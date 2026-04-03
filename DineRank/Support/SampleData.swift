import Foundation

enum SampleData {
    static let componentSamples: [TemplateComponentSample] = [
        .init(title: "首页事件卡", value: "361 × 140", detail: "状态条、emoji、时间投票进度与参会人数"),
        .init(title: "地图选餐厅", value: "361 × 300", detail: "搜索、地图标点、候选餐厅列表一体化"),
        .init(title: "守约战报卡", value: "361 × 280", detail: "聚餐后可分享的增长卡片"),
        .init(title: "段位 Hero", value: "393 × 400", detail: "当前段位、守约率、连续守约和分享入口")
    ]

    static let capabilities: [TemplateCapability] = [
        .init(title: "CloudKit 协作", subtitle: "零后端 MVP", systemImage: "icloud", detail: "约饭局、投票和位置共享统一走 CloudKit Public DB。"),
        .init(title: "MapKit 地图", subtitle: "餐厅选点 + 到店地图", systemImage: "map", detail: "创建时选候选餐厅，约饭当天看距离与位置。"),
        .init(title: "StoreKit 2", subtitle: "Pro 解锁", systemImage: "creditcard", detail: "支持 20 人上限、圈子排行榜、扩展分享卡。"),
        .init(title: "Widget / Live Activity", subtitle: "动态状态追踪", systemImage: "pill", detail: "用共享快照给首页、锁屏和灵动岛做状态提示。")
    ]

    static var snapshot: TemplateSnapshot {
        let dashboard = dashboard()
        return dashboard.latestSnapshot
    }

    static func manualSnapshot() -> TemplateSnapshot {
        let dashboard = dashboard()
        return TemplateSnapshot(
            title: dashboard.events.first?.title ?? "本地约饭局",
            subtitle: "刚刚创建了一场新的约饭局",
            detail: "分享链接已经准备好，可以直接发到微信群邀请朋友参与投票。",
            metricTitle: "当前段位",
            metricValue: dashboard.profile.currentRank.title,
            status: .ready,
            sourceLabel: "本地创建",
            fetchedAt: Date(),
            isFallback: false,
            fallbackReason: nil
        )
    }

    static func dashboard() -> DineRankDashboard {
        let participants = sampleParticipants()
        let restaurants = sampleRestaurants()
        let events = sampleEvents(participants: participants, restaurants: restaurants)
        let profile = sampleProfile()
        let report = sampleBattleReport(event: events[2])
        let snapshot = TemplateSnapshot(
            title: events[0].title,
            subtitle: events[0].votingSummary,
            detail: "最新动态：地图选餐厅已开启，大家正在同步时间与餐厅投票。",
            metricTitle: "当前段位",
            metricValue: profile.currentRank.title,
            status: .ready,
            sourceLabel: "本地样例",
            fetchedAt: Date(),
            isFallback: false,
            fallbackReason: nil
        )

        let leaderboard = [
            LeaderboardEntry(id: UUID(), nickname: "Rico", rank: .gold, attendanceRate: 0.96, currentStreak: 12),
            LeaderboardEntry(id: UUID(), nickname: "Mina", rank: .gold, attendanceRate: 0.92, currentStreak: 8),
            LeaderboardEntry(id: UUID(), nickname: "Leo", rank: .silver, attendanceRate: 0.88, currentStreak: 4),
            LeaderboardEntry(id: UUID(), nickname: "Ava", rank: .bronze, attendanceRate: 0.84, currentStreak: 3)
        ]

        return DineRankDashboard(
            heroTitle: "地图投票已上线",
            heroSubtitle: "火锅 / 烧鸟 / Brunch 现在可以直接在地图上选候选餐厅。",
            events: events,
            profile: profile,
            leaderboard: leaderboard,
            battleReport: report,
            latestSnapshot: snapshot
        )
    }

