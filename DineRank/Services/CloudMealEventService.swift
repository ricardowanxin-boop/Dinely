import CloudKit
import Foundation

final class CloudMealEventService {
    static let shared = CloudMealEventService()

    private enum RecordType: String {
        case meta = "DineRankMealEvent"
        case participant = "DineRankMealParticipant"
        case timeVote = "DineRankMealTimeVote"
        case restaurantVote = "DineRankMealRestaurantVote"
    }

    private enum Field {
        static let eventID = "eventID"
        static let payload = "payload"
        static let title = "title"
        static let creatorDeviceID = "creatorDeviceId"
        static let updatedAt = "updatedAt"

        static let participantID = "participantID"
        static let nickname = "nickname"
        static let avatarEmoji = "avatarEmoji"
        static let hasVotedTime = "hasVotedTime"
        static let hasVotedRestaurant = "hasVotedRestaurant"
        static let attended = "attended"
        static let rankRawValue = "rankRawValue"
        static let attendanceRate = "attendanceRate"
        static let isLocationSharingEnabled = "isLocationSharingEnabled"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let locationTimestamp = "locationTimestamp"
        static let lastLocationUpdate = "lastLocationUpdate"

        static let slotID = "slotID"
        static let restaurantID = "restaurantID"
    }

    private struct TimeVotePayload {
        let slotID: UUID
        let participantID: UUID
    }

    private struct RestaurantVotePayload {
        let restaurantID: UUID
        let participantID: UUID
    }

    private let database: CKDatabase
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let isEnabled: Bool

