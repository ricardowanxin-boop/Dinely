import MapKit
import SwiftUI
import UIKit

struct HomeScreen: View {
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var storeEntitlementStore: StoreEntitlementStore
    let onCreateEvent: () -> Void
    let onEditEvent: (MealEvent) -> Void

    init(
        viewModel: HomeViewModel,
        storeEntitlementStore: StoreEntitlementStore,
        onCreateEvent: @escaping () -> Void = {},
        onEditEvent: @escaping (MealEvent) -> Void
    ) {
        self.viewModel = viewModel
        self.storeEntitlementStore = storeEntitlementStore
        self.onCreateEvent = onCreateEvent
        self.onEditEvent = onEditEvent
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            List {
                headerSection
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

                heroSection
                    .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

                if viewModel.events.isEmpty {
                    TemplateEmptyStateView(
                        title: "还没有约饭局",
                        detail: "创建第一场约饭局，邀请熟人一起投票决定去哪吃。",
                        systemImage: "fork.knife.circle"
                    )
                    .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(viewModel.events) { event in
                        NavigationLink {
                            EventDetailScreen(
                                viewModel: viewModel,
                                storeEntitlementStore: storeEntitlementStore,
                                event: event,
                                battleReport: viewModel.battleReport(for: event)
                            )
                        } label: {
                            EventCardView(event: event)
                        }
                        .accessibilityIdentifier("event-card-\(event.title)")
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            if event.status != .completed {
                                Button {
                                    onEditEvent(event)
                                } label: {
                                    Label("编辑", systemImage: "pencil")
                                }
                                .tint(AppTheme.copper)
                            }

                            Button(role: .destructive) {
                                _ = viewModel.deleteEvent(event.id)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }

                Color.clear
                    .frame(height: TemplateLayoutMetrics.tabBarClearance)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("home-screen")
        .rootChromeVisible(true)
        .refreshable {
            await viewModel.refresh(showNotification: false)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                Text(AppConfig.localizedBrandName())
                    .font(.largeTitle.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer(minLength: 0)

                createEventButton
            }

            Text("本周一共 \(viewModel.events.count) 个待处理约饭局")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var createEventButton: some View {
        Button {
            onCreateEvent()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.copper, AppTheme.copperDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: AppTheme.shadow.opacity(0.9), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        .accessibilityIdentifier("create-event-fab")
        .accessibilityLabel("创建约饭")
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.heroTitle)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(viewModel.heroSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                Image(systemName: "map.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(AppTheme.copper)
            }

            featureBadgeSection

            Text(viewModel.lastEventDescription)
                .font(.footnote)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .templateSurface(highlighted: true)
    }

    private var featureBadgeSection: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 10) {
                FeatureBadge(title: "多选投票", systemImage: "checklist")
                FeatureBadge(title: "地图选餐厅", systemImage: "map")
                FeatureBadge(title: "守约战报", systemImage: "trophy")
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    FeatureBadge(title: "多选投票", systemImage: "checklist")
                    FeatureBadge(title: "地图选餐厅", systemImage: "map")
                }

                FeatureBadge(title: "守约战报", systemImage: "trophy")
            }
        }
    }
}

struct EventDetailScreen: View {
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var storeEntitlementStore: StoreEntitlementStore
    let battleReport: BattleReport
    @State private var localEvent: MealEvent

    init(viewModel: HomeViewModel, storeEntitlementStore: StoreEntitlementStore, event: MealEvent, battleReport: BattleReport) {
        self.viewModel = viewModel
        self.storeEntitlementStore = storeEntitlementStore
        self.battleReport = battleReport
        _localEvent = State(initialValue: event)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                headerCard
                timeVoteSection
                restaurantVoteSection
                participantSection
                navigationSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .background(AppBackgroundView())
        .navigationTitle("约饭详情")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await synchronizeLoop()
        }
        .rootChromeVisible(false)
        .safeAreaInset(edge: .bottom) {
            BottomActionBar {
                Group {
                    switch localEvent.status {
                    case .voting:
                        Button("确认约饭局") {
                            if let updated = viewModel.confirmEvent(localEvent.id) {
                                localEvent = updated
                            }
                        }
                        .accessibilityLabel("确认约饭局")
                        .accessibilityAddTraits(.isButton)
                        .buttonStyle(TemplatePrimaryButtonStyle())
                        .accessibilityIdentifier("confirm-event-button")
                    case .confirmed:
                        NavigationLink("查看约饭当天地图") {
                            LiveMapScreen(viewModel: viewModel, event: localEvent)
                        }
                        .accessibilityLabel("查看约饭当天地图")
                        .accessibilityAddTraits(.isButton)
                        .buttonStyle(TemplatePrimaryButtonStyle())
                        .accessibilityIdentifier("live-map-link")
                    case .completed:
                        NavigationLink("查看守约战报") {
                            BattleReportScreen(
                                report: viewModel.battleReport(for: localEvent),
                                storeEntitlementStore: storeEntitlementStore
                            )
                        }
                        .accessibilityLabel("查看守约战报")
                        .accessibilityAddTraits(.isButton)
                        .buttonStyle(TemplatePrimaryButtonStyle())
                        .accessibilityIdentifier("battle-report-link")
                    }
                }
                .accessibilityIdentifier("event-detail-primary-action")
            } secondaryAction: {
                Group {
                    switch localEvent.status {
                    case .voting:
                        Text("发起人可在投票结束后确认时间与餐厅")
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    case .confirmed:
                        NavigationLink("签到 / AA / 战报") {
                            AttendanceScreen(
                                viewModel: viewModel,
                                storeEntitlementStore: storeEntitlementStore,
                                event: localEvent,
                                report: viewModel.battleReport(for: localEvent)
                            )
                        }
                        .accessibilityLabel("签到 / AA / 战报")
                        .accessibilityAddTraits(.isButton)
                        .buttonStyle(TemplateSecondaryButtonStyle())
                        .accessibilityIdentifier("attendance-flow-link")
                    case .completed:
                        NavigationLink("查看 AA 明细") {
                            AACalculatorScreen(
                                event: localEvent,
                                attendees: localEvent.participants.filter { $0.attended ?? false },
                                report: viewModel.battleReport(for: localEvent),
                                storeEntitlementStore: storeEntitlementStore
                            )
                        }
                        .accessibilityLabel("查看 AA 明细")
                        .accessibilityAddTraits(.isButton)
                        .buttonStyle(TemplateSecondaryButtonStyle())
                        .accessibilityIdentifier("aa-detail-link")
                    }
                }
            }
        }
        .accessibilityIdentifier("event-detail-screen")
    }

    private func synchronizeLoop() async {
        if let refreshed = await viewModel.refreshEvent(localEvent.id) {
            localEvent = refreshed
        }

        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(5))
            guard let refreshed = await viewModel.refreshEvent(localEvent.id) else { continue }
            localEvent = refreshed
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                Text(localEvent.categoryEmoji)
                    .font(.system(size: 30))
                    .frame(width: 44, height: 44)
                    .background(AppTheme.surfaceWarm, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(localEvent.title)
                        .font(.title3.weight(.bold))
                        .lineLimit(2)
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("由 \(localEvent.creatorName) 发起 · \(localEvent.cuisine)")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
                EventStatusBadge(status: localEvent.status)
            }

            Text(localEvent.votingSummary)
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.textSecondary)
        }
        .templateSurface()
    }

    private var timeVoteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("候选时间", badge: "\(localEvent.candidateTimes.count)")

            ForEach(localEvent.candidateTimes) { slot in
                Button {
                    guard localEvent.status == .voting else { return }
                    if let updated = viewModel.toggleTimeVote(eventID: localEvent.id, slotID: slot.id) {
                        localEvent = updated
                    }
                } label: {
                    VoteOptionCard(
                        title: slot.titleText,
                        subtitle: slot.rangeText,
                        votes: slot.voteCount,
                        isSelected: localEvent.status == .voting ? hasCurrentUserVoted(timeSlot: slot) : localEvent.confirmedTime?.id == slot.id,
                        stateTitle: localEvent.status == .voting ? (hasCurrentUserVoted(timeSlot: slot) ? "已投票" : "投票") : (localEvent.confirmedTime?.id == slot.id ? "已确定" : "待定"),
                        accent: AppTheme.aqua
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .templateSurface()
    }

    private var restaurantVoteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("候选餐厅", badge: "\(localEvent.candidateRestaurants.count)")

            ForEach(localEvent.candidateRestaurants) { restaurant in
                Button {
                    guard localEvent.status == .voting else { return }
                    if let updated = viewModel.toggleRestaurantVote(eventID: localEvent.id, restaurantID: restaurant.id) {
                        localEvent = updated
                    }
                } label: {
                    VoteOptionCard(
                        title: restaurant.name,
                        subtitle: restaurant.subtitle,
                        votes: restaurant.voteCount,
                        isSelected: localEvent.status == .voting ? hasCurrentUserVoted(restaurant: restaurant) : localEvent.confirmedRestaurant?.id == restaurant.id,
                        stateTitle: localEvent.status == .voting ? (hasCurrentUserVoted(restaurant: restaurant) ? "已投票" : "投票") : (localEvent.confirmedRestaurant?.id == restaurant.id ? "已确定" : "待定"),
                        accent: AppTheme.copper
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .templateSurface()
    }

    private var participantSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("参与者", badge: localEvent.participantSummary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(localEvent.participants) { participant in
                        VStack(spacing: 6) {
                            ParticipantAvatarView(participant: participant, size: 48)

                            Text(participant.nickname)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(AppTheme.textPrimary)
                                .lineLimit(1)

                            Circle()
                                .fill(participant.hasVotedTime ? AppTheme.mint : AppTheme.divider)
                                .frame(width: 8, height: 8)
                        }
                        .frame(width: 64)
                    }
                }
            }
        }
        .templateSurface()
    }

    private var navigationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TemplateSectionHeader(
                title: "流程入口",
                subtitle: "把约饭当天与聚餐后流程接成完整闭环"
            )

            NavigationLink {
                LiveMapScreen(viewModel: viewModel, event: localEvent)
            } label: {
                DetailNavigationRow(
                    title: "约饭当天 · 位置共享地图",
                    detail: "查看所有人距离餐厅还有多远"
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                AttendanceScreen(
                    viewModel: viewModel,
                    storeEntitlementStore: storeEntitlementStore,
                    event: localEvent,
                    report: viewModel.battleReport(for: localEvent)
                )
            } label: {
                DetailNavigationRow(
                    title: "聚餐后 · 到场确认与 AA",
                    detail: "标记实际到场人员并自动计算人均金额"
                )
            }
            .buttonStyle(.plain)

            Button {
                UIPasteboard.general.string = viewModel.shareMessage(for: localEvent)
                viewModel.transientMessage = "邀请文案和分享链接已复制。对方安装 App 后可直接加入。"
                Task {
                    _ = await viewModel.publishEventForSharing(localEvent.id)
                }
            } label: {
                DetailNavigationRow(
                    title: "分享加入链接",
                    detail: "复制邀请链接，让朋友直接加入并开始投票"
                )
            }
            .buttonStyle(.plain)
        }
        .templateSurface()
    }

    private func sectionTitle(_ title: String, badge: String) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(badge)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.surfaceWarm, in: Capsule())
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(badge)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.surfaceWarm, in: Capsule())
            }
        }
    }

    private func hasCurrentUserVoted(timeSlot: TimeSlot) -> Bool {
        timeSlot.votes.contains(viewModel.profileDeviceID)
    }

    private func hasCurrentUserVoted(restaurant: Restaurant) -> Bool {
        restaurant.votes.contains(viewModel.profileDeviceID)
    }
}

