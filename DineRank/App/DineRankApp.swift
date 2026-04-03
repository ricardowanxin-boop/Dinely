import BackgroundTasks
import SwiftUI
import UIKit

@main
struct DineRankApp: App {
    @StateObject private var settingsStore: AppSettingsStore
    @StateObject private var storeEntitlementStore: StoreEntitlementStore
    @StateObject private var liveActivityManager: LiveActivityManager
    @StateObject private var viewModel: HomeViewModel

    init() {
        AppRuntime.prepareForUITesting()
        Self.configureAppearance()
        if AppRuntime.allowsNativeBootstrapOnLaunch {
            NotificationManager.shared.configureForegroundPresentation()
        }

        let settingsStore = AppSettingsStore()
        let storeEntitlementStore = StoreEntitlementStore()
        let liveActivityManager = LiveActivityManager()

        _settingsStore = StateObject(wrappedValue: settingsStore)
        _storeEntitlementStore = StateObject(wrappedValue: storeEntitlementStore)
        _liveActivityManager = StateObject(wrappedValue: liveActivityManager)
        _viewModel = StateObject(wrappedValue: HomeViewModel())
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                viewModel: viewModel,
                settingsStore: settingsStore,
                storeEntitlementStore: storeEntitlementStore,
                liveActivityManager: liveActivityManager
            )
            .preferredColorScheme(settingsStore.settings.appearance.colorScheme)
        }
    }

    private static func configureAppearance() {
        let accent = UIColor(AppTheme.copper)
        let background = UIColor(AppTheme.surface)
        let border = UIColor(AppTheme.divider)
        let textPrimary = UIColor(AppTheme.textPrimary)
        let textSecondary = UIColor(AppTheme.textSecondary)

        let navigation = UINavigationBarAppearance()
        navigation.configureWithOpaqueBackground()
        navigation.backgroundColor = background
        navigation.shadowColor = border
        navigation.titleTextAttributes = [.foregroundColor: textPrimary]
        navigation.largeTitleTextAttributes = [.foregroundColor: textPrimary]
        UINavigationBar.appearance().standardAppearance = navigation
        UINavigationBar.appearance().scrollEdgeAppearance = navigation
        UINavigationBar.appearance().compactAppearance = navigation

        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = background
        tab.shadowColor = border
        for layout in [tab.stackedLayoutAppearance, tab.inlineLayoutAppearance, tab.compactInlineLayoutAppearance] {
            layout.selected.iconColor = accent
            layout.selected.titleTextAttributes = [.foregroundColor: accent]
            layout.normal.iconColor = textSecondary
            layout.normal.titleTextAttributes = [.foregroundColor: textSecondary]
        }
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab

        UISegmentedControl.appearance().selectedSegmentTintColor = accent.withAlphaComponent(0.16)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: textPrimary], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: textSecondary], for: .normal)
    }
}
