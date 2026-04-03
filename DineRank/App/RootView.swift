import SwiftUI

struct RootView: View {
    private enum RootTab: Hashable {
        case home
        case rank
        case settings
    }

    private enum EventComposerRoute: Identifiable {
        case create
        case edit(MealEvent)

        var id: String {
            switch self {
            case .create:
                return "create"
            case .edit(let event):
                return "edit-\(event.id.uuidString)"
            }
        }

        var editingEvent: MealEvent? {
            switch self {
            case .create:
                return nil
            case .edit(let event):
                return event
            }
        }
    }

    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab: RootTab = .home
    @State private var hasLoadedInitialContent = false
    @State private var eventComposerRoute: EventComposerRoute?
    @State private var sharedEventToJoin: MealEvent?
    @State private var isPresentingMessage = false
    @State private var isShowingComplianceNotice = !SharedDefaults.loadComplianceNoticeAcknowledged()
    @State private var isRootChromeVisible = true

    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var settingsStore: AppSettingsStore
    @ObservedObject var storeEntitlementStore: StoreEntitlementStore
    @ObservedObject var liveActivityManager: LiveActivityManager

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeScreen(
                    viewModel: viewModel,
                    storeEntitlementStore: storeEntitlementStore,
                    onCreateEvent: {
                        eventComposerRoute = .create
                    }
                ) { event in
                    eventComposerRoute = .edit(event)
                }
            }
            .tag(RootTab.home)
            .tabItem {
                Label("约饭", systemImage: "fork.knife")
            }

            NavigationStack {
                RankScreen(
                    viewModel: viewModel,
                    storeEntitlementStore: storeEntitlementStore
                )
            }
            .tag(RootTab.rank)
            .tabItem {
                Label("我的段位", systemImage: "trophy")
            }

            NavigationStack {
                SettingsScreen(
                    settingsStore: settingsStore,
                    storeEntitlementStore: storeEntitlementStore,
                    viewModel: viewModel
                )
            }
            .tag(RootTab.settings)
            .tabItem {
                Label("设置", systemImage: "gearshape")
            }
        }
        .tint(AppTheme.copper)
        .toolbar(.hidden, for: .tabBar)
        .accessibilityIdentifier("root-tab-view")
        .sheet(item: $eventComposerRoute) { route in
            NavigationStack {
                CreateEventFlowScreen(
                    viewModel: viewModel,
                    storeEntitlementStore: storeEntitlementStore,
                    editingEvent: route.editingEvent
                )
            }
        }
        .sheet(item: $sharedEventToJoin) { event in
            NavigationStack {
                JoinSharedEventScreen(viewModel: viewModel, event: event) {
                    sharedEventToJoin = nil
                    selectedTab = .home
                }
            }
        }
        .sheet(isPresented: $isShowingComplianceNotice) {
            NavigationStack {
                ComplianceNoticeSheet {
                    SharedDefaults.saveComplianceNoticeAcknowledged(true)
                    isShowingComplianceNotice = false
                }
            }
            .interactiveDismissDisabled()
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if isRootChromeVisible {
                customTabBar
            }
        }
        .onPreferenceChange(RootChromeVisibilityPreferenceKey.self) { isRootChromeVisible = $0 }
        .task {
            await performInitialLoad()
        }
        .onOpenURL { url in
            Task {
                if let event = await viewModel.resolveSharedEvent(url: url) {
                    await MainActor.run {
                        sharedEventToJoin = event
                    }
                }
            }
        }
        .onChange(of: settingsStore.settings.liveActivitiesEnabled) { _, newValue in
            guard AppRuntime.allowsNativeBootstrapOnLaunch else { return }
            Task {
                await liveActivityManager.sync(snapshot: viewModel.snapshot, isEnabled: newValue)
            }
        }
        .onChange(of: settingsStore.settings.backgroundRefreshEnabled) { _, _ in
            guard AppRuntime.allowsNativeBootstrapOnLaunch else { return }
            Task {
                await BackgroundRefreshService.shared.schedule(force: true)
            }
        }
        .onChange(of: viewModel.snapshot) { _, newValue in
            guard AppRuntime.allowsNativeBootstrapOnLaunch else { return }
            Task {
                await liveActivityManager.sync(snapshot: newValue, isEnabled: settingsStore.settings.liveActivitiesEnabled)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            guard AppRuntime.allowsNativeBootstrapOnLaunch else { return }
            Task {
                await storeEntitlementStore.refreshEntitlements()
                liveActivityManager.refreshStatus()
            }
        }
        .onChange(of: viewModel.transientMessage) { _, newValue in
            isPresentingMessage = newValue != nil
        }
        .alert("提示", isPresented: $isPresentingMessage) {
            Button("知道了") {
                viewModel.transientMessage = nil
            }
        } message: {
            Text(viewModel.transientMessage ?? "")
        }
    }

    private func performInitialLoad() async {
        guard !hasLoadedInitialContent else { return }
        hasLoadedInitialContent = true

        await viewModel.loadInitialContent()
        guard AppRuntime.allowsNativeBootstrapOnLaunch else { return }

        await storeEntitlementStore.startIfNeeded()
        liveActivityManager.refreshStatus()

        Task {
            await BackgroundRefreshService.shared.schedule(force: true)
            await liveActivityManager.sync(snapshot: viewModel.snapshot, isEnabled: settingsStore.settings.liveActivitiesEnabled)
        }
    }

    private var customTabBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(AppTheme.divider)
                .frame(height: 1)

            HStack(spacing: 0) {
                tabButton(
                    title: "约饭",
                    systemImage: "fork.knife",
                    tab: .home
                )

                tabButton(
                    title: "我的段位",
                    systemImage: "trophy",
                    tab: .rank
                )

                tabButton(
                    title: "设置",
                    systemImage: "gearshape",
                    tab: .settings
                )
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 10)
            .background(AppTheme.surface)
        }
        .background(AppTheme.surface)
    }

    private func tabButton(title: String, systemImage: String, tab: RootTab) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 19, weight: .semibold))
                Text(title)
                    .font(.caption2.weight(.medium))
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity, minHeight: 58)
            .foregroundStyle(isSelected ? AppTheme.copper : AppTheme.textTertiary)
            .contentShape(Rectangle())
        }
        .accessibilityIdentifier("root-tab-\(title)")
    }
}