struct CreateEventFlowScreen: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var storeEntitlementStore: StoreEntitlementStore
    let editingEvent: MealEvent?

    @State private var draft: CreateEventDraft
    @State private var currentStep = 0
    @State private var createdEventForShare: MealEvent?
    @State private var activeTimePicker: ActiveTimePicker?
    @StateObject private var searchService = RestaurantSearchService()
    @StateObject private var locationService = DeviceLocationService()
    @FocusState private var isRestaurantSearchFocused: Bool
    @State private var searchAnchorCoordinate = CLLocationCoordinate2D(latitude: 31.2304, longitude: 121.4737)
    @State private var mapPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 31.2304, longitude: 121.4737),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )

    init(
        viewModel: HomeViewModel,
        storeEntitlementStore: StoreEntitlementStore,
        editingEvent: MealEvent? = nil
    ) {
        self.viewModel = viewModel
        self.storeEntitlementStore = storeEntitlementStore
        self.editingEvent = editingEvent

        if let editingEvent {
            _draft = State(initialValue: CreateEventDraft(event: editingEvent))
        } else {
            var initialDraft = SampleData.defaultDraft()
            initialDraft.candidateRestaurants = []
            _draft = State(initialValue: initialDraft)
        }
    }

    private var availableRestaurants: [Restaurant] {
        let merged = draft.candidateRestaurants + searchService.results
        var seen = Set<String>()
        return merged.filter { seen.insert($0.selectionKey).inserted }
    }

    private var participantLimit: Int {
        storeEntitlementStore.hasProAccess ? AppConfig.maximumProParticipants : AppConfig.maximumFreeParticipants
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                header

                switch currentStep {
                case 0:
                    basicsStep
                case 1:
                    timeStep
                default:
                    restaurantStep
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, TemplateLayoutMetrics.fullBottomActionBarClearance)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(AppBackgroundView())
        .accessibilityIdentifier("create-event-screen")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $createdEventForShare) { event in
            NavigationStack {
                CreatedEventShareScreen(viewModel: viewModel, event: event) {
                    createdEventForShare = nil
                    dismiss()
                }
            }
        }
        .sheet(item: $activeTimePicker) { picker in
            candidateTimePickerSheet(for: picker)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("取消") { dismiss() }
                    .foregroundStyle(AppTheme.textSecondary)
            }

            ToolbarItem(placement: .principal) {
                Text(editingEvent == nil ? "创建约饭" : "编辑约饭")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
            }
        }
        .safeAreaInset(edge: .bottom) {
            BottomActionBar {
                Button(primaryButtonTitle) {
                    if currentStep < 2 {
                        currentStep += 1
                    } else if let editingEvent {
                        if viewModel.updateEvent(
                            editingEvent.id,
                            from: draft,
                            hasProAccess: storeEntitlementStore.hasProAccess
                        ) != nil {
                            dismiss()
                        }
                    } else {
                        createdEventForShare = viewModel.addEvent(
                            from: draft,
                            hasProAccess: storeEntitlementStore.hasProAccess
                        )
                    }
                }
                .accessibilityIdentifier("create-event-primary")
                .buttonStyle(TemplatePrimaryButtonStyle())
            } secondaryAction: {
                if currentStep > 0 {
                    Button("上一步") {
                        currentStep -= 1
                    }
                    .accessibilityIdentifier("create-event-secondary")
                    .buttonStyle(TemplateSecondaryButtonStyle())
                } else {
                    EmptyView()
                }
            }
        }
        .onAppear {
            draft.maxParticipants = min(draft.maxParticipants, participantLimit)
            if currentStep == 2 {
                activateRestaurantStep()
            }
        }
        .onChange(of: storeEntitlementStore.hasProAccess) { _, _ in
            draft.maxParticipants = min(draft.maxParticipants, participantLimit)
        }
        .onChange(of: currentStep) { _, newValue in
            guard newValue == 2 else { return }
            activateRestaurantStep()
        }
        .onChange(of: searchService.query) { _, _ in
            guard currentStep == 2 else { return }
            searchService.scheduleSearch(near: currentRegionCenter)
        }
        .onChange(of: locationService.locationPoint) { _, newValue in
            guard currentStep == 2, let newValue else { return }
            updateRestaurantMap(
                to: newValue.coordinate,
                shouldRefreshResults: searchService.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            )
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("步骤 \(currentStep + 1) / 3")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)

            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { step in
                    Capsule()
                        .fill(step <= currentStep ? AppTheme.copper : AppTheme.divider)
                        .frame(width: step == currentStep ? 28 : 16, height: 6)
                }
            }
        }
    }

    private var basicsStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            TemplateSectionHeader(
                title: "基本信息",
                subtitle: "定义主题、菜系和预算，让朋友一眼知道这场约饭是干什么的。"
            )

            VStack(spacing: 12) {
                TextField("约饭主题", text: $draft.title)
                    .textFieldStyle(DineRankTextFieldStyle())
                    .accessibilityIdentifier("draft-title-field")

                TextField("菜系 / 关键词", text: $draft.cuisine)
                    .textFieldStyle(DineRankTextFieldStyle())
                    .accessibilityIdentifier("draft-cuisine-field")

                Stepper("预算 ¥\(draft.budgetPerPerson) / 人", value: $draft.budgetPerPerson, in: 50...300, step: 10)
                    .padding(16)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(AppTheme.divider, lineWidth: 1)
                    )
            }
        }
        .templateSurface()
    }

    private var timeStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            TemplateSectionHeader(
                title: "候选时间",
                subtitle: "最多添加 3 个时间段，方便大家多选投票。"
            )

            ForEach(draft.candidateTimes.indices, id: \.self) { index in
                let candidateTime = draft.candidateTimes[index]

                VStack(alignment: .leading, spacing: 12) {
                    candidateTimeRow(
                        title: "开始时间",
                        dateText: candidateDateText(candidateTime.startDate),
                        timeText: DisplayFormatters.time(candidateTime.startDate)
                    ) {
                        activeTimePicker = ActiveTimePicker(slotID: candidateTime.id, field: .start)
                    }

                    candidateTimeRow(
                        title: "结束时间",
                        timeText: DisplayFormatters.time(candidateTime.endDate)
                    ) {
                        activeTimePicker = ActiveTimePicker(slotID: candidateTime.id, field: .end)
                    }

                    TemplateSegmentedControl(
                        options: ["午餐", "晚餐", "Brunch"],
                        selection: Binding(
                            get: { draft.candidateTimes[index].period },
                            set: { draft.candidateTimes[index].period = $0 }
                        ),
                        title: { $0 }
                    )
                }
                .padding(16)
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AppTheme.divider, lineWidth: 1)
                )
            }

            if draft.candidateTimes.count < AppConfig.maximumCandidateTimes {
                Button("＋ 添加候选时间") {
                    let next = Calendar.current.date(byAdding: .hour, value: 24, to: Date()) ?? Date()
                    draft.candidateTimes.append(
                        CreateTimeDraft(
                            id: UUID(),
                            startDate: next,
                            endDate: next.addingTimeInterval(90 * 60),
                            period: "晚餐"
                        )
                    )
                }
                .buttonStyle(TemplateSecondaryButtonStyle())
            }
        }
        .templateSurface()
        .accessibilityIdentifier("create-event-step-time")
    }

    private var restaurantStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            TemplateSectionHeader(
                title: "地图选餐厅",
                subtitle: "最多选择 3 家候选餐厅，后续大家可以在详情页继续投票。"
            )

            restaurantSearchField

            Text("默认会按当前位置和“\(initialRestaurantKeyword)”搜索真实餐厅，你也可以直接改关键词。")
                .font(.system(size: 12))
                .foregroundStyle(AppTheme.textSecondary)
                .padding(.horizontal, 4)

            Map(position: $mapPosition) {
                ForEach(availableRestaurants) { restaurant in
                    Marker(restaurant.name, coordinate: restaurant.coordinate)
                        .tint(isRestaurantSelected(restaurant) ? AppTheme.copper : AppTheme.textSecondary)
                }
            }
            .frame(height: 280)
            .onMapCameraChange(frequency: .continuous) { context in
                searchAnchorCoordinate = context.region.center
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.divider, lineWidth: 1)
            )

            if searchService.isSearching {
                ProgressView("正在搜索附近餐厅…")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.textSecondary)
            } else if let errorMessage = searchService.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.rose)
                    .padding(.horizontal, 4)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(restaurantResultsTitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                if availableRestaurants.isEmpty {
                    Text(emptyRestaurantResultsMessage)
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.textSecondary)
                        .padding(.horizontal, 4)
                } else {
                    ForEach(availableRestaurants) { restaurant in
                        Button {
                            toggleRestaurant(restaurant)
                            focusRestaurantOnMap(restaurant)
                        } label: {
                            restaurantOptionCard(restaurant)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("restaurant-option-\(restaurant.name)")
                    }
                }
            }

            Stepper("参与人数上限：\(draft.maxParticipants) 人", value: $draft.maxParticipants, in: 2...participantLimit)
                .padding(16)
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AppTheme.divider, lineWidth: 1)
                )

            if !storeEntitlementStore.hasProAccess {
                VStack(alignment: .leading, spacing: 10) {
                    ViewThatFits(in: .horizontal) {
                        HStack {
                            Text("升级 Pro 支持最多 20 人")
                                .font(.headline)
                            Spacer()
                            Text("当前免费版最多 8 人")
                                .font(.headline.weight(.bold))
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("升级 Pro 支持最多 20 人")
                                .font(.headline)
                            Text("当前免费版最多 8 人")
                                .font(.headline.weight(.bold))
                        }
                    }
                    .foregroundStyle(AppTheme.textPrimary)
                    .padding(16)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#FFD55C"), AppTheme.warning],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )
                }
            }
        }
        .templateSurface()
        .accessibilityIdentifier("create-event-step-restaurant")
    }

    private var currentRegionCenter: CLLocationCoordinate2D {
        searchAnchorCoordinate
    }

    private var primaryButtonTitle: String {
        switch currentStep {
        case 0:
            "下一步：候选时间"
        case 1:
            "下一步：选餐厅"
        default:
            editingEvent == nil ? "创建约饭" : "保存修改"
        }
    }

    private func toggleRestaurant(_ restaurant: Restaurant) {
        if let index = draft.candidateRestaurants.firstIndex(where: { $0.selectionKey == restaurant.selectionKey }) {
            draft.candidateRestaurants.remove(at: index)
            return
        }

        guard draft.candidateRestaurants.count < AppConfig.maximumCandidateRestaurants else { return }
        draft.candidateRestaurants.append(restaurant)
    }

    private var restaurantSearchField: some View {
        TextField("搜索附近餐厅", text: $searchService.query)
            .textFieldStyle(DineRankTextFieldStyle())
            .focused($isRestaurantSearchFocused)
            .submitLabel(.search)
            .accessibilityIdentifier("restaurant-search-field")
            .onSubmit {
                Task {
                    await searchService.search(near: currentRegionCenter)
                }
            }
    }

    private var restaurantResultsTitle: String {
        if let activeKeyword = searchService.activeKeyword, !activeKeyword.isEmpty {
            return "附近「\(activeKeyword)」结果"
        }

        return "附近餐厅"
    }

    private var emptyRestaurantResultsMessage: String {
        if let activeKeyword = searchService.activeKeyword, !activeKeyword.isEmpty {
            return "暂时没有找到更合适的真实结果。试试换个关键词，或者移动地图后再搜一次。"
        }

        return "正在按你附近的位置加载真实餐厅结果，你也可以直接输入菜系或店名搜索。"
    }

    private var initialRestaurantKeyword: String {
        let trimmedCuisine = draft.cuisine.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedCuisine.isEmpty ? "餐厅" : trimmedCuisine
    }

    private func isRestaurantSelected(_ restaurant: Restaurant) -> Bool {
        draft.candidateRestaurants.contains { $0.selectionKey == restaurant.selectionKey }
    }

    private func activateRestaurantStep() {
        locationService.requestCurrentLocation()

        guard searchService.results.isEmpty || searchService.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        Task {
            await searchService.search(keyword: initialRestaurantKeyword, near: currentRegionCenter)
        }
    }

    private func updateRestaurantMap(to coordinate: CLLocationCoordinate2D, shouldRefreshResults: Bool) {
        searchAnchorCoordinate = coordinate
        mapPosition = .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )

        guard shouldRefreshResults else { return }

        Task {
            await searchService.search(keyword: initialRestaurantKeyword, near: coordinate)
        }
    }

    private func focusRestaurantOnMap(_ restaurant: Restaurant) {
        isRestaurantSearchFocused = false
        searchAnchorCoordinate = restaurant.coordinate
        mapPosition = .region(
            MKCoordinateRegion(
                center: restaurant.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006)
            )
        )
    }

    private func restaurantOptionCard(_ restaurant: Restaurant) -> some View {
        let isSelected = isRestaurantSelected(restaurant)

        return HStack(spacing: 12) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(isSelected ? AppTheme.copper : AppTheme.textTertiary)

            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(restaurant.address)
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(2)
                Text(restaurant.subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.textTertiary)
            }

            Spacer()
        }
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isSelected ? AppTheme.copper : AppTheme.divider, lineWidth: isSelected ? 2 : 1)
        )
    }

    private func candidateDateText(_ date: Date) -> String {
        date.formatted(
            .dateTime
                .year()
                .month(.defaultDigits)
                .day()
                .locale(Locale(identifier: "zh_CN"))
        )
    }

    private func candidateTimeRow(
        title: String,
        dateText: String? = nil,
        timeText: String,
        action: @escaping () -> Void
    ) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: 12) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer(minLength: 8)

                candidateTimeValueGroup(
                    title: title,
                    dateText: dateText,
                    timeText: timeText,
                    action: action
                )
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                candidateTimeValueGroup(
                    title: title,
                    dateText: dateText,
                    timeText: timeText,
                    action: action
                )
            }
        }
    }

    private func candidateTimeValueGroup(
        title: String,
        dateText: String? = nil,
        timeText: String,
        action: @escaping () -> Void
    ) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 10) {
                if let dateText {
                    candidateTimeChip(
                        text: dateText,
                        accessibilityLabel: "\(title)日期",
                        action: action
                    )
                }

                candidateTimeChip(
                    text: timeText,
                    accessibilityLabel: "\(title)时间",
                    action: action
                )
            }

            VStack(alignment: .leading, spacing: 10) {
                if let dateText {
                    candidateTimeChip(
                        text: dateText,
                        accessibilityLabel: "\(title)日期",
                        action: action
                    )
                }

                candidateTimeChip(
                    text: timeText,
                    accessibilityLabel: "\(title)时间",
                    action: action
                )
            }
        }
    }

    private func candidateTimeChip(
        text: String,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(text)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 14)
                .frame(minHeight: TemplateLayoutMetrics.segmentedControlHeight)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppTheme.surfaceTint)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(AppTheme.divider, lineWidth: 1)
                )
                .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    @ViewBuilder
    private func candidateTimePickerSheet(for picker: ActiveTimePicker) -> some View {
        if let index = draft.candidateTimes.firstIndex(where: { $0.id == picker.slotID }) {
            CandidateTimePickerSheet(
                selection: picker.binding(for: $draft.candidateTimes[index]),
                field: picker.field
            )
        }
    }
}

