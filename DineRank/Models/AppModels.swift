import CoreLocation
import Foundation
import SwiftUI

enum AppAppearance: String, CaseIterable, Codable, Identifiable, Sendable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system:
            L10n.string("跟随系统")
        case .light:
            L10n.string("浅色")
        case .dark:
            L10n.string("深色")
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            nil
        case .light:
            .light
        case .dark:
            .dark
        }
    }
}

struct AppSettings: Codable, Equatable, Sendable {
    var appearance: AppAppearance = .system
    var liveActivitiesEnabled = true
    var backgroundRefreshEnabled = true
    var showBackgroundRefreshNotifications = false
}

enum SnapshotStatus: String, Codable, CaseIterable, Sendable {
    case ready
    case syncing
    case fallback

    var title: String {
        switch self {
        case .ready:
            L10n.string("正常")
        case .syncing:
            L10n.string("同步中")
        case .fallback:
            L10n.string("回退数据")
        }
    }
}

struct TemplateSnapshot: Codable, Equatable, Sendable {
    var title: String
    var subtitle: String
    var detail: String
    var metricTitle: String
    var metricValue: String
    var status: SnapshotStatus
    var sourceLabel: String
    var fetchedAt: Date
    var isFallback: Bool
    var fallbackReason: String?

    func markedAsFallback(reason: String) -> TemplateSnapshot {
        var copy = self
        copy.status = .fallback
        copy.isFallback = true
        copy.fallbackReason = reason
        return copy
    }
}

struct TemplateCapability: Identifiable, Hashable, Sendable {
    var id: String { title }
    let title: String
    let subtitle: String
    let systemImage: String
    let detail: String
}

struct TemplateComponentSample: Identifiable, Hashable, Sendable {
    var id: String { title }
    let title: String
    let value: String
    let detail: String
}

enum TemplateProduct: String, CaseIterable, Codable, Identifiable, Sendable {
    case monthly = "com.ricardo.dinerank.pro.monthly"
    case yearly = "com.ricardo.dinerank.pro.yearly"
    case lifetime = "com.ricardo.dinerank.pro.lifetime"

    static let publiclyOfferedProducts: [TemplateProduct] = [.lifetime]

    static var futureProducts: [TemplateProduct] {
        allCases.filter { !publiclyOfferedProducts.contains($0) }
    }

    var id: String { rawValue }

    var title: String {
        switch self {
        case .monthly:
            "Pro 月度"
        case .yearly:
            "Pro 年度"
        case .lifetime:
            "DineRank Pro"
        }
    }

    var subtitle: String {
        switch self {
        case .monthly:
            "解锁 20 人约饭局、圈子榜单和扩展分享样式"
        case .yearly:
            "适合长期组织饭局的高频用户"
        case .lifetime:
            "一次购买，永久解锁当前 Pro 权益"
        }
    }

    var entitlementPriority: Int {
        switch self {
        case .monthly:
            0
        case .yearly:
            1
        case .lifetime:
            2
        }
    }
}

enum ProFeature: String, CaseIterable, Identifiable, Sendable {
    case largerParties
    case circleLeaderboard
    case premiumThemes
    case advancedShareCards

    var id: String { rawValue }

    var title: String {
        switch self {
        case .largerParties:
            "20 人约饭局"
        case .circleLeaderboard:
            "圈子排行榜"
        case .premiumThemes:
            "高级主题"
        case .advancedShareCards:
            "扩展战报卡"
        }
    }

    var detail: String {
        switch self {
        case .largerParties:
            "免费版最多 8 人，Pro 支持扩展到 20 人。"
        case .circleLeaderboard:
            "查看熟人圈的守约榜单和连续上榜情况。"
        case .premiumThemes:
            "解锁节日主题与更丰富的卡片视觉风格。"
        case .advancedShareCards:
            "解锁更多战报分享版式和导出尺寸。"
        }
    }
}

struct StoreEntitlementSnapshot: Codable, Equatable, Sendable {
    var unlockedProductIDs: [String] = []
    var updatedAt: Date = Date()

    var hasProAccess: Bool {
        !unlockedProductIDs.isEmpty
    }

    var activeProducts: [TemplateProduct] {
        unlockedProductIDs
            .compactMap(TemplateProduct.init(rawValue:))
            .sorted { lhs, rhs in
                lhs.entitlementPriority > rhs.entitlementPriority
            }
    }

    var currentProduct: TemplateProduct? {
        activeProducts.first
    }