private struct JoinSharedEventScreen: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: HomeViewModel
    let event: MealEvent
    let onComplete: () -> Void

    @State private var nickname = ""
    @State private var avatarEmoji = "🍽️"
    @State private var isJoining = false

    private let recommendedAvatars = ["🍽️", "🍜", "🍣", "🍲", "🥗", "☕️", "🍰", "🍻"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("加入约饭局")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("你即将加入《\(event.title)》，加入后可以直接参与时间和餐厅投票。")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    TextField("昵称", text: $nickname)
                        .font(.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .frame(minHeight: 52)
                        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(AppTheme.divider, lineWidth: 1)
                        )

                    VStack(alignment: .leading, spacing: 10) {
                        Text("选择一个头像 Emoji")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AppTheme.textPrimary)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                            ForEach(recommendedAvatars, id: \.self) { emoji in
                                Button {
                                    avatarEmoji = emoji
                                } label: {
                                    Text(emoji)
                                        .font(.system(size: 24))
                                        .frame(maxWidth: .infinity, minHeight: 52)
                                        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .stroke(avatarEmoji == emoji ? AppTheme.copper : AppTheme.divider, lineWidth: avatarEmoji == emoji ? 2 : 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .templateSurface()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .background(AppBackgroundView())
        .navigationTitle("分享加入")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if nickname.isEmpty {
                nickname = viewModel.currentNickname
            }
        }
        .safeAreaInset(edge: .bottom) {
            BottomActionBar {
                Button(isJoining ? "加入中…" : "确认加入") {
                    guard !isJoining else { return }
                    isJoining = true
                    Task {
                        _ = await viewModel.joinSharedEvent(event, nickname: nickname, avatarEmoji: avatarEmoji)
                        await MainActor.run {
                            isJoining = false
                            dismiss()
                            onComplete()
                        }
                    }
                }
                .buttonStyle(TemplatePrimaryButtonStyle())
            } secondaryAction: {
                Button("稍后") {
                    dismiss()
                }
                .buttonStyle(TemplateSecondaryButtonStyle())
            }
        }
    }
}