private extension CreateEventFlowScreen {
    struct ActiveTimePicker: Identifiable, Equatable {
        enum Field: String {
            case start
            case end

            var title: String {
                switch self {
                case .start:
                    return "开始时间"
                case .end:
                    return "结束时间"
                }
            }
        }

        let slotID: UUID
        let field: Field

        var id: String {
            "\(slotID.uuidString)-\(field.rawValue)"
        }

        func binding(for timeDraft: Binding<CreateTimeDraft>) -> Binding<Date> {
            Binding(
                get: {
                    switch field {
                    case .start:
                        return timeDraft.wrappedValue.startDate
                    case .end:
                        return timeDraft.wrappedValue.endDate
                    }
                },
                set: { newValue in
                    switch field {
                    case .start:
                        timeDraft.wrappedValue.startDate = newValue
                    case .end:
                        timeDraft.wrappedValue.endDate = newValue
                    }
                }
            )
        }
    }
}

private struct CandidateTimePickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var selection: Date
    let field: CreateEventFlowScreen.ActiveTimePicker.Field

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    if field == .start {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("日期")
                                .font(.headline)
                                .foregroundStyle(AppTheme.textPrimary)

                            DatePicker(
                                "日期",
                                selection: $selection,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("时间")
                            .font(.headline)
                            .foregroundStyle(AppTheme.textPrimary)

                        DatePicker(
                            "时间",
                            selection: $selection,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                        .clipped()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .background(AppBackgroundView())
            .navigationTitle(field.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents(field == .start ? [.large] : [.medium])
        .presentationDragIndicator(.visible)
    }
}

private struct CreatedEventShareScreen: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: HomeViewModel
    let event: MealEvent
    let onDone: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("约饭已创建")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("下一步把链接发给朋友，他们打开后就能填写昵称、选择头像并直接参与投票。")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text(event.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(viewModel.shareURL(for: event).absoluteString)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                        .textSelection(.enabled)
                }
                .templateSurface(highlighted: true)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, TemplateLayoutMetrics.fullBottomActionBarClearance)
        }
        .background(AppBackgroundView())
        .navigationTitle("分享约饭局")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            BottomActionBar {
                Button("复制分享链接") {
                    UIPasteboard.general.string = viewModel.shareURL(for: event).absoluteString
                    viewModel.transientMessage = "分享链接已复制，可以直接发给朋友。"
                    Task {
                        _ = await viewModel.publishEventForSharing(event.id)
                    }
                }
                .accessibilityIdentifier("share-created-event-button")
                .buttonStyle(TemplatePrimaryButtonStyle())
            } secondaryAction: {
                AdaptiveButtonGroup {
                    ShareLink(item: viewModel.shareMessage(for: event)) {
                        Text("系统分享")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(TemplateSecondaryButtonStyle())
                } secondary: {
                    Button("完成") {
                        dismiss()
                        onDone()
                    }
                    .accessibilityIdentifier("share-created-event-done")
                    .buttonStyle(TemplateSecondaryButtonStyle())
                }
            }
        }
    }
}