    init(
        container: CKContainer = CKContainer(identifier: AppConfig.cloudKitContainerIdentifier),
        isEnabled: Bool = !AppRuntime.isUITesting && AppRuntime.allowsNativeBootstrapOnLaunch
    ) {
        database = container.publicCloudDatabase
        self.isEnabled = isEnabled
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func publish(_ event: MealEvent) async throws {
        guard isEnabled else { return }

        try await saveMetaRecord(for: event)
        try await syncParticipants(for: event)
        try await syncTimeVotes(for: event)
        try await syncRestaurantVotes(for: event)
    }

    func fetch(eventID: UUID) async throws -> MealEvent? {
        guard isEnabled else { return nil }

        let metaRecordID = CKRecord.ID(recordName: eventID.uuidString)

        do {
            let metaRecord = try await database.record(for: metaRecordID)
            guard let payload = metaRecord[Field.payload] as? Data else { return nil }

            var event = try decoder.decode(MealEvent.self, from: payload)

            let participantRecords = try await fetchRecords(type: .participant, eventID: eventID)
            if !participantRecords.isEmpty {
                event.participants = participantRecords
                    .compactMap(decodeParticipant)
                    .sorted(by: participantSort)
            }

            let timeVoteRecords = try await fetchRecords(type: .timeVote, eventID: eventID)
            if !timeVoteRecords.isEmpty {
                let groupedVotes = Dictionary(grouping: timeVoteRecords.compactMap(decodeTimeVote), by: \.slotID)
                    .mapValues { payloads in payloads.map(\.participantID) }

                for index in event.candidateTimes.indices {
                    event.candidateTimes[index].votes = groupedVotes[event.candidateTimes[index].id] ?? []
                }
            }

            let restaurantVoteRecords = try await fetchRecords(type: .restaurantVote, eventID: eventID)
            if !restaurantVoteRecords.isEmpty {
                let groupedVotes = Dictionary(grouping: restaurantVoteRecords.compactMap(decodeRestaurantVote), by: \.restaurantID)
                    .mapValues { payloads in payloads.map(\.participantID) }

                for index in event.candidateRestaurants.indices {
                    event.candidateRestaurants[index].votes = groupedVotes[event.candidateRestaurants[index].id] ?? []
                }
            }

            event.updatedAt = resolveUpdatedAt(
                base: event.updatedAt,
                records: [metaRecord] + participantRecords + timeVoteRecords + restaurantVoteRecords
            )

            return event
        } catch let error as CKError where error.code == .unknownItem {
            return nil
        }
    }

    func fetch(events: [MealEvent]) async -> [MealEvent] {
        guard isEnabled, !events.isEmpty else { return events }

        var updatedEvents: [MealEvent] = []

        for event in events {
            guard let remote = try? await fetch(eventID: event.id) else {
                updatedEvents.append(event)
                continue
            }

            if remote.updatedAt >= event.updatedAt {
                updatedEvents.append(remote)
            } else {
                updatedEvents.append(event)
            }
        }

        return updatedEvents
    }

    private func saveMetaRecord(for event: MealEvent) async throws {
        let recordID = CKRecord.ID(recordName: event.id.uuidString)
        let record = CKRecord(recordType: RecordType.meta.rawValue, recordID: recordID)
        record[Field.eventID] = event.id.uuidString as CKRecordValue
        record[Field.title] = event.title as CKRecordValue
        record[Field.creatorDeviceID] = event.creatorDeviceId as CKRecordValue
        record[Field.updatedAt] = event.updatedAt as CKRecordValue
        record[Field.payload] = try encoder.encode(event) as CKRecordValue
        _ = try await database.save(record)
    }

    private func syncParticipants(for event: MealEvent) async throws {
        let existingRecords = try await fetchRecords(type: .participant, eventID: event.id)
        let expectedRecordNames = Set(event.participants.map { participantRecordName(eventID: event.id, participantID: $0.id) })

        for participant in event.participants {
            let record = participantRecord(for: participant, eventID: event.id, eventUpdatedAt: event.updatedAt)
            _ = try await database.save(record)
        }

        for staleRecord in existingRecords where !expectedRecordNames.contains(staleRecord.recordID.recordName) {
            try? await database.deleteRecord(withID: staleRecord.recordID)
        }
    }

    private func syncTimeVotes(for event: MealEvent) async throws {
        let existingRecords = try await fetchRecords(type: .timeVote, eventID: event.id)
        let expectedRecordNames = Set(
            event.candidateTimes.flatMap { slot in
                slot.votes.map { timeVoteRecordName(eventID: event.id, slotID: slot.id, participantID: $0) }
            }
        )

        for slot in event.candidateTimes {
            for participantID in slot.votes {
                let recordID = CKRecord.ID(recordName: timeVoteRecordName(eventID: event.id, slotID: slot.id, participantID: participantID))
                let record = CKRecord(recordType: RecordType.timeVote.rawValue, recordID: recordID)
                record[Field.eventID] = event.id.uuidString as CKRecordValue
                record[Field.slotID] = slot.id.uuidString as CKRecordValue
                record[Field.participantID] = participantID.uuidString as CKRecordValue
                record[Field.updatedAt] = event.updatedAt as CKRecordValue
                _ = try await database.save(record)
            }
        }

        for staleRecord in existingRecords where !expectedRecordNames.contains(staleRecord.recordID.recordName) {
            try? await database.deleteRecord(withID: staleRecord.recordID)
        }
    }

    private func syncRestaurantVotes(for event: MealEvent) async throws {
        let existingRecords = try await fetchRecords(type: .restaurantVote, eventID: event.id)
        let expectedRecordNames = Set(
            event.candidateRestaurants.flatMap { restaurant in
                restaurant.votes.map { restaurantVoteRecordName(eventID: event.id, restaurantID: restaurant.id, participantID: $0) }
            }
        )

        for restaurant in event.candidateRestaurants {
            for participantID in restaurant.votes {
                let recordID = CKRecord.ID(recordName: restaurantVoteRecordName(eventID: event.id, restaurantID: restaurant.id, participantID: participantID))
                let record = CKRecord(recordType: RecordType.restaurantVote.rawValue, recordID: recordID)
                record[Field.eventID] = event.id.uuidString as CKRecordValue
                record[Field.restaurantID] = restaurant.id.uuidString as CKRecordValue
                record[Field.participantID] = participantID.uuidString as CKRecordValue
                record[Field.updatedAt] = event.updatedAt as CKRecordValue
                _ = try await database.save(record)
            }
        }

        for staleRecord in existingRecords where !expectedRecordNames.contains(staleRecord.recordID.recordName) {
            try? await database.deleteRecord(withID: staleRecord.recordID)
        }
    }

    private func fetchRecords(type: RecordType, eventID: UUID) async throws -> [CKRecord] {
        let query = CKQuery(
            recordType: type.rawValue,
            predicate: NSPredicate(format: "eventID == %@", eventID.uuidString)
        )

        let (matches, _) = try await database.records(matching: query, resultsLimit: 200)

        var records: [CKRecord] = []
        for (_, result) in matches {
            if let record = try? result.get() {
                records.append(record)
            }
        }
        return records
    }

    private func participantRecord(for participant: Participant, eventID: UUID, eventUpdatedAt: Date) -> CKRecord {
        let recordID = CKRecord.ID(recordName: participantRecordName(eventID: eventID, participantID: participant.id))
        let record = CKRecord(recordType: RecordType.participant.rawValue, recordID: recordID)
        record[Field.eventID] = eventID.uuidString as CKRecordValue
        record[Field.participantID] = participant.id.uuidString as CKRecordValue
        record[Field.nickname] = participant.nickname as CKRecordValue
        record[Field.avatarEmoji] = participant.avatarEmoji as CKRecordValue
        record[Field.hasVotedTime] = participant.hasVotedTime as CKRecordValue
        record[Field.hasVotedRestaurant] = participant.hasVotedRestaurant as CKRecordValue
        record[Field.rankRawValue] = participant.rank.rawValue as CKRecordValue
        record[Field.isLocationSharingEnabled] = participant.isLocationSharingEnabled as CKRecordValue
        record[Field.updatedAt] = (participant.lastLocationUpdate ?? eventUpdatedAt) as CKRecordValue

        if let attendanceRate = participant.attendanceRate {
            record[Field.attendanceRate] = attendanceRate as CKRecordValue
        } else {
            record[Field.attendanceRate] = nil
        }

        if let attended = participant.attended {
            record[Field.attended] = attended as CKRecordValue
        } else {
            record[Field.attended] = nil
        }

        if let location = participant.currentLocation {
            record[Field.latitude] = location.latitude as CKRecordValue
            record[Field.longitude] = location.longitude as CKRecordValue
            record[Field.locationTimestamp] = location.timestamp as CKRecordValue
        } else {
            record[Field.latitude] = nil
            record[Field.longitude] = nil
            record[Field.locationTimestamp] = nil
        }

        if let lastLocationUpdate = participant.lastLocationUpdate {
            record[Field.lastLocationUpdate] = lastLocationUpdate as CKRecordValue
        } else {
            record[Field.lastLocationUpdate] = nil
        }

        return record
    }

    private func decodeParticipant(from record: CKRecord) -> Participant? {
        guard
            let participantIDRaw = record[Field.participantID] as? String,
            let participantID = UUID(uuidString: participantIDRaw),
            let nickname = record[Field.nickname] as? String,
            let avatarEmoji = record[Field.avatarEmoji] as? String,
            let rankRawValue = record[Field.rankRawValue] as? Int,
            let rank = AttendanceRank(rawValue: rankRawValue)
        else {
            return nil
        }

        let latitude = record[Field.latitude] as? Double
        let longitude = record[Field.longitude] as? Double
        let locationTimestamp = record[Field.locationTimestamp] as? Date

        let location: LocationPoint?
        if let latitude, let longitude {
            location = LocationPoint(
                latitude: latitude,
                longitude: longitude,
                timestamp: locationTimestamp ?? Date()
            )
        } else {
            location = nil
        }

        return Participant(
            id: participantID,
            nickname: nickname,
            avatarEmoji: avatarEmoji,
            hasVotedTime: (record[Field.hasVotedTime] as? Int == 1) || (record[Field.hasVotedTime] as? Bool == true),
            hasVotedRestaurant: (record[Field.hasVotedRestaurant] as? Int == 1) || (record[Field.hasVotedRestaurant] as? Bool == true),
            attended: record[Field.attended] as? Bool,
            rank: rank,
            attendanceRate: record[Field.attendanceRate] as? Double,
            currentLocation: location,
            isLocationSharingEnabled: (record[Field.isLocationSharingEnabled] as? Int == 1) || (record[Field.isLocationSharingEnabled] as? Bool == true),
            lastLocationUpdate: record[Field.lastLocationUpdate] as? Date
        )
    }

    private func decodeTimeVote(from record: CKRecord) -> TimeVotePayload? {
        guard
            let slotIDRaw = record[Field.slotID] as? String,
            let slotID = UUID(uuidString: slotIDRaw),
            let participantIDRaw = record[Field.participantID] as? String,
            let participantID = UUID(uuidString: participantIDRaw)
        else {
            return nil
        }

        return TimeVotePayload(slotID: slotID, participantID: participantID)
    }

    private func decodeRestaurantVote(from record: CKRecord) -> RestaurantVotePayload? {
        guard
            let restaurantIDRaw = record[Field.restaurantID] as? String,
            let restaurantID = UUID(uuidString: restaurantIDRaw),
            let participantIDRaw = record[Field.participantID] as? String,
            let participantID = UUID(uuidString: participantIDRaw)
        else {
            return nil
        }

        return RestaurantVotePayload(restaurantID: restaurantID, participantID: participantID)
    }

    private func participantRecordName(eventID: UUID, participantID: UUID) -> String {
        "\(eventID.uuidString)-participant-\(participantID.uuidString)"
    }

    private func timeVoteRecordName(eventID: UUID, slotID: UUID, participantID: UUID) -> String {
        "\(eventID.uuidString)-time-\(slotID.uuidString)-\(participantID.uuidString)"
    }

    private func restaurantVoteRecordName(eventID: UUID, restaurantID: UUID, participantID: UUID) -> String {
        "\(eventID.uuidString)-restaurant-\(restaurantID.uuidString)-\(participantID.uuidString)"
    }

    private func participantSort(lhs: Participant, rhs: Participant) -> Bool {
        if lhs.isLocationSharingEnabled == rhs.isLocationSharingEnabled {
            return lhs.nickname.localizedStandardCompare(rhs.nickname) == .orderedAscending
        }

        return lhs.isLocationSharingEnabled && !rhs.isLocationSharingEnabled
    }

    private func resolveUpdatedAt(base: Date, records: [CKRecord]) -> Date {
        records.reduce(base) { current, record in
            let updatedAt = record[Field.updatedAt] as? Date ?? current
            return max(current, updatedAt)
        }
    }
}
