import Foundation

enum AppRuntime {
    private static let uiTestingArgument = "-ui-testing"
    private static let unlockedProductsKey = "NATIVE_TEMPLATE_UI_TEST_UNLOCKED_PRODUCTS"
    private static let nativeBootstrapEnvironmentKey = "DINERANK_ENABLE_NATIVE_BOOTSTRAP"
    private static let dashboardPayloadKey = "dinerank.dashboard.payload"

    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains(uiTestingArgument)
    }

    static var isSimulator: Bool {
#if targetEnvironment(simulator)
        true
#else
        false
#endif
    }

    static var supportsBackgroundRefreshRegistration: Bool {
        !isUITesting && !isSimulator
    }

    static var allowsNativeBootstrapOnLaunch: Bool {
        ProcessInfo.processInfo.environment[nativeBootstrapEnvironmentKey] == "1"
    }

    static var allowsWidgetRefresh: Bool {
        allowsNativeBootstrapOnLaunch
    }

    static func prepareForUITesting() {
        guard isUITesting else { return }

        SharedDefaults.store.removeObject(forKey: SharedDefaults.settingsKey)
        SharedDefaults.store.removeObject(forKey: SharedDefaults.entitlementKey)
        SharedDefaults.store.removeObject(forKey: SharedDefaults.backgroundRefreshStatusKey)
        SharedDefaults.store.removeObject(forKey: SharedDefaults.latestSnapshotKey)
        SharedDefaults.store.removeObject(forKey: SharedDefaults.profileDeviceIDKey)
        SharedDefaults.store.removeObject(forKey: SharedDefaults.complianceNoticeAcknowledgedKey)
        SharedDefaults.store.removeObject(forKey: dashboardPayloadKey)

        SharedDefaults.saveSettings(AppSettings())
        SharedDefaults.saveLatestSnapshot(SampleData.snapshot)
        SharedDefaults.saveComplianceNoticeAcknowledged(true)

        let rawValue = ProcessInfo.processInfo.environment[unlockedProductsKey] ?? "none"
        SharedDefaults.saveStoreEntitlement(
            StoreEntitlementSnapshot(
                unlockedProductIDs: parseUnlockedProducts(from: rawValue),
                updatedAt: Date()
            )
        )
    }

    private static func parseUnlockedProducts(from rawValue: String) -> [String] {
        let normalized = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if normalized.isEmpty || normalized.lowercased() == "none" {
            return []
        }

        return normalized
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .compactMap { token in
                TemplateProduct.allCases.first { $0.rawValue.lowercased() == token }
                    ?? {
                        switch token {
                        case "pro", "one-time", "nonconsumable":
                            .lifetime
                        case "monthly":
                            .monthly
                        case "yearly":
                            .yearly
                        case "lifetime":
                            .lifetime
                        default:
                            nil
                        }
                    }()
            }
            .map(\.rawValue)
    }
}
