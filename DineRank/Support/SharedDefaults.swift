import Foundation

enum SharedDefaults {
    static let appGroupID = AppConfig.appGroupID
    static let settingsKey = "dinerank.settings"
    static let entitlementKey = "dinerank.entitlement"
    static let backgroundRefreshStatusKey = "dinerank.backgroundRefreshStatus"
    static let latestSnapshotKey = "dinerank.latestSnapshot"
    static let profileDeviceIDKey = "dinerank.profile.device-id"
    static let complianceNoticeAcknowledgedKey = "dinerank.complianceNoticeAcknowledged"
    private static let nativeBootstrapEnvironmentKey = "DINERANK_ENABLE_NATIVE_BOOTSTRAP"

    static var store: UserDefaults {
        guard shouldUseAppGroupStore else { return .standard }
        return UserDefaults(suiteName: appGroupID) ?? .standard
    }

    private static var shouldUseAppGroupStore: Bool {
        if Bundle.main.bundleURL.pathExtension == "appex" {
            return true
        }

        return ProcessInfo.processInfo.environment[nativeBootstrapEnvironmentKey] == "1"
    }

    static func loadSettings() -> AppSettings {
        guard
            let data = store.data(forKey: settingsKey),
            let decoded = try? JSONDecoder().decode(AppSettings.self, from: data)
        else {
            return AppSettings()
        }
        return decoded
    }

    static func saveSettings(_ settings: AppSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        store.set(data, forKey: settingsKey)
    }

    static func loadStoreEntitlement() -> StoreEntitlementSnapshot {
        guard
            let data = store.data(forKey: entitlementKey),
            let decoded = try? JSONDecoder().decode(StoreEntitlementSnapshot.self, from: data)
        else {
            return StoreEntitlementSnapshot()
        }
        return decoded
    }

    static func saveStoreEntitlement(_ snapshot: StoreEntitlementSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        store.set(data, forKey: entitlementKey)
    }

    static func loadBackgroundRefreshStatus() -> BackgroundRefreshStatus {
        guard
            let data = store.data(forKey: backgroundRefreshStatusKey),
            let decoded = try? JSONDecoder().decode(BackgroundRefreshStatus.self, from: data)
        else {
            return BackgroundRefreshStatus()
        }
        return decoded
    }

    static func saveBackgroundRefreshStatus(_ status: BackgroundRefreshStatus) {
        guard let data = try? JSONEncoder().encode(status) else { return }
        store.set(data, forKey: backgroundRefreshStatusKey)
    }

    static func loadLatestSnapshot() -> TemplateSnapshot? {
        guard
            let data = store.data(forKey: latestSnapshotKey),
            let decoded = try? JSONDecoder().decode(TemplateSnapshot.self, from: data)
        else {
            return nil
        }
        return decoded
    }

    static func saveLatestSnapshot(_ snapshot: TemplateSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        store.set(data, forKey: latestSnapshotKey)
    }

    static func loadOrCreateProfileDeviceID() -> UUID {
        let isUITesting = ProcessInfo.processInfo.arguments.contains("-ui-testing")

        if isUITesting, let fixed = UUID(uuidString: "11111111-1111-1111-1111-111111111111") {
            store.set(fixed.uuidString, forKey: profileDeviceIDKey)
            return fixed
        }

        if
            let rawValue = store.string(forKey: profileDeviceIDKey),
            let identifier = UUID(uuidString: rawValue)
        {
            return identifier
        }

        let identifier = UUID()
        store.set(identifier.uuidString, forKey: profileDeviceIDKey)
        return identifier
    }

    static func loadComplianceNoticeAcknowledged() -> Bool {
        store.bool(forKey: complianceNoticeAcknowledgedKey)
    }

    static func saveComplianceNoticeAcknowledged(_ acknowledged: Bool) {
        store.set(acknowledged, forKey: complianceNoticeAcknowledgedKey)
    }
}
