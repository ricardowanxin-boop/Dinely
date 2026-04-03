import CloudKit
import Foundation
import SwiftData

@Model
final class DashboardCacheRecord {
    @Attribute(.unique) var key: String
    var payload: Data
    var updatedAt: Date

    init(key: String, payload: Data, updatedAt: Date) {
        self.key = key
        self.payload = payload
        self.updatedAt = updatedAt
    }
}

private actor DashboardLocalStore {
    private let container: ModelContainer?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let recordKey = "current-dashboard"
    private let fallbackPayloadKey = "dinerank.dashboard.payload"

    init(useInMemoryStore: Bool = AppRuntime.isUITesting) {
        container = Self.makeContainer(useInMemoryStore: useInMemoryStore)
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func loadDashboard() -> DineRankDashboard? {
        if let container {
            let context = ModelContext(container)
            let descriptor = FetchDescriptor<DashboardCacheRecord>(
                predicate: #Predicate { $0.key == "current-dashboard" }
            )

            if
                let record = try? context.fetch(descriptor).first,
                let dashboard = try? decoder.decode(DineRankDashboard.self, from: record.payload)
            {
                return dashboard
            }
        }

        guard
            let payload = SharedDefaults.store.data(forKey: fallbackPayloadKey),
            let dashboard = try? decoder.decode(DineRankDashboard.self, from: payload)
        else {
            return nil
        }

        return dashboard
    }

    func saveDashboard(_ dashboard: DineRankDashboard) {
        let data = (try? encoder.encode(dashboard)) ?? Data()

        SharedDefaults.store.set(data, forKey: fallbackPayloadKey)

        guard let container else { return }

        let context = ModelContext(container)
        let descriptor = FetchDescriptor<DashboardCacheRecord>(
            predicate: #Predicate { $0.key == "current-dashboard" }
        )

        if let existing = try? context.fetch(descriptor).first {
            existing.payload = data
            existing.updatedAt = Date()
        } else {
            context.insert(DashboardCacheRecord(key: recordKey, payload: data, updatedAt: Date()))
        }

        try? context.save()
    }

    private static func makeContainer(useInMemoryStore: Bool) -> ModelContainer? {
        do {
            let configuration = ModelConfiguration(
                isStoredInMemoryOnly: useInMemoryStore,
                cloudKitDatabase: .none
            )
            return try ModelContainer(for: DashboardCacheRecord.self, configurations: configuration)
        } catch let primaryError {
            do {
                let config = ModelConfiguration(
                    isStoredInMemoryOnly: true,
                    cloudKitDatabase: .none
                )
                return try ModelContainer(for: DashboardCacheRecord.self, configurations: config)
            } catch let fallbackError {
                #if DEBUG
                print(
                    "SwiftData container unavailable; falling back to shared defaults only. " +
                    "Primary: \(primaryError.localizedDescription). " +
                    "Fallback: \(fallbackError.localizedDescription)"
                )
                #endif
                return nil
            }
        }
    }
}

private final class CloudDashboardSyncService {
    private let database: CKDatabase
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let recordType = "DineRankDashboardSnapshot"
    private let isEnabled: Bool

    init(
        container: CKContainer = CKContainer(identifier: AppConfig.cloudKitContainerIdentifier),
        isEnabled: Bool = !AppRuntime.isUITesting && AppRuntime.allowsNativeBootstrapOnLaunch
    ) {
        database = container.publicCloudDatabase
        self.isEnabled = isEnabled
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func fetchDashboard(ownerID: String) async throws -> DineRankDashboard? {
        guard isEnabled else { return nil }

        let query = CKQuery(
            recordType: recordType,
            predicate: NSPredicate(format: "ownerID == %@", ownerID)
        )
        query.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]

        let (matches, _) = try await database.records(matching: query, resultsLimit: 1)
        for (_, result) in matches {
            let record = try result.get()
            guard let payload = record["payload"] as? Data else { continue }
            return try decoder.decode(DineRankDashboard.self, from: payload)
        }

        return nil
    }

    func saveDashboard(_ dashboard: DineRankDashboard, ownerID: String) async {
        guard isEnabled else { return }

        let recordID = CKRecord.ID(recordName: "dashboard-\(ownerID)")
        let record = CKRecord(recordType: recordType, recordID: recordID)

        record["ownerID"] = ownerID as CKRecordValue
        record["updatedAt"] = Date() as CKRecordValue
        record["payload"] = ((try? encoder.encode(dashboard)) ?? Data()) as CKRecordValue

        do {
            _ = try await database.save(record)
        } catch {
            // CloudKit is best-effort here; local SwiftData remains the source of truth offline.
            print("CloudKit save failed: \(error.localizedDescription)")
        }
    }
}

final class DemoContentRepository {
    private let localStore: DashboardLocalStore
    private lazy var cloudStore = CloudDashboardSyncService()

    init() {
        localStore = DashboardLocalStore()
    }

    func loadDashboard() async -> DineRankDashboard {
        try? await Task.sleep(for: .milliseconds(180))

        if let cached = await localStore.loadDashboard() {
            return cached
        }

        let seeded = SampleData.dashboard()
        await localStore.saveDashboard(seeded)
        return seeded
    }

    func refreshDashboard(current: DineRankDashboard) async -> DineRankDashboard {
        do {
            if let remote = try await cloudStore.fetchDashboard(ownerID: current.profile.deviceId.uuidString) {
                let resolved = remote.latestSnapshot.fetchedAt >= current.latestSnapshot.fetchedAt ? remote : current
                await localStore.saveDashboard(resolved)
                return resolved
            }
        } catch {
            print("CloudKit fetch failed: \(error.localizedDescription)")
        }

        await localStore.saveDashboard(current)
        return current
    }

    func saveDashboard(_ dashboard: DineRankDashboard) async {
        await localStore.saveDashboard(dashboard)
        await cloudStore.saveDashboard(dashboard, ownerID: dashboard.profile.deviceId.uuidString)
    }

    func loadLatestSnapshot() async -> TemplateSnapshot {
        let dashboard = await loadDashboard()
        SharedDefaults.saveLatestSnapshot(dashboard.latestSnapshot)
        return dashboard.latestSnapshot
    }
}