    static func defaultDraft() -> CreateEventDraft {
        return CreateEventDraft(
            title: "周末新店踩点",
            cuisine: "日料",
            budgetPerPerson: 120,
            candidateTimes: [
                CreateTimeDraft(id: UUID(), startDate: nextDate(weekday: 6, hour: 19, minute: 30), endDate: nextDate(weekday: 6, hour: 21, minute: 0), period: "晚餐"),
                CreateTimeDraft(id: UUID(), startDate: nextDate(weekday: 1, hour: 11, minute: 30), endDate: nextDate(weekday: 1, hour: 13, minute: 0), period: "Brunch")
            ],
            candidateRestaurants: [],
            maxParticipants: AppConfig.maximumFreeParticipants
        )
    }

    private static func sampleParticipants() -> [Participant] {
        [
            Participant(id: UUID(), nickname: "Rico", avatarEmoji: "🍜", hasVotedTime: true, hasVotedRestaurant: true, attended: true, rank: .gold, attendanceRate: 0.96, currentLocation: LocationPoint(latitude: 31.2296, longitude: 121.4732, timestamp: Date()), isLocationSharingEnabled: true, lastLocationUpdate: Date()),
            Participant(id: UUID(), nickname: "Mina", avatarEmoji: "🥟", hasVotedTime: true, hasVotedRestaurant: true, attended: true, rank: .gold, attendanceRate: 0.92, currentLocation: LocationPoint(latitude: 31.2307, longitude: 121.4750, timestamp: Date()), isLocationSharingEnabled: true, lastLocationUpdate: Date()),
            Participant(id: UUID(), nickname: "Leo", avatarEmoji: "🍣", hasVotedTime: false, hasVotedRestaurant: true, attended: false, rank: .silver, attendanceRate: 0.88, currentLocation: LocationPoint(latitude: 31.2285, longitude: 121.4766, timestamp: Date()), isLocationSharingEnabled: true, lastLocationUpdate: Date()),
            Participant(id: UUID(), nickname: "Ava", avatarEmoji: "🍰", hasVotedTime: false, hasVotedRestaurant: false, attended: true, rank: .bronze, attendanceRate: 0.84, currentLocation: nil, isLocationSharingEnabled: false, lastLocationUpdate: nil),
            Participant(id: UUID(), nickname: "Noah", avatarEmoji: "☕️", hasVotedTime: false, hasVotedRestaurant: false, attended: nil, rank: .newcomer, attendanceRate: 0.79, currentLocation: nil, isLocationSharingEnabled: false, lastLocationUpdate: nil)
        ]
    }

    private static func sampleRestaurants() -> [Restaurant] {
        [
            Restaurant(id: UUID(), name: "山风居酒屋", address: "静安区愚园路 98 号", latitude: 31.2302, longitude: 121.4728, cuisine: "日料", pricePerPerson: 120, votes: [], poiId: "shanfeng-001"),
            Restaurant(id: UUID(), name: "海底捞", address: "静安大悦城 7F", latitude: 31.2290, longitude: 121.4768, cuisine: "火锅", pricePerPerson: 95, votes: [], poiId: "haidilao-001"),
            Restaurant(id: UUID(), name: "MORI Cafe", address: "巨鹿路 518 号", latitude: 31.2318, longitude: 121.4781, cuisine: "咖啡", pricePerPerson: 78, votes: [], poiId: "mori-001")
        ]
    }