struct LiveMapScreen: View {
    @ObservedObject var viewModel: HomeViewModel
    @StateObject private var locationService = DeviceLocationService()
    @State private var localEvent: MealEvent
    @State private var isLocationSharingEnabled = false
    @State private var mapPosition: MapCameraPosition
    @State private var isShowingNavigationOptions = false
    private let autoCheckInThreshold: CLLocationDistance = 180

    init(viewModel: HomeViewModel, event: MealEvent) {
        self.viewModel = viewModel
        _localEvent = State(initialValue: event)
        let center = event.confirmedRestaurant?.coordinate ?? event.candidateRestaurants.first?.coordinate ?? CLLocationCoordinate2D(latitude: 31.2304, longitude: 121.4737)
        _mapPosition = State(initialValue: .region(MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006))))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                mapCard
                sharingCard
                distanceCard
            }
            .padding(16)
            .padding(.bottom, 40)
        }
        .background(AppBackgroundView())
        .accessibilityIdentifier("live-map-screen")
        .navigationTitle("约饭当天")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let updated = viewModel.event(for: localEvent.id) {
                localEvent = updated
            }
            isLocationSharingEnabled = locationService.isSharing
            locationService.requestPermission()
        }
        .onChange(of: isLocationSharingEnabled) { _, newValue in
            locationService.setSharingEnabled(newValue)
            let updated = viewModel.updateLocationSharing(
                eventID: localEvent.id,
                isEnabled: newValue,
                currentLocation: locationService.locationPoint
            )
            if let updated {
                localEvent = updated
            }
        }
        .task {
            await synchronizeLoop()
        }
        .confirmationDialog("导航到餐厅", isPresented: $isShowingNavigationOptions, titleVisibility: .visible) {
            Button("Apple 地图") {
                openAppleMaps()
            }

            if gaodeURL != nil {
                Button("高德地图") {
                    openGaodeMaps()
                }
            }

            Button("复制餐厅地址") {
                UIPasteboard.general.string = confirmedRestaurant?.address ?? confirmedRestaurant?.name ?? ""
                viewModel.transientMessage = "餐厅地址已复制。"
            }

            Button("取消", role: .cancel) {}
        }
        .onChange(of: locationService.locationPoint) { _, newValue in
            guard isLocationSharingEnabled else { return }
            let updated = viewModel.updateLocationSharing(
                eventID: localEvent.id,
                isEnabled: true,
                currentLocation: newValue
            )
            if let updated {
                localEvent = updated
            }
        }
        .rootChromeVisible(false)
    }

    private var mapCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            TemplateSectionHeader(title: "实时地图", subtitle: "查看所有已开启位置共享的朋友与目标餐厅的距离。")

            Map(position: $mapPosition) {
                if let restaurant = localEvent.confirmedRestaurant ?? localEvent.candidateRestaurants.first {
                    Marker(restaurant.name, coordinate: restaurant.coordinate)
                        .tint(AppTheme.copper)
                }

                ForEach(sharingParticipants) { participant in
                    if let location = participant.currentLocation {
                        Annotation(participant.nickname, coordinate: location.coordinate) {
                            VStack(spacing: 4) {
                                ParticipantAvatarView(participant: participant, size: 28)
                                Text(participant.nickname)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(AppTheme.surface.opacity(0.94), in: Capsule())
                            }
                        }
                    }
                }
            }
            .frame(height: 360)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.divider, lineWidth: 1)
            )

            Button {
                isShowingNavigationOptions = true
            } label: {
                Label("导航前往餐厅", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(TemplateSecondaryButtonStyle())

            HStack(spacing: 10) {
                Image(systemName: isAutoCheckedIn ? "checkmark.circle.fill" : "location.circle.fill")
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(isAutoCheckedIn ? AppTheme.mint : AppTheme.copper, in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(isAutoCheckedIn ? "已自动签到" : "正在接近餐厅")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(checkInSubtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.8))
                }

                Spacer()
            }
            .padding(14)
            .background(
                isAutoCheckedIn ? AppTheme.mint : AppTheme.copper,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
        }
        .templateSurface()
    }

    private var sharingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            TemplateSectionHeader(title: "位置共享", subtitle: "默认关闭，开启后会向同局参与者同步当前位置。")

            Toggle(isOn: $isLocationSharingEnabled) {
                TemplateSettingsRow(
                    title: "实时位置共享",
                    detail: "开启后可查看所有人距离餐厅的距离。",
                    systemImage: "location"
                )
            }
            .tint(AppTheme.mint)
            .accessibilityIdentifier("location-sharing-toggle")
        }
        .templateSurface()
    }

    private var distanceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            TemplateSectionHeader(title: "所有人距离", subtitle: "\(sharingParticipants.count)/\(localEvent.participants.count) 人已开启位置共享")

            ForEach(sharingParticipants) { participant in
                HStack(spacing: 12) {
                    ParticipantAvatarView(participant: participant, size: 40)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(participant.nickname)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AppTheme.textPrimary)

                        Text(participant.rank.title)
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    Spacer()

                    Text(distance(for: participant))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppTheme.copper)
                }
                .padding(14)
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AppTheme.divider, lineWidth: 1)
                )
            }
        }
        .templateSurface()
    }

    private var sharingParticipants: [Participant] {
        localEvent.participants.filter { $0.isLocationSharingEnabled && $0.currentLocation != nil }
    }

    private var confirmedRestaurant: Restaurant? {
        localEvent.confirmedRestaurant ?? localEvent.candidateRestaurants.first
    }

    private var gaodeURL: URL? {
        guard let restaurant = confirmedRestaurant else { return nil }

        let encodedName = restaurant.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? restaurant.name
        guard let url = URL(string: "iosamap://path?sourceApplication=\(AppConfig.appDisplayName)&dlat=\(restaurant.latitude)&dlon=\(restaurant.longitude)&dname=\(encodedName)&dev=0&t=0") else {
            return nil
        }

        guard UIApplication.shared.canOpenURL(url) else { return nil }
        return url
    }

    private func openAppleMaps() {
        guard let restaurant = confirmedRestaurant else { return }

        let destination = MKMapItem(placemark: MKPlacemark(coordinate: restaurant.coordinate))
        destination.name = restaurant.name
        destination.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }

    private func openGaodeMaps() {
        guard let url = gaodeURL else { return }
        UIApplication.shared.open(url)
    }

    private func distance(for participant: Participant) -> String {
        guard
            let userLocation = participant.currentLocation?.coordinate,
            let restaurant = localEvent.confirmedRestaurant ?? localEvent.candidateRestaurants.first
        else {
            return "未定位"
        }

        let from = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let to = CLLocation(latitude: restaurant.latitude, longitude: restaurant.longitude)
        return DisplayFormatters.shortDistance(from.distance(from: to))
    }

    private var distanceToRestaurant: CLLocationDistance? {
        guard
            let current = locationService.locationPoint?.coordinate,
            let restaurant = localEvent.confirmedRestaurant ?? localEvent.candidateRestaurants.first
        else {
            return nil
        }

        let from = CLLocation(latitude: current.latitude, longitude: current.longitude)
        let to = CLLocation(latitude: restaurant.latitude, longitude: restaurant.longitude)
        return from.distance(from: to)
    }

    private var isAutoCheckedIn: Bool {
        guard isLocationSharingEnabled, let distanceToRestaurant else { return false }
        return distanceToRestaurant <= autoCheckInThreshold
    }

    private var checkInSubtitle: String {
        guard let distanceToRestaurant else {
            return "开启位置共享后可自动判断是否到店。"
        }

        if isAutoCheckedIn {
            return "你已到达餐厅附近 \(DisplayFormatters.shortDistance(distanceToRestaurant))。"
        }

        return "距离餐厅还有 \(DisplayFormatters.shortDistance(distanceToRestaurant))。"
    }

    private func synchronizeLoop() async {
        if let refreshed = await viewModel.refreshEvent(localEvent.id) {
            localEvent = refreshed
        }

        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(5))
            guard let refreshed = await viewModel.refreshEvent(localEvent.id) else { continue }
            localEvent = refreshed
        }
    }
}

