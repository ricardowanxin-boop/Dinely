import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var snapshot: TemplateSnapshot
    @Published private(set) var isRefreshing = false
    @Published private(set) var lastEventDescription: String
    @Published private(set) var events: [MealEvent]
    @Published private(set) var profile: AttendanceProfile
    @Published private(set) var leaderboard: [LeaderboardEntry]
    @Published private(set) var battleReport: BattleReport
    @Published private(set) var heroTitle: String
    @Published private(set) var heroSubtitle: String
    @Published private(set) var localizedBrandName: String
    @Published var transientMessage: String?

    private let repository: DemoContentRepository
    private let notificationManager: NotificationManager
    private let collaborationService: CloudMealEventService

    init(
        repository: DemoContentRepository = DemoContentRepository(),
        notificationManager: NotificationManager? = nil,
        collaborationService: CloudMealEventService = .shared
    ) {
        let dashboard = SampleData.dashboard()
        snapshot = SharedDefaults.loadLatestSnapshot() ?? dashboard.latestSnapshot
        lastEventDescription = "地图投票、签到、AA 与战报已经接入首版信息架构。"
        events = dashboard.events
        profile = dashboard.profile
        leaderboard = dashboard.leaderboard
        battleReport = dashboard.battleReport
        heroTitle = dashboard.heroTitle
        heroSubtitle = dashboard.heroSubtitle
        localizedBrandName = AppConfig.localizedBrandName()
        self.repository = repository
        self.notificationManager = notificationManager ?? .shared
        self.collaborationService = collaborationService
    }

    var openEvents: [MealEvent] {
        events.filter { $0.status != .completed }
    }

    var currentNickname: String {
        profile.nickname
    }

    var profileDeviceID: UUID {
        profile.deviceId
    }

    func event(for id: UUID) -> MealEvent? {
        events.first { $0.id == id }
    }

    func loadInitialContent() async {
        let dashboard = await repository.loadDashboard()
        apply(dashboard: dashboard)
        persistSnapshotOnly(dashboard.latestSnapshot)
        lastEventDescription = "已从本地与云端载入 \(events.count) 个约饭局。"
    }

    func refresh(showNotification: Bool) async {
        guard !isRefreshing else { return }

        isRefreshing = true
        lastEventDescription = "正在刷新约饭局、段位档案和战报摘要。"
        defer { isRefreshing = false }

        let dashboard = await repository.refreshDashboard(current: composeDashboard())
        let syncedEvents = await synchronizeSharedEvents(dashboard.events)
        let resolvedDashboard = DineRankDashboard(
            heroTitle: dashboard.heroTitle,
            heroSubtitle: dashboard.heroSubtitle,
            events: syncedEvents,
            profile: dashboard.profile,
            leaderboard: dashboard.leaderboard,
            battleReport: dashboard.battleReport,
            latestSnapshot: dashboard.latestSnapshot
        )
        apply(dashboard: resolvedDashboard)
        persistSnapshotOnly(resolvedDashboard.latestSnapshot)
        lastEventDescription = "已同步 \(events.count) 个约饭局，当前段位为 \(profile.currentRank.title)。"

        if showNotification {
            await notificationManager.sendManualUpdateNotification(snapshot: dashboard.latestSnapshot)
        }
    }

    func writeSampleSnapshot() {
        let snapshot = SampleData.manualSnapshot()
        persistSnapshotOnly(snapshot)
        persistCurrentDashboard(snapshotOverride: snapshot)
        lastEventDescription = "已写入一份新的分享快照。"
    }

    func addEvent(from draft: CreateEventDraft, hasProAccess: Bool) -> MealEvent {
        let participantSeed = seededParticipants()
        let restaurants = Array(draft.candidateRestaurants.prefix(AppConfig.maximumCandidateRestaurants))
        let timeSlots = draft.candidateTimes.map {
            TimeSlot(id: $0.id, startDate: $0.startDate, endDate: $0.endDate, period: $0.period, votes: [])
        }

        let event = MealEvent(
            id: UUID(),
            title: draft.title,
            categoryEmoji: cuisineEmoji(for: draft.cuisine),
            creatorDeviceId: profile.deviceId.uuidString,
            creatorName: profile.nickname,
            cuisine: draft.cuisine,
            budgetPerPerson: draft.budgetPerPerson,
            candidateTimes: Array(timeSlots.prefix(AppConfig.maximumCandidateTimes)),
            candidateRestaurants: restaurants,
            participants: participantSeed,
            status: .voting,
            confirmedTime: nil,
            confirmedRestaurant: nil,
            totalBill: nil,
            maxParticipants: min(
                draft.maxParticipants,
                hasProAccess ? AppConfig.maximumProParticipants : AppConfig.maximumFreeParticipants
            ),
            updatedAt: Date()
        )

        events.insert(event, at: 0)
        heroTitle = "新的约饭局已创建"
        heroSubtitle = "地图选餐厅与多选投票已经准备好，可以直接开始邀请朋友。"
        lastEventDescription = "已创建《\(event.title)》，当前保存在本地并准备同步到 CloudKit。"
        let newSnapshot = makeSnapshot(
            for: event,
            detail: "新的约饭局已创建完成，下一步可以把分享链接发给朋友参与投票。",
            sourceLabel: "本地创建"
        )
        persistSnapshotOnly(newSnapshot)
        persistCurrentDashboard(snapshotOverride: newSnapshot)
        Task {
            await publish(event)
        }
        return event
    }

    func updateEvent(_ eventID: UUID, from draft: CreateEventDraft, hasProAccess: Bool) -> MealEvent? {
        guard let index = events.firstIndex(where: { $0.id == eventID }) else { return nil }
        var event = events[index]

        let existingTimeVotes = Dictionary(uniqueKeysWithValues: event.candidateTimes.map { ($0.id, $0.votes) })
        let existingRestaurantVotes = Dictionary(uniqueKeysWithValues: event.candidateRestaurants.map { ($0.selectionKey, $0.votes) })

        let updatedTimes = Array(draft.candidateTimes.prefix(AppConfig.maximumCandidateTimes)).map {
            TimeSlot(
                id: $0.id,
                startDate: $0.startDate,
                endDate: $0.endDate,
                period: $0.period,
                votes: existingTimeVotes[$0.id] ?? []
            )
        }

        let updatedRestaurants = Array(draft.candidateRestaurants.prefix(AppConfig.maximumCandidateRestaurants)).map { restaurant in
            var copy = restaurant
            copy.votes = existingRestaurantVotes[restaurant.selectionKey] ?? []
            return copy
        }

        event.title = draft.title
        event.categoryEmoji = cuisineEmoji(for: draft.cuisine)
        event.cuisine = draft.cuisine
        event.budgetPerPerson = draft.budgetPerPerson
        event.candidateTimes = updatedTimes
        event.candidateRestaurants = updatedRestaurants
        event.maxParticipants = max(
            event.participants.count,
            min(
                draft.maxParticipants,
                hasProAccess ? AppConfig.maximumProParticipants : AppConfig.maximumFreeParticipants
            )
        )

        if let confirmedTime = event.confirmedTime, !updatedTimes.contains(where: { $0.id == confirmedTime.id }) {
            event.confirmedTime = nil
        }

        if let confirmedRestaurant = event.confirmedRestaurant,
           !updatedRestaurants.contains(where: { $0.selectionKey == confirmedRestaurant.selectionKey }) {
            event.confirmedRestaurant = nil
        }

        if event.status == .confirmed, (event.confirmedTime == nil || event.confirmedRestaurant == nil) {
            event.status = .voting
        }

        for participantIndex in event.participants.indices {
            let participantID = event.participants[participantIndex].id
            event.participants[participantIndex].hasVotedTime = updatedTimes.contains { $0.votes.contains(participantID) }
            event.participants[participantIndex].hasVotedRestaurant = updatedRestaurants.contains { $0.votes.contains(participantID) }
        }

        event.updatedAt = Date()
        events[index] = event

        heroTitle = "约饭局已更新"
        heroSubtitle = "时间、餐厅和参与人数设置已经保存。"
        lastEventDescription = "《\(event.title)》的约饭设置已更新。"
        let snapshot = makeSnapshot(
            for: event,
            detail: "约饭局信息已完成修改，分享出去后看到的就是最新版本。",
            sourceLabel: "本地编辑"
        )
        persistSnapshotOnly(snapshot)
        persistCurrentDashboard(snapshotOverride: snapshot)
        Task {
            await publish(event)
        }
        return event
    }

    @discardableResult
    func deleteEvent(_ eventID: UUID) -> Bool {
        guard let index = events.firstIndex(where: { $0.id == eventID }) else { return false }
        let removedEvent = events.remove(at: index)

        heroTitle = events.isEmpty ? "还没有约饭局" : "已删除约饭局"
        heroSubtitle = events.isEmpty ? "创建第一场约饭局，邀请熟人一起投票决定去哪吃。" : "可以继续编辑或创建新的约饭局。"
        lastEventDescription = "《\(removedEvent.title)》已从当前列表移除。"

        let snapshot = events.first.map {
            makeSnapshot(
                for: $0,
                detail: "当前首页已经更新到最新的约饭列表。",
                sourceLabel: "本地删除"
            )
        } ?? makeEmptySnapshot(detail: "当前还没有约饭局，创建一场新的饭局就能继续邀请朋友。")

        persistSnapshotOnly(snapshot)
        persistCurrentDashboard(snapshotOverride: snapshot)
        return true
    }

    func confirmEvent(_ eventID: UUID) -> MealEvent? {
        guard let index = events.firstIndex(where: { $0.id == eventID }) else { return nil }
        var event = events[index]

        event.confirmedTime = event.candidateTimes.max(by: { $0.voteCount < $1.voteCount }) ?? event.candidateTimes.first
        event.confirmedRestaurant = event.candidateRestaurants.max(by: { $0.voteCount < $1.voteCount }) ?? event.candidateRestaurants.first
        event.status = .confirmed
        event.updatedAt = Date()
        events[index] = event

        heroTitle = "约饭已确认"
        heroSubtitle = "大家可以开始共享位置并准备赴约。"
        lastEventDescription = "《\(event.title)》已确认，接下来进入约饭当天地图与签到流程。"
        let snapshot = makeSnapshot(
            for: event,
            detail: "发起人已经确认了时间和餐厅，约饭当天可查看实时距离并完成自动签到。",
            sourceLabel: "本地确认"
        )
        persistSnapshotOnly(snapshot)
        persistCurrentDashboard(snapshotOverride: snapshot)
        Task {
            await publish(event)
        }
        return event
    }

    func completeEvent(_ eventID: UUID, attendedIDs: [UUID], totalBill: Double) -> (MealEvent, BattleReport)? {
        guard let index = events.firstIndex(where: { $0.id == eventID }) else { return nil }
        var event = events[index]

        event.participants = event.participants.map { participant in
            var copy = participant
            copy.attended = attendedIDs.contains(participant.id)
            return copy
        }
        event.status = .completed
        event.totalBill = totalBill
        event.updatedAt = Date()
        events[index] = event

        updateProfileAttendance(eventID: event.id, attended: attendedIDs.contains(profile.deviceId))

        let updatedReport = battleReport(for: event)
        battleReport = updatedReport
        leaderboard = updatedLeaderboard()
        heroTitle = "战报已生成"
        heroSubtitle = "签到、AA 和守约段位已经全部更新。"
        lastEventDescription = "《\(event.title)》已完成结算，并生成了新的守约战报。"
        let snapshot = makeSnapshot(
            for: event,
            detail: "本次聚餐已经完成签到和 AA 结算，战报卡可用于后续分享。",
            sourceLabel: "聚餐完成"
        )
        persistSnapshotOnly(snapshot)
        persistCurrentDashboard(snapshotOverride: snapshot)
        Task {
            await publish(event)
        }
        return (event, updatedReport)
    }

    func updateLocationSharing(eventID: UUID, isEnabled: Bool, currentLocation: LocationPoint?) -> MealEvent? {
        guard let index = events.firstIndex(where: { $0.id == eventID }) else { return nil }
        var event = events[index]

        if let participantIndex = currentParticipantIndex(in: event) {
            event.participants[participantIndex].isLocationSharingEnabled = isEnabled
            event.participants[participantIndex].currentLocation = isEnabled ? currentLocation : nil
            event.participants[participantIndex].lastLocationUpdate = isEnabled ? Date() : nil
        }

        event.updatedAt = Date()
        events[index] = event
        persistCurrentDashboard()
        Task {
            await publish(event)
        }
        return event
    }

    func toggleTimeVote(eventID: UUID, slotID: UUID) -> MealEvent? {
        guard let eventIndex = events.firstIndex(where: { $0.id == eventID }) else { return nil }
        var event = events[eventIndex]
        guard let slotIndex = event.candidateTimes.firstIndex(where: { $0.id == slotID }) else { return nil }

        let userID = profile.deviceId
        if event.candidateTimes[slotIndex].votes.contains(userID) {
            event.candidateTimes[slotIndex].votes.removeAll { $0 == userID }
        } else {
            event.candidateTimes[slotIndex].votes.append(userID)
        }

        let hasVotedTime = event.candidateTimes.contains { $0.votes.contains(userID) }
        updateCurrentParticipant(in: &event) { participant in
            participant.hasVotedTime = hasVotedTime
        }

        event.updatedAt = Date()
        events[eventIndex] = event
        persistCurrentDashboard()
        Task {
            await publish(event)
        }
        return event
    }

    func toggleRestaurantVote(eventID: UUID, restaurantID: UUID) -> MealEvent? {
        guard let eventIndex = events.firstIndex(where: { $0.id == eventID }) else { return nil }
        var event = events[eventIndex]
        guard let restaurantIndex = event.candidateRestaurants.firstIndex(where: { $0.id == restaurantID }) else { return nil }

        let userID = profile.deviceId
        let selectedRestaurantIDs = event.candidateRestaurants
            .filter { $0.votes.contains(userID) }
            .map(\.id)

        if event.candidateRestaurants[restaurantIndex].votes.contains(userID) {
            event.candidateRestaurants[restaurantIndex].votes.removeAll { $0 == userID }
        } else {
            guard selectedRestaurantIDs.count < 2 else {
                transientMessage = "餐厅投票最多只能选择 2 家。"
                return nil
            }
            event.candidateRestaurants[restaurantIndex].votes.append(userID)
        }

        let hasVotedRestaurant = event.candidateRestaurants.contains { $0.votes.contains(userID) }
        updateCurrentParticipant(in: &event) { participant in
            participant.hasVotedRestaurant = hasVotedRestaurant
        }

        event.updatedAt = Date()
        events[eventIndex] = event
        persistCurrentDashboard()
        Task {
            await publish(event)
        }
        return event
    }

    func shareURL(for event: MealEvent) -> URL {
        AppConfig.preferredShareURL(for: event.id)
    }

    func shareMessage(for event: MealEvent) -> String {
        let fallbackURL = AppConfig.joinURL(for: event.id)
        return """
        我发起了一个新的约饭局《\(event.title)》。
        打开链接就能填写昵称、选择头像并直接参与时间和餐厅投票：
        \(shareURL(for: event).absoluteString)

        如果当前环境没有直接拉起 App，可使用备用链接：
        \(fallbackURL.absoluteString)
        """
    }

    func publishEventForSharing(_ eventID: UUID) async -> URL? {
        guard let event = event(for: eventID) else { return nil }
        await publish(event)
        return shareURL(for: event)
    }

    func resolveSharedEvent(url: URL) async -> MealEvent? {
        guard let eventID = AppConfig.sharedEventID(from: url) else { return nil }

        if let local = event(for: eventID) {
            return local
        }

        guard let remote = try? await collaborationService.fetch(eventID: eventID) else {
            transientMessage = "没有找到这场约饭局，可能分享链接已失效。"
            return nil
        }

        return remote
    }

    func refreshEvent(_ eventID: UUID) async -> MealEvent? {
        guard let local = event(for: eventID) else { return nil }

        guard let remote = try? await collaborationService.fetch(eventID: eventID) else {
            return local
        }

        let resolved = remote.updatedAt >= local.updatedAt ? remote : local
        if let index = events.firstIndex(where: { $0.id == resolved.id }) {
            events[index] = resolved
            persistCurrentDashboard()
        }
        return resolved
    }

    func joinSharedEvent(_ event: MealEvent, nickname: String, avatarEmoji: String) async -> MealEvent {
        var joinedEvent = event
        let sanitizedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? profile.nickname : nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        let sanitizedEmoji = avatarEmoji.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "🍽️" : avatarEmoji.trimmingCharacters(in: .whitespacesAndNewlines)

        profile.nickname = sanitizedNickname
        profile.lastUpdated = Date()

        if let index = joinedEvent.participants.firstIndex(where: { $0.id == profile.deviceId }) {
            joinedEvent.participants[index].nickname = sanitizedNickname
            joinedEvent.participants[index].avatarEmoji = sanitizedEmoji
            joinedEvent.participants[index].rank = profile.currentRank
            joinedEvent.participants[index].attendanceRate = profile.attendanceRate
        } else if joinedEvent.participants.count < joinedEvent.maxParticipants {
            joinedEvent.participants.append(
                Participant(
                    id: profile.deviceId,
                    nickname: sanitizedNickname,
                    avatarEmoji: sanitizedEmoji,
                    hasVotedTime: false,
                    hasVotedRestaurant: false,
                    attended: nil,
                    rank: profile.currentRank,
                    attendanceRate: profile.attendanceRate,
                    currentLocation: nil,
                    isLocationSharingEnabled: false,
                    lastLocationUpdate: nil
                )
            )
        }

        joinedEvent.updatedAt = Date()

        if let existingIndex = events.firstIndex(where: { $0.id == joinedEvent.id }) {
            events[existingIndex] = joinedEvent
        } else {
            events.insert(joinedEvent, at: 0)
        }

        heroTitle = "已加入约饭局"
        heroSubtitle = "现在可以直接参与时间和餐厅投票。"
        lastEventDescription = "你已加入《\(joinedEvent.title)》，接下来可以开始投票。"
        let snapshot = makeSnapshot(
            for: joinedEvent,
            detail: "你已通过分享链接加入这场约饭局，后续投票结果会同步更新。",
            sourceLabel: "分享加入"
        )
        persistSnapshotOnly(snapshot)
        persistCurrentDashboard(snapshotOverride: snapshot)
        await publish(joinedEvent)
        return joinedEvent
    }

    func battleReport(for event: MealEvent) -> BattleReport {
        if event.status == .completed {
            let attendedCount = event.participants.filter { $0.attended ?? false }.count
            return BattleReport(
                id: event.id,
                eventTitle: event.title,
                date: event.confirmedTime?.startDate ?? Date(),
                invitedCount: event.participants.count,
                attendedCount: attendedCount,
                averageSpend: event.totalBill.map { $0 / Double(max(attendedCount, 1)) } ?? battleReport.averageSpend,
                heroNames: event.participants.filter { $0.attended ?? false }.map(\.nickname),
                noShowNames: event.participants.filter { ($0.attended ?? false) == false }.map(\.nickname)
            )
        }

        return battleReport
    }

    private func apply(dashboard: DineRankDashboard) {
        heroTitle = dashboard.heroTitle
        heroSubtitle = dashboard.heroSubtitle
        events = dashboard.events
        profile = dashboard.profile
        leaderboard = dashboard.leaderboard
        battleReport = dashboard.battleReport
        localizedBrandName = AppConfig.localizedBrandName()
    }

    private func composeDashboard(snapshotOverride: TemplateSnapshot? = nil) -> DineRankDashboard {
        DineRankDashboard(
            heroTitle: heroTitle,
            heroSubtitle: heroSubtitle,
            events: events,
            profile: profile,
            leaderboard: leaderboard,
            battleReport: battleReport,
            latestSnapshot: snapshotOverride ?? snapshot
        )
    }

    private func persistCurrentDashboard(snapshotOverride: TemplateSnapshot? = nil) {
        let dashboard = composeDashboard(snapshotOverride: snapshotOverride)
        Task {
            await repository.saveDashboard(dashboard)
        }
    }

    private func persistSnapshotOnly(_ snapshot: TemplateSnapshot) {
        self.snapshot = snapshot
        SharedDefaults.saveLatestSnapshot(snapshot)

        guard AppRuntime.allowsWidgetRefresh else { return }

        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }

    private func publish(_ event: MealEvent) async {
        try? await collaborationService.publish(event)
    }

    private func synchronizeSharedEvents(_ events: [MealEvent]) async -> [MealEvent] {
        await collaborationService.fetch(events: events)
    }

    private func makeSnapshot(for event: MealEvent, detail: String, sourceLabel: String) -> TemplateSnapshot {
        TemplateSnapshot(
            title: event.title,
            subtitle: event.votingSummary,
            detail: detail,
            metricTitle: "当前段位",
            metricValue: profile.currentRank.title,
            status: .ready,
            sourceLabel: sourceLabel,
            fetchedAt: Date(),
            isFallback: false,
            fallbackReason: nil
        )
    }

    private func makeEmptySnapshot(detail: String) -> TemplateSnapshot {
        TemplateSnapshot(
            title: AppConfig.localizedBrandName(),
            subtitle: "暂无约饭局",
            detail: detail,
            metricTitle: "当前段位",
            metricValue: profile.currentRank.title,
            status: .ready,
            sourceLabel: "本地更新",
            fetchedAt: Date(),
            isFallback: false,
            fallbackReason: nil
        )
    }

    private func cuisineEmoji(for cuisine: String) -> String {
        if cuisine.contains("火锅") { return "🍲" }
        if cuisine.contains("咖啡") { return "☕️" }
        if cuisine.contains("日") { return "🍣" }
        if cuisine.contains("Brunch") { return "🥗" }
        return "🍽️"
    }

    private func seededParticipants() -> [Participant] {
        let sampleParticipants = SampleData.dashboard().events.first?.participants ?? []
        let currentUser = Participant(
            id: profile.deviceId,
            nickname: profile.nickname,
            avatarEmoji: "🍜",
            hasVotedTime: true,
            hasVotedRestaurant: true,
            attended: nil,
            rank: profile.currentRank,
            attendanceRate: profile.attendanceRate,
            currentLocation: nil,
            isLocationSharingEnabled: false,
            lastLocationUpdate: nil
        )

        let peers = sampleParticipants
            .filter { $0.nickname != profile.nickname }
            .prefix(3)

        return [currentUser] + peers
    }

    private func updateCurrentParticipant(in event: inout MealEvent, _ mutate: (inout Participant) -> Void) {
        if let participantIndex = currentParticipantIndex(in: event) {
            mutate(&event.participants[participantIndex])
            event.participants[participantIndex].rank = profile.currentRank
            event.participants[participantIndex].attendanceRate = profile.attendanceRate
        }
    }

    private func updatedLeaderboard() -> [LeaderboardEntry] {
        var current = leaderboard.filter { $0.nickname != profile.nickname }
        current.insert(
            LeaderboardEntry(
                id: profile.deviceId,
                nickname: profile.nickname,
                rank: profile.currentRank,
                attendanceRate: profile.attendanceRate,
                currentStreak: profile.currentStreak
            ),
            at: 0
        )
        return current.sorted { lhs, rhs in
            if lhs.attendanceRate == rhs.attendanceRate {
                return lhs.currentStreak > rhs.currentStreak
            }
            return lhs.attendanceRate > rhs.attendanceRate
        }
    }

    private func currentParticipantIndex(in event: MealEvent) -> Int? {
        event.participants.firstIndex {
            $0.id == profile.deviceId || $0.nickname == profile.nickname || $0.nickname == event.creatorName
        }
    }

    private func updateProfileAttendance(eventID: UUID, attended: Bool) {
        profile.records.append(
            AttendanceRecord(
                id: UUID(),
                eventID: eventID,
                attended: attended,
                date: Date()
            )
        )

        profile.totalInvited = profile.records.count
        profile.totalAttended = profile.records.filter(\.attended).count
        profile.currentStreak = trailingAttendanceStreak(in: profile.records)
        profile.longestStreak = longestAttendanceStreak(in: profile.records)
        profile.currentRank = calculateRank(from: profile.records, currentRank: profile.currentRank)
        profile.lastUpdated = Date()
    }

    private func calculateRank(from records: [AttendanceRecord], currentRank: AttendanceRank) -> AttendanceRank {
        guard records.count >= 3 else { return .newcomer }

        let sortedRecords = records.sorted { $0.date < $1.date }
        let recent = Array(sortedRecords.suffix(6))
        let older = Array(sortedRecords.dropLast(min(6, sortedRecords.count)))
        let recentWeight = Double(recent.count) * 1.5
        let olderWeight = Double(older.count)
        let attendedScore = (Double(recent.filter(\.attended).count) * 1.5) + Double(older.filter(\.attended).count)
        let weightedRate = attendedScore / max(recentWeight + olderWeight, 1)

        if sortedRecords.suffix(2).allSatisfy({ !$0.attended }) {
            return AttendanceRank(rawValue: max(AttendanceRank.bronze.rawValue, currentRank.rawValue - 1)) ?? .bronze
        }

        if sortedRecords.suffix(5).count == 5, sortedRecords.suffix(5).allSatisfy(\.attended) {
            return AttendanceRank(rawValue: min(AttendanceRank.legend.rawValue, currentRank.rawValue + 1)) ?? .legend
        }

        switch weightedRate {
        case 0.99...1.0 where sortedRecords.count >= 20:
            return .legend
        case 0.93...0.98:
            return .diamond
        case 0.85...0.92:
            return .platinum
        case 0.75...0.84:
            return .gold
        case 0.60...0.74:
            return .silver
        default:
            return .bronze
        }
    }

    private func trailingAttendanceStreak(in records: [AttendanceRecord]) -> Int {
        records
            .sorted { $0.date < $1.date }
            .reversed()
            .prefix { $0.attended }
            .count
    }

    private func longestAttendanceStreak(in records: [AttendanceRecord]) -> Int {
        var best = 0
        var current = 0

        for record in records.sorted(by: { $0.date < $1.date }) {
            if record.attended {
                current += 1
                best = max(best, current)
            } else {
                current = 0
            }
        }

        return best
    }
}
