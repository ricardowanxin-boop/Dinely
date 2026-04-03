import StoreKit
import SwiftUI

struct CapabilitiesScreen: View {
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var settingsStore: AppSettingsStore
    @ObservedObject var storeEntitlementStore: StoreEntitlementStore
    @ObservedObject var liveActivityManager: LiveActivityManager

    @State private var backgroundRefreshStatus = SharedDefaults.loadBackgroundRefreshStatus()

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    networkCard
                    liveActivityCard
                    storeKitCard
                    backgroundRefreshCard
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .navigationTitle("通用能力")
        .onAppear {
            backgroundRefreshStatus = SharedDefaults.loadBackgroundRefreshStatus()
        }
    }

    private var networkCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            TemplateSectionHeader(
                title: L10n.string("网络请求"),
                subtitle: L10n.string("演示 APIClient + Repository + 本地缓存回退")
            )

            KeyValueRow(title: "Base URL", value: AppConfig.apiBaseURL.absoluteString)
            KeyValueRow(title: "Endpoint", value: AppConfig.demoEndpointPath)
            KeyValueRow(title: L10n.string("最近同步"), value: DisplayFormatters.timestamp(viewModel.snapshot.fetchedAt))

            Button("重新请求示例接口") {
                Task {
                    await viewModel.refresh(showNotification: false)
                }
            }
            .buttonStyle(TemplatePrimaryButtonStyle())
        }
        .templateSurface()
    }

    private var liveActivityCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            TemplateSectionHeader(
                title: L10n.string("Widget 与灵动岛"),
                subtitle: L10n.string("共享同一份 `TemplateSnapshot` 数据结构")
            )

            KeyValueRow(title: "App Group", value: AppConfig.appGroupID)
            KeyValueRow(title: L10n.string("系统支持"), value: liveActivityManager.isSupported ? L10n.string("已开启") : L10n.string("未开启"))
            KeyValueRow(title: L10n.string("当前 Activity"), value: liveActivityManager.hasActiveActivity ? L10n.string("运行中") : L10n.string("未启动"))

            AdaptiveButtonGroup {
                Button("启动 / 更新灵动岛") {
                    Task {
                        await liveActivityManager.start(snapshot: viewModel.snapshot)
                    }
                }
                .buttonStyle(TemplatePrimaryButtonStyle())
            } secondary: {
                Button("结束灵动岛") {
                    Task {
                        await liveActivityManager.stopAll(using: viewModel.snapshot)
                    }
                }
                .buttonStyle(TemplateSecondaryButtonStyle())
            }

            Button("写入共享快照并刷新组件") {
                viewModel.writeSampleSnapshot()
            }
            .buttonStyle(TemplateSecondaryButtonStyle())
        }
        .templateSurface()
    }

    private var storeKitCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            TemplateSectionHeader(
                title: "StoreKit 2",
                subtitle: L10n.string("已经接好商品加载、购买、恢复购买与权益快照")
            )

            KeyValueRow(title: L10n.string("当前权益"), value: storeEntitlementStore.entitlement.currentProduct?.title ?? L10n.string("免费版"))
            KeyValueRow(title: "Storefront", value: storeEntitlementStore.storefrontSummary)
            KeyValueRow(title: L10n.string("购买状态"), value: purchaseStatusTitle(storeEntitlementStore.purchaseStatus))

            if storeEntitlementStore.availableProducts.isEmpty {
                ForEach(TemplateProduct.publiclyOfferedProducts) { product in
                    TemplateSettingsRow(
                        title: product.title,
                        detail: "\(product.rawValue)\n\(product.subtitle)",
                        systemImage: "cart"
                    )
                }
            } else {
                ForEach(storeEntitlementStore.availableProducts, id: \.id) { product in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(product.displayName)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(AppTheme.textPrimary)

                        Text(product.description)
                            .font(.footnote)
                            .foregroundStyle(AppTheme.textSecondary)

                        ViewThatFits(in: .horizontal) {
                            HStack(alignment: .center, spacing: 12) {
                                Text(product.displayPrice)
                                    .font(.title3.weight(.black))
                                    .foregroundStyle(AppTheme.copperSoft)

                                Spacer(minLength: 12)

                                Button("购买") {
                                    Task {
                                        await storeEntitlementStore.purchase(product)
                                    }
                                }
                                .buttonStyle(TemplateSecondaryButtonStyle())
                                .frame(maxWidth: 160)
                            }

                            VStack(alignment: .leading, spacing: 12) {
                                Text(product.displayPrice)
                                    .font(.title3.weight(.black))
                                    .foregroundStyle(AppTheme.copperSoft)

                                Button("购买") {
                                    Task {
                                        await storeEntitlementStore.purchase(product)
                                    }
                                }
                                .buttonStyle(TemplateSecondaryButtonStyle())
                            }
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(AppTheme.surfaceTint)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(AppTheme.divider, lineWidth: 1)
                    )
                }
            }

            Button("恢复购买") {
                Task {
                    await storeEntitlementStore.restorePurchases()
                }
            }
            .buttonStyle(TemplatePrimaryButtonStyle())
        }
        .templateSurface()
    }

    private var backgroundRefreshCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            TemplateSectionHeader(
                title: L10n.string("后台刷新与通知"),
                subtitle: L10n.string("演示登记 BGAppRefreshTask 并在完成后发通知")
            )

            KeyValueRow(title: L10n.string("任务标识"), value: AppConfig.backgroundRefreshTaskIdentifier)
            KeyValueRow(title: L10n.string("开关状态"), value: settingsStore.settings.backgroundRefreshEnabled ? L10n.string("已开启") : L10n.string("已关闭"))
            KeyValueRow(title: L10n.string("最近登记"), value: statusText(backgroundRefreshStatus.lastScheduledAt))
            KeyValueRow(title: L10n.string("最近成功"), value: statusText(backgroundRefreshStatus.lastSuccessAt))
            KeyValueRow(title: L10n.string("当前结果"), value: backgroundRefreshStatus.outcome.title)

            if let lastErrorMessage = backgroundRefreshStatus.lastErrorMessage {
                Text(lastErrorMessage)
                    .font(.footnote)
                    .foregroundStyle(AppTheme.rose)
            }

            AdaptiveButtonGroup {
                Button("申请通知权限") {
                    Task {
                        await NotificationManager.shared.requestAuthorization()
                    }
                }
                .buttonStyle(TemplateSecondaryButtonStyle())
            } secondary: {
                Button("立即登记刷新") {
                    Task {
                        await BackgroundRefreshService.shared.schedule(force: true)
                        backgroundRefreshStatus = SharedDefaults.loadBackgroundRefreshStatus()
                    }
                }
                .buttonStyle(TemplatePrimaryButtonStyle())
            }
        }
        .templateSurface()
    }

    private func purchaseStatusTitle(_ status: StorePurchaseStatus) -> String {
        switch status {
        case .idle:
            L10n.string("空闲")
        case .loadingProducts:
            L10n.string("正在加载商品")
        case let .purchasing(productID):
            L10n.format("购买中：%@", productID)
        case .pending:
            L10n.string("等待确认")
        case .restored:
            L10n.string("已恢复购买")
        case let .completed(productID):
            L10n.format("已完成：%@", productID)
        case let .failed(message):
            message
        }
    }

    private func statusText(_ date: Date?) -> String {
        guard let date else { return L10n.string("暂无") }
        return DisplayFormatters.timestamp(date)
    }
}