struct AttendanceScreen: View {
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var storeEntitlementStore: StoreEntitlementStore
    struct AttendanceSelection: Identifiable {
        let id: UUID
        let participant: Participant
        var isAttending: Bool
    }

    let event: MealEvent
    let report: BattleReport

    @State private var selections: [AttendanceSelection]
    @State private var totalBillText: String
    @State private var showCalculator = false
    @State private var completedEvent: MealEvent?
    @State private var completedReport: BattleReport?

    init(viewModel: HomeViewModel, storeEntitlementStore: StoreEntitlementStore, event: MealEvent, report: BattleReport) {
        self.viewModel = viewModel
        self.storeEntitlementStore = storeEntitlementStore
        self.event = event
        self.report = report
        _selections = State(initialValue: event.participants.map {
            AttendanceSelection(id: $0.id, participant: $0, isAttending: $0.attended ?? false)
        })
        _totalBillText = State(initialValue: event.totalBill.map { String(Int($0)) } ?? "")
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                TextField("输入本次总金额，例如 502", text: $totalBillText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(DineRankTextFieldStyle())
                    .accessibilityIdentifier("total-bill-field")

                ForEach($selections) { $selection in
                    HStack(spacing: 14) {
                        ParticipantAvatarView(participant: selection.participant, size: 48)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(selection.participant.nickname)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(AppTheme.textPrimary)
                            Text("\(selection.participant.rank.title) · \(selection.participant.attendanceRateText)")
                                .font(.system(size: 13))
                                .foregroundStyle(AppTheme.textSecondary)
                        }

                        Spacer()

                        Button {
                            selection.isAttending.toggle()
                        } label: {
                            Image(systemName: selection.isAttending ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundStyle(selection.isAttending ? AppTheme.mint : AppTheme.divider)
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("attendance-toggle-\(selection.participant.nickname)")
                    }
                    .padding(16)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(AppTheme.divider, lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, TemplateLayoutMetrics.compactBottomActionBarClearance)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(AppBackgroundView())
        .accessibilityIdentifier("attendance-screen")
        .navigationTitle("标记到场人员")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showCalculator) {
            Group {
                if let completedEvent, let completedReport {
                AACalculatorScreen(
                    event: completedEvent,
                    attendees: completedEvent.participants.filter { $0.attended ?? false },
                    report: completedReport,
                    storeEntitlementStore: storeEntitlementStore
                )
                } else {
                    EmptyView()
                }
            }
        }
        .rootChromeVisible(false)
        .safeAreaInset(edge: .bottom) {
            BottomActionBar {
                Button("确认并结算") {
                    let attendeeIDs = selections.filter(\.isAttending).map(\.id)
                    let totalBill = Double(totalBillText) ?? event.totalBill ?? report.averageSpend * Double(max(attendeeIDs.count, 1))
                    if let result = viewModel.completeEvent(event.id, attendedIDs: attendeeIDs, totalBill: totalBill) {
                        completedEvent = result.0
                        completedReport = result.1
                        showCalculator = true
                    }
                }
                .accessibilityLabel("确认并结算")
                .accessibilityAddTraits(.isButton)
                .buttonStyle(TemplatePrimaryButtonStyle())
                .accessibilityIdentifier("settle-button")
            } secondaryAction: {
                Text("已到场 \(selections.filter(\.isAttending).count)/\(selections.count) 人")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct AACalculatorScreen: View {
    let event: MealEvent
    let attendees: [Participant]
    let report: BattleReport
    @ObservedObject var storeEntitlementStore: StoreEntitlementStore

    @State private var showReport = false
    @State private var showingCopiedAlert = false

    private var totalBill: Double {
        event.totalBill ?? report.averageSpend * Double(max(attendees.count, 1))
    }

    private var amountPerPerson: Double {
        totalBill / Double(max(attendees.count, 1))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("总金额")
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.86))
                    Text(DisplayFormatters.currency(totalBill))
                        .font(.system(size: 46, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .foregroundStyle(.white)
                    Text("共 \(attendees.count) 人参与")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
                .background(
                    LinearGradient(
                        colors: [AppTheme.copper, AppTheme.neutralForCards],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text("每人应付")
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.textSecondary)
                    Text(DisplayFormatters.currency(amountPerPerson))
                        .font(.system(size: 40, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                        .foregroundStyle(AppTheme.neutralForCards)
                    Text("已自动四舍五入")
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.textTertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppTheme.divider, lineWidth: 1)
                )

                ForEach(attendees) { participant in
                    HStack(spacing: 12) {
                        ParticipantAvatarView(participant: participant, size: 40)
                        Text(participant.nickname)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                        Spacer()
                        Text(DisplayFormatters.currency(amountPerPerson))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AppTheme.neutralForCards)
                    }
                    .padding(16)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(AppTheme.divider, lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, TemplateLayoutMetrics.fullBottomActionBarClearance)
        }
        .background(AppBackgroundView())
        .accessibilityIdentifier("aa-screen")
        .navigationTitle("AA 分摊")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showReport) {
            BattleReportScreen(
                report: report,
                storeEntitlementStore: storeEntitlementStore
            )
        }
        .alert("已复制", isPresented: $showingCopiedAlert) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text("AA 分摊明细已经复制到剪贴板。")
        }
        .rootChromeVisible(false)
        .safeAreaInset(edge: .bottom) {
            BottomActionBar {
                Button("完成结算") {
                    showReport = true
                }
                .accessibilityLabel("完成结算")
                .accessibilityAddTraits(.isButton)
                .buttonStyle(TemplatePrimaryButtonStyle())
                .accessibilityIdentifier("aa-finish-button")
            } secondaryAction: {
                Button("复制分摊明细") {
                    UIPasteboard.general.string = aaBreakdownText
                    showingCopiedAlert = true
                }
                .accessibilityLabel("复制分摊明细")
                .accessibilityAddTraits(.isButton)
                .buttonStyle(TemplateSecondaryButtonStyle())
                .accessibilityIdentifier("aa-copy-button")
            }
        }
    }

    private var aaBreakdownText: String {
        let lines = attendees.map { "\($0.nickname)：\(DisplayFormatters.currency(amountPerPerson))" }
        return ([
            "《\(event.title)》AA 明细",
            "总金额：\(DisplayFormatters.currency(totalBill))",
            "参与人数：\(attendees.count)",
            "每人应付：\(DisplayFormatters.currency(amountPerPerson))"
        ] + lines).joined(separator: "\n")
    }
}

struct BattleReportScreen: View {
    let report: BattleReport
    @ObservedObject var storeEntitlementStore: StoreEntitlementStore
    @State private var isPresentingShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var exportErrorMessage: String?
    @State private var showingCopiedAlert = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("约饭战报")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(report.eventTitle)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppTheme.textSecondary)

                    Text(DisplayFormatters.day(report.date))
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textTertiary)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                        MetricCardView(icon: "person.3.fill", value: "\(report.invitedCount)", label: "应到人数", accent: AppTheme.aqua)
                        MetricCardView(icon: "checkmark.seal.fill", value: "\(report.attendedCount)", label: "实到人数", accent: AppTheme.mint)
                        MetricCardView(icon: "flame.fill", value: DisplayFormatters.percentage(report.attendanceRate), label: "守约率", accent: AppTheme.warning)
                        MetricCardView(icon: "yensign.circle.fill", value: DisplayFormatters.currency(report.averageSpend), label: "人均消费", accent: AppTheme.copper)
                    }

                    Divider()
                        .overlay(AppTheme.divider)

                    reportNames(title: "守约英雄", names: report.heroNames, tint: AppTheme.mint)
                    reportNames(title: "爽约名单", names: report.noShowNames, tint: AppTheme.rose)
                }
                .templateSurface(highlighted: true)