    func canUse(_ feature: ProFeature) -> Bool {
        hasProAccess
    }
}

enum BackgroundRefreshOutcome: String, Codable, Sendable {
    case idle
    case scheduled
    case running
    case success
    case disabled
    case failed

    var title: String {
        switch self {
        case .idle:
            L10n.string("空闲")
        case .scheduled:
            L10n.string("已登记")
        case .running:
            L10n.string("运行中")
        case .success:
            L10n.string("成功")
        case .disabled:
            L10n.string("已关闭")
        case .failed:
            L10n.string("失败")
        }
    }
}

struct BackgroundRefreshStatus: Codable, Equatable, Sendable {
    var lastScheduledAt: Date?
    var lastAttemptAt: Date?
    var lastSuccessAt: Date?
    var lastErrorMessage: String?
    var outcome: BackgroundRefreshOutcome = .idle
}

enum EventStatus: String, Codable, CaseIterable, Sendable {
    case voting
    case confirmed
    case completed

    var title: String {
        switch self {
        case .voting:
            "投票中"
        case .confirmed:
            "已确定"
        case .completed:
            "已结束"
        }
    }

    var accentColor: Color {
        switch self {
        case .voting:
            Color(red: 1.0, green: 0.78, blue: 0.21)
        case .confirmed:
            Color(red: 0.15, green: 0.74, blue: 0.46)
        case .completed:
            Color(red: 0.47, green: 0.54, blue: 0.64)
        }
    }
}

struct LocationPoint: Codable, Hashable, Sendable {
    var latitude: Double
    var longitude: Double
    var timestamp: Date

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct TimeSlot: Identifiable, Codable, Hashable, Sendable {
    var id: UUID
    var startDate: Date
    var endDate: Date
    var period: String
    var votes: [UUID]

    var voteCount: Int { votes.count }
    var titleText: String { DisplayFormatters.day(startDate) }
    var rangeText: String { DisplayFormatters.timeRange(start: startDate, end: endDate) }
}

struct Restaurant: Identifiable, Codable, Hashable, Sendable {
    var id: UUID
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var cuisine: String
    var pricePerPerson: Int
    var votes: [UUID]
    var poiId: String?

    var voteCount: Int { votes.count }
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var selectionKey: String {
        if let poiId, !poiId.isEmpty {
            return poiId.lowercased()
        }

        return [
            name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            address.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            String(format: "%.6f", latitude),
            String(format: "%.6f", longitude)
        ]
        .joined(separator: "|")
    }

    var subtitle: String {
        "\(cuisine) · ¥\(pricePerPerson)/人"
    }
}

enum AttendanceRank: Int, Codable, CaseIterable, Comparable, Sendable {
    case newcomer = 0
    case bronze = 1
    case silver = 2
    case gold = 3
    case platinum = 4
    case diamond = 5
    case legend = 6

    static func < (lhs: AttendanceRank, rhs: AttendanceRank) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var title: String {
        switch self {
        case .newcomer:
            "新人"
        case .bronze:
            "青铜"
        case .silver:
            "白银"
        case .gold:
            "黄金"
        case .platinum:
            "铂金"
        case .diamond:
            "钻石"
        case .legend:
            "传奇"
        }
    }

    var emoji: String {
        switch self {
        case .newcomer:
            "🌱"
        case .bronze:
            "🥉"
        case .silver:
            "🪙"
        case .gold:
            "🥇"
        case .platinum:
            "💠"
        case .diamond:
            "💎"
        case .legend:
            "👑"
        }
    }

    var accentColor: Color {
        switch self {
        case .newcomer:
            Color(red: 0.73, green: 0.75, blue: 0.79)
        case .bronze:
            Color(red: 0.81, green: 0.57, blue: 0.32)
        case .silver:
            Color(red: 0.68, green: 0.74, blue: 0.81)
        case .gold:
            Color(red: 1.0, green: 0.78, blue: 0.21)
        case .platinum:
            Color(red: 0.42, green: 0.81, blue: 0.78)
        case .diamond:
            Color(red: 0.34, green: 0.64, blue: 1.0)
        case .legend:
            Color(red: 0.67, green: 0.44, blue: 0.98)
        }
    }
}

struct Participant: Identifiable, Codable, Hashable, Sendable {
    var id: UUID
    var nickname: String
    var avatarEmoji: String
    var hasVotedTime: Bool
    var hasVotedRestaurant: Bool
    var attended: Bool?
    var rank: AttendanceRank
    var attendanceRate: Double?
    var currentLocation: LocationPoint?
    var isLocationSharingEnabled: Bool
    var lastLocationUpdate: Date?