    private static func sampleEvents(participants: [Participant], restaurants: [Restaurant]) -> [MealEvent] {
        let fridayStart = nextDate(weekday: 6, hour: 19, minute: 30)
        let fridayEnd = nextDate(weekday: 6, hour: 21, minute: 0)
        let sundayStart = nextDate(weekday: 1, hour: 11, minute: 30)
        let sundayEnd = nextDate(weekday: 1, hour: 13, minute: 0)
        let wednesdayStart = nextDate(weekday: 4, hour: 20, minute: 0)
        let wednesdayEnd = nextDate(weekday: 4, hour: 21, minute: 30)

        let fridayTime = TimeSlot(id: UUID(), startDate: fridayStart, endDate: fridayEnd, period: "晚餐", votes: [participants[0].id, participants[1].id, participants[2].id])
        let sundayTime = TimeSlot(id: UUID(), startDate: sundayStart, endDate: sundayEnd, period: "Brunch", votes: [participants[0].id, participants[3].id])
        let wednesdayTime = TimeSlot(id: UUID(), startDate: wednesdayStart, endDate: wednesdayEnd, period: "晚餐", votes: [participants[0].id])

        var firstRestaurants = restaurants
        firstRestaurants[0].votes = [participants[0].id, participants[1].id]
        firstRestaurants[1].votes = [participants[2].id]

        var secondParticipants = Array(participants.prefix(4))
        secondParticipants.indices.forEach { secondParticipants[$0].hasVotedTime = true }

        let votingEvent = MealEvent(
            id: UUID(),
            title: "周五火锅回血局",
            categoryEmoji: "🍲",
            creatorDeviceId: "local-creator",
            creatorName: "Rico",
            cuisine: "火锅",
            budgetPerPerson: 120,
            candidateTimes: [fridayTime, sundayTime],
            candidateRestaurants: Array(firstRestaurants.prefix(2)),
            participants: participants,
            status: .voting,
            confirmedTime: nil,
            confirmedRestaurant: nil,
            totalBill: nil,
            maxParticipants: AppConfig.maximumFreeParticipants,
            updatedAt: Date()
        )

        let confirmedEvent = MealEvent(
            id: UUID(),
            title: "周日早午餐局",
            categoryEmoji: "🥗",
            creatorDeviceId: "local-creator",
            creatorName: "Mina",
            cuisine: "Brunch",
            budgetPerPerson: 88,
            candidateTimes: [sundayTime],
            candidateRestaurants: [restaurants[2]],
            participants: secondParticipants,
            status: .confirmed,
            confirmedTime: sundayTime,
            confirmedRestaurant: restaurants[2],
            totalBill: nil,
            maxParticipants: AppConfig.maximumFreeParticipants,
            updatedAt: Date().addingTimeInterval(-900)
        )

        let completedEvent = MealEvent(
            id: UUID(),
            title: "周三临时加班局",
            categoryEmoji: "🍱",
            creatorDeviceId: "local-creator",
            creatorName: "Leo",
            cuisine: "便当",
            budgetPerPerson: 125,
            candidateTimes: [wednesdayTime],
            candidateRestaurants: [restaurants[0]],
            participants: participants,
            status: .completed,
            confirmedTime: wednesdayTime,
            confirmedRestaurant: restaurants[0],
            totalBill: 502,
            maxParticipants: AppConfig.maximumFreeParticipants,
            updatedAt: Date().addingTimeInterval(-3600)
        )

        return [votingEvent, confirmedEvent, completedEvent]
    }

    private static func sampleProfile() -> AttendanceProfile {
        let deviceID = SharedDefaults.loadOrCreateProfileDeviceID()
        let records = sampleAttendanceRecords()
        return AttendanceProfile(
            deviceId: deviceID,
            nickname: "Rico",
            totalAttended: 48,
            totalInvited: 52,
            currentStreak: 12,
            longestStreak: 16,
            currentRank: .gold,
            lastUpdated: Date(),
            records: records
        )
    }

    private static func sampleBattleReport(event: MealEvent) -> BattleReport {
        BattleReport(
            id: UUID(),
            eventTitle: event.title,
            date: event.confirmedTime?.startDate ?? Date(),
            invitedCount: event.maxParticipants,
            attendedCount: 5,
            averageSpend: 125.5,
            heroNames: ["Rico", "Mina", "Leo"],
            noShowNames: ["Ava", "Noah"]
        )
    }

    private static func nextDate(weekday: Int, hour: Int, minute: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "zh_CN")
        let now = Date()
        var components = DateComponents()
        components.weekday = weekday
        components.hour = hour
        components.minute = minute
        let next = calendar.nextDate(after: now, matching: components, matchingPolicy: .nextTimePreservingSmallerComponents)
        return next ?? now
    }

    private static func sampleAttendanceRecords() -> [AttendanceRecord] {
        (0..<12).map { index in
            AttendanceRecord(
                id: UUID(),
                eventID: UUID(),
                attended: ![2, 7].contains(index),
                date: Calendar.current.date(byAdding: .day, value: -(12 - index), to: Date()) ?? Date()
            )
        }
    }
}