                VStack(alignment: .leading, spacing: 8) {
                    Text("分享建议")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(storeEntitlementStore.hasProAccess ? "你已解锁高清战报卡导出，可直接生成图片分享到微信、朋友圈或小红书。" : "免费版支持文本战报分享，升级 Pro 后可导出高清战报卡。")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .templateSurface()
            }
            .padding(16)
            .padding(.bottom, TemplateLayoutMetrics.fullBottomActionBarClearance)
        }
        .background(AppBackgroundView())
        .accessibilityIdentifier("battle-report-screen")
        .navigationTitle("守约战报")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isPresentingShareSheet) {
            ActivityShareSheet(items: shareItems)
        }
        .alert("提示", isPresented: Binding(
            get: { exportErrorMessage != nil || showingCopiedAlert },
            set: { isPresented in
                if !isPresented {
                    exportErrorMessage = nil
                    showingCopiedAlert = false
                }
            }
        )) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(exportErrorMessage ?? "战报内容已复制到剪贴板。")
        }
        .rootChromeVisible(false)
        .safeAreaInset(edge: .bottom) {
            BottomActionBar {
                Button(storeEntitlementStore.hasProAccess ? "导出高清战报卡" : "升级 Pro 导出战报卡") {
                    if storeEntitlementStore.hasProAccess {
                        Task { await exportShareCard() }
                    } else {
                        exportErrorMessage = "高清战报卡属于 Pro 权益，先在设置页完成购买或恢复购买后再导出。"
                    }
                }
                .buttonStyle(TemplatePrimaryButtonStyle())
            } secondaryAction: {
                AdaptiveButtonGroup {
                    Button("分享文本战报") {
                        shareItems = [shareText]
                        isPresentingShareSheet = true
                    }
                    .buttonStyle(TemplateSecondaryButtonStyle())
                } secondary: {
                    Button("复制战报") {
                        UIPasteboard.general.string = shareText
                        showingCopiedAlert = true
                    }
                    .buttonStyle(TemplateSecondaryButtonStyle())
                }
            }
        }
    }

    @MainActor
    private func exportShareCard() async {
        guard let shareCardURL = BattleReportCardExporter.export(report: report, brandName: AppConfig.localizedBrandName()) else {
            exportErrorMessage = "战报卡导出失败，请稍后重试。"
            return
        }

        shareItems = [shareCardURL]
        isPresentingShareSheet = true
    }

    private var shareText: String {
        """
        守约战报 · \(report.eventTitle)
        时间：\(DisplayFormatters.day(report.date))
        守约率：\(DisplayFormatters.percentage(report.attendanceRate))
        实到 \(report.attendedCount)/\(report.invitedCount) 人
        人均消费：\(DisplayFormatters.currency(report.averageSpend))
        """
    }

    @ViewBuilder
    private func reportNames(title: String, names: [String], tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tint)

            ForEach(names, id: \.self) { name in
                Text("• \(name)")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textPrimary)
            }
        }
    }
}