    var attendanceRateText: String {
        guard let attendanceRate else { return "待统计" }
        return "守约率 \(DisplayFormatters.percentage(attendanceRate))"
    }
}

struct AttendanceRecord: Identifiable, Codable, Hashable, Sendable {
    var id: UUID
    var eventID: UUID
    var attended: Bool
    var date: Date
}

struct MealEvent: Identifiable, Codable, Hashable, Sendable {
    var id: UUID
    var title: String
    var categoryEmoji: String
    var creatorDeviceId: String
    var creatorName: String
    var cuisine: String
    var budgetPerPerson: Int
    var candidateTimes: [TimeSlot]
    var candidateRestaurants: [Restaurant]
    var participants: [Participant]
    var status: EventStatus
    var confirmedTime: TimeSlot?
    var confirmedRestaurant: Restaurant?
    var totalBill: Double?
    var maxParticipants: Int
    var updatedAt: Date = Date()

    var progress: Double {
        guard !participants.isEmpty else { return 0 }
        let totalVotes = candidateTimes.reduce(0) { $0 + $1.voteCount }
        let maxVotes = max(candidateTimes.count * participants.count, 1)
        return min(Double(totalVotes) / Double(maxVotes), 1)
    }

    var participantSummary: String {
        "\(participants.count)/\(maxParticipants)人"
    }

    var votingSummary: String {
        switch status {
        case .voting:
            return "\(candidateTimes.count)个候选时间 · \(candidateRestaurants.count)家候选餐厅"
        case .confirmed:
            if let confirmedRestaurant {
                return "已定在 \(confirmedRestaurant.name)"
            }
            return "等待赴约"
        case .completed:
            return "已完成 AA 与战报"
        }
    }
}

struct AttendanceProfile: Codable, Equatable, Sendable {
    var deviceId: UUID
    var nickname: String
    var totalAttended: Int
    var totalInvited: Int
    var currentStreak: Int
    var longestStreak: Int
    var currentRank: AttendanceRank
    var lastUpdated: Date
    var records: [AttendanceRecord] = []

    var attendanceRate: Double {
        if !records.isEmpty {
            let attendedCount = records.filter(\.attended).count
            return Double(attendedCount) / Double(records.count)
        }
        guard totalInvited > 0 else { return 0 }
        return Double(totalAttended) / Double(totalInvited)
    }
}

struct LeaderboardEntry: Identifiable, Codable, Hashable, Sendable {
    var id: UUID
    var nickname: String
    var rank: AttendanceRank
    var attendanceRate: Double
    var currentStreak: Int
}

struct BattleReport: Identifiable, Codable, Hashable, Sendable {
    var id: UUID
    var eventTitle: String
    var date: Date
    var invitedCount: Int
    var attendedCount: Int
    var averageSpend: Double
    var heroNames: [String]
    var noShowNames: [String]

    var attendanceRate: Double {
        guard invitedCount > 0 else { return 0 }
        return Double(attendedCount) / Double(invitedCount)
    }
}

struct CreateTimeDraft: Identifiable, Hashable, Sendable {
    var id: UUID
    var startDate: Date
    var endDate: Date
    var period: String
}

struct CreateEventDraft: Equatable, Sendable {
    var title: String
    var cuisine: String
    var budgetPerPerson: Int
    var candidateTimes: [CreateTimeDraft]
    var candidateRestaurants: [Restaurant]
    var maxParticipants: Int
}

extension CreateEventDraft {
    init(event: MealEvent) {
        self.init(
            title: event.title,
            cuisine: event.cuisine,
            budgetPerPerson: event.budgetPerPerson,
            candidateTimes: event.candidateTimes.map {
                CreateTimeDraft(
                    id: $0.id,
                    startDate: $0.startDate,
                    endDate: $0.endDate,
                    period: $0.period
                )
            },
            candidateRestaurants: event.candidateRestaurants,
            maxParticipants: event.maxParticipants
        )
    }
}

struct DineRankDashboard: Codable, Sendable {
    var heroTitle: String
    var heroSubtitle: String
    var events: [MealEvent]
    var profile: AttendanceProfile
    var leaderboard: [LeaderboardEntry]
    var battleReport: BattleReport
    var latestSnapshot: TemplateSnapshot
}
