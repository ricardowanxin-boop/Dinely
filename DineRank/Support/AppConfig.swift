import Foundation

enum AppConfig {
    static let projectName = "食否"
    static let appDisplayName = "食否"
    static let bundleIdentifier = "com.ricardo.dinerank"
    static let developmentTeamID = "2HZLQ4V556"
    static let appGroupID = "group.com.ricardo.dinerank"
    static let cloudKitContainerIdentifier = "iCloud.com.ricardo.dinerank"
    static let backgroundRefreshTaskIdentifier = "com.ricardo.dinerank.refresh"
    static let mapProviderName = "Apple MapKit（中国大陆地图数据会显示高德署名）"
    static let customURLScheme = "dinerank"
    static let universalLinkHost = "dinerank.app"
    static let universalLinkHosts = ["dinerank.app", "www.dinerank.app"]
    static let associatedDomains = universalLinkHosts.map { "applinks:\($0)" }
    static let appleAppSiteAssociationAppID = "\(developmentTeamID).\(bundleIdentifier)"
    static let gaodeMapScheme = "iosamap"
    static let privacyPolicyPublicURL = URL(string: "https://dinerank.app/privacy")!
    static let supportPublicURL = URL(string: "https://dinerank.app/support")!
    static let standardEULAURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    static let supportEmail = "support@dinerank.app"

    static let apiBaseURL = URL(string: "https://api.dinerank.app")!
    static let demoEndpointPath = "v1/mvp/overview"
    static let requestTimeout: TimeInterval = 12
    static let apiDefaultHeaders = [
        "Accept": "application/json"
    ]

    static let maximumFreeParticipants = 8
    static let maximumProParticipants = 20
    static let maximumCandidateTimes = 3
    static let maximumCandidateRestaurants = 3
    static let locationRefreshInterval: TimeInterval = 5

    struct MarketName: Identifiable, Hashable, Sendable {
        let code: String
        let label: String
        let productName: String

        var id: String { code }
    }

    static let supportedMarketNames: [MarketName] = [
        .init(code: "CN", label: "中国大陆", productName: "食否"),
        .init(code: "HK", label: "中国香港", productName: "食否"),
        .init(code: "TW", label: "中国台湾", productName: "食否"),
        .init(code: "US", label: "美国", productName: "Dinely"),
        .init(code: "JP", label: "日本", productName: "Dinely"),
        .init(code: "SG", label: "新加坡", productName: "Dinely"),
        .init(code: "INTL", label: "其他英语地区", productName: "Dinely")
    ]

    static func localizedBrandName(locale: Locale = .current) -> String {
        let regionCode = locale.region?.identifier ?? "US"

        return switch regionCode {
        case "CN":
            "食否"
        case "HK", "TW", "MO":
            "食否"
        default:
            "Dinely"
        }
    }

    static func joinURL(for eventID: UUID) -> URL {
        URL(string: "\(customURLScheme)://join/\(eventID.uuidString)")!
    }

    static func universalJoinURL(for eventID: UUID) -> URL {
        URL(string: "https://\(universalLinkHost)/join/\(eventID.uuidString)")!
    }

    static func preferredShareURL(for eventID: UUID) -> URL {
        universalJoinURL(for: eventID)
    }

    static func sharedEventID(from url: URL) -> UUID? {
        if url.scheme == customURLScheme {
            guard url.host == "join" else { return nil }
            return UUID(uuidString: url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
        }

        guard
            universalLinkHosts.contains(url.host ?? ""),
            url.path.hasPrefix("/join/")
        else {
            return nil
        }

        let rawValue = url.path.replacingOccurrences(of: "/join/", with: "")
        return UUID(uuidString: rawValue)
    }
}