private struct BattleReportShareCardView: View {
    let report: BattleReport
    let brandName: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppTheme.copper, AppTheme.copperDark, AppTheme.neutralForCards],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("\(brandName) · 守约战报")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.white)

                    Text(report.eventTitle)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.92))

                    Text(DisplayFormatters.day(report.date))
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white.opacity(0.78))
                }

                HStack(spacing: 18) {
                    battleShareMetric(value: "\(report.invitedCount)", label: "应到")
                    battleShareMetric(value: "\(report.attendedCount)", label: "实到")
                    battleShareMetric(value: DisplayFormatters.percentage(report.attendanceRate), label: "守约率")
                    battleShareMetric(value: DisplayFormatters.currency(report.averageSpend), label: "人均")
                }

                VStack(alignment: .leading, spacing: 16) {
                    battleShareList(title: "守约英雄", names: report.heroNames)
                    battleShareList(title: "爽约名单", names: report.noShowNames)
                }

                Spacer()

                Text("Dinely / 食否")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.82))
            }
            .padding(56)
        }
        .frame(width: 540, height: 960)
    }

    private func battleShareMetric(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white.opacity(0.78))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func battleShareList(title: String, names: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)

            ForEach(names.isEmpty ? ["暂无"] : names, id: \.self) { name in
                Text("• \(name)")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

@MainActor
private enum BattleReportCardExporter {
    static func export(report: BattleReport, brandName: String) -> URL? {
        let renderer = ImageRenderer(content: BattleReportShareCardView(report: report, brandName: brandName))
        renderer.scale = UIScreen.main.scale

        guard
            let image = renderer.uiImage,
            let data = image.pngData()
        else {
            return nil
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("battle-report-\(report.id.uuidString)")
            .appendingPathExtension("png")

        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }
}

private struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private struct VoteOptionCard: View {
    let title: String
    let subtitle: String
    let votes: Int
    let isSelected: Bool
    let stateTitle: String
    let accent: Color

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(2)
                    .foregroundStyle(AppTheme.textPrimary)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Text("\(votes) 票")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(accent)

                Text(stateTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : AppTheme.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(isSelected ? accent : AppTheme.surfaceWarm, in: Capsule())
            }
        }
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isSelected ? accent : AppTheme.divider, lineWidth: isSelected ? 2 : 1)
        )
    }
}

private struct DetailNavigationRow: View {
    let title: String
    let detail: String

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(AppTheme.textPrimary)
                Text(detail)
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.textTertiary)
        }
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(AppTheme.divider, lineWidth: 1)
        )
    }
}

private struct DineRankTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .font(.body)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(minHeight: TemplateLayoutMetrics.controlHeight)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppTheme.divider, lineWidth: 1)
            )
    }
}

private extension AppTheme {
    static let neutralForCards = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 229 / 255, green: 237 / 255, blue: 247 / 255, alpha: 1)
                : UIColor(red: 74 / 255, green: 85 / 255, blue: 104 / 255, alpha: 1)
        }
    )
}

@MainActor
private final class RestaurantSearchService: ObservableObject {
    @Published var query = ""
    @Published private(set) var results: [Restaurant] = []
    @Published private(set) var isSearching = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var activeKeyword: String?

    private var pendingSearchTask: Task<Void, Never>?
    private var latestSearchToken = UUID()

    deinit {
        pendingSearchTask?.cancel()
    }

    func search(near center: CLLocationCoordinate2D) async {
        await search(keyword: query, near: center)
    }

    func search(keyword rawKeyword: String, near center: CLLocationCoordinate2D) async {
        pendingSearchTask?.cancel()

        let trimmed = rawKeyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = nil
            isSearching = false
            activeKeyword = nil
            return
        }

        let token = UUID()
        latestSearchToken = token
        activeKeyword = trimmed
        isSearching = true
        errorMessage = nil
        defer {
            if latestSearchToken == token {
                isSearching = false
            }
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmed
        request.resultTypes = .pointOfInterest
        request.region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        )

        do {
            let response = try await MKLocalSearch(request: request).start()
            guard latestSearchToken == token else { return }
            results = response.mapItems.prefix(6).map { item in
                Restaurant(
                    id: UUID(),
                    name: item.name ?? "附近餐厅",
                    address: item.placemark.title ?? item.placemark.name ?? "地址待补充",
                    latitude: item.placemark.coordinate.latitude,
                    longitude: item.placemark.coordinate.longitude,
                    cuisine: item.pointOfInterestCategory?.rawValue.replacingOccurrences(of: "_", with: " ") ?? "附近餐厅",
                    pricePerPerson: 120,
                    votes: [],
                    poiId: item.url?.absoluteString
                )
            }

            if results.isEmpty {
                errorMessage = "附近没有找到更合适的结果，试试更具体的关键词。"
            }
        } catch is CancellationError {
            return
        } catch {
            guard latestSearchToken == token else { return }
            results = []
            errorMessage = "MapKit 搜索失败，请检查网络或定位权限后再试。"
        }
    }

    func scheduleSearch(near center: CLLocationCoordinate2D) {
        pendingSearchTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = nil
            isSearching = false
            return
        }

        pendingSearchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled else { return }
            await self?.search(keyword: trimmed, near: center)
        }
    }
}

private final class DeviceLocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private(set) var locationPoint: LocationPoint?
    @Published private(set) var isSharing = false

    private let manager = CLLocationManager()
    private var isRequestingSingleLocation = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 20
    }

    func requestPermission() {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }

    func requestCurrentLocation() {
        authorizationStatus = manager.authorizationStatus
        isRequestingSingleLocation = true

        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            isRequestingSingleLocation = false
        }
    }

    func setSharingEnabled(_ enabled: Bool) {
        isSharing = enabled

        guard enabled else {
            manager.stopUpdatingLocation()
            locationPoint = nil
            return
        }

        requestPermission()
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            authorizationStatus = status
            if isRequestingSingleLocation, (authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse) {
                manager.requestLocation()
            }
            if isSharing, (authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse) {
                manager.startUpdatingLocation()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let point = LocationPoint(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            timestamp: Date()
        )
        Task { @MainActor in
            isRequestingSingleLocation = false
            locationPoint = point
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            isRequestingSingleLocation = false
        }
    }
}
