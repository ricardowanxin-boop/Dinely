import StoreKit
import SwiftUI
import UIKit

struct SettingsScreen: View {
    @ObservedObject var settingsStore: AppSettingsStore
    @ObservedObject var storeEntitlementStore: StoreEntitlementStore
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                productCard
                preferenceCard
                legalSupportCard
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, TemplateLayoutMetrics.tabBarClearance)
        }
        .background(AppBackgroundView())
        .accessibilityIdentifier("settings-screen")
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.large)
        .rootChromeVisible(true)
    }

    private var productCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            TemplateSectionHeader(
                title: "\(viewModel.localizedBrandName) Pro",
                subtitle: "当前版本只开放一次性买断 Pro。买断不自动续费，可解锁更大的饭局人数上限、圈子排行榜和高清战报卡。"
            )

            KeyValueRow(title: "当前权益", value: storeEntitlementStore.entitlement.currentProduct?.title ?? "免费版")
            KeyValueRow(title: "购买类型", value: "一次性买断，不自动续费")
            KeyValueRow(title: "人数上限", value: "免费版 \(AppConfig.maximumFreeParticipants) 人 · Pro \(AppConfig.maximumProParticipants) 人")

            ForEach(TemplateProduct.publiclyOfferedProducts) { product in
                VStack(alignment: .leading, spacing: 12) {
                    TemplateSettingsRow(
                        title: product.title,
                        detail: product.subtitle,
                        systemImage: "crown"
                    )

                    if let liveProduct = storeProduct(for: product) {
                        HStack(spacing: 12) {
                            Text(liveProduct.displayPrice)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(AppTheme.textPrimary)

                            Spacer()

                            if storeEntitlementStore.entitlement.unlockedProductIDs.contains(product.rawValue) {
                                Text("已解锁")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(AppTheme.mint)
                            } else {
                                Button("立即买断") {
                                    Task {
                                        await storeEntitlementStore.purchase(liveProduct)
                                    }
                                }
                                .buttonStyle(TemplateSecondaryButtonStyle())
                            }
                        }
                    } else {
                        Text("当前版本只提供一次性买断 Pro，价格会在 App Store 商品就绪后显示。")
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                }
                .padding(.vertical, 4)
            }

            HStack(spacing: 12) {
                Button("恢复购买") {
                    Task {
                        await storeEntitlementStore.restorePurchases()
                    }
                }
                .buttonStyle(TemplateSecondaryButtonStyle())

                Spacer()

                if case let .failed(message) = storeEntitlementStore.purchaseStatus {
                    Text(message)
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.rose)
                        .multilineTextAlignment(.trailing)
                }
            }

            Text("买断版不会自动续费。购买或恢复前，你可以先查看《隐私政策》和《服务条款 / EULA》。")
                .font(.system(size: 12))
                .foregroundStyle(AppTheme.textSecondary)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 10) {
                    legalChip(
                        title: "隐私政策",
                        systemImage: "hand.raised",
                        identifier: "settings-privacy-policy",
                        destination: LegalDocumentScreen(document: .privacyPolicy)
                    )
                    legalChip(
                        title: "服务条款",
                        systemImage: "doc.text",
                        identifier: "settings-terms",
                        destination: LegalDocumentScreen(document: .terms)
                    )
                    legalChip(
                        title: "联系支持",
                        systemImage: "questionmark.bubble",
                        identifier: "settings-support-shortcut",
                        destination: SupportCenterScreen()
                    )
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        legalChip(
                            title: "隐私政策",
                            systemImage: "hand.raised",
                            identifier: "settings-privacy-policy",
                            destination: LegalDocumentScreen(document: .privacyPolicy)
                        )
                        legalChip(
                            title: "服务条款",
                            systemImage: "doc.text",
                            identifier: "settings-terms",
                            destination: LegalDocumentScreen(document: .terms)
                        )
                    }

                    legalChip(
                        title: "联系支持",
                        systemImage: "questionmark.bubble",
                        identifier: "settings-support-shortcut",
                        destination: SupportCenterScreen()
                    )
                }
            }
        }
        .templateSurface(highlighted: true)
    }

    private func storeProduct(for product: TemplateProduct) -> Product? {
        storeEntitlementStore.availableProducts.first { $0.id == product.rawValue }
    }

    private var preferenceCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            TemplateSectionHeader(
                title: "偏好设置",
                subtitle: "这里保留真正对使用体验有影响的开关，不再展示仅用于开发或测试的内部配置。"
            )

            TemplateSegmentedControl(
                options: AppAppearance.allCases,
                selection: $settingsStore.settings.appearance,
                title: { $0.title }
            )

            Toggle(isOn: $settingsStore.settings.liveActivitiesEnabled) {
                TemplateSettingsRow(
                    title: "启用 Live Activity",
                    detail: "让约饭状态和守约战报同步到锁屏与灵动岛。",
                    systemImage: "pill"
                )
            }
            .tint(AppTheme.copper)

            Toggle(isOn: $settingsStore.settings.backgroundRefreshEnabled) {
                TemplateSettingsRow(
                    title: "启用后台刷新",
                    detail: "允许系统在后台同步首页概览和 Widget 快照。",
                    systemImage: "clock.arrow.circlepath"
                )
            }
            .tint(AppTheme.copper)
        }
        .templateSurface()
    }

    private var legalSupportCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            TemplateSectionHeader(
                title: "隐私与支持",
                subtitle: "审核需要的隐私、条款、免责声明、数据来源和支持入口都集中保留在这里，方便随时重新查看。"
            )

            navigationRow(
                title: "隐私政策",
                detail: "说明本地数据、CloudKit 协作、定位权限和购买信息如何处理。",
                systemImage: "hand.raised",
                identifier: "settings-privacy-policy-row",
                destination: LegalDocumentScreen(document: .privacyPolicy)
            )

            Divider()
                .overlay(AppTheme.divider)

            navigationRow(
                title: "服务条款 / EULA",
                detail: "说明产品许可边界、一次性买断规则，以及 Apple 标准 EULA 的适用关系。",
                systemImage: "doc.text",
                identifier: "settings-terms-row",
                destination: LegalDocumentScreen(document: .terms)
            )

            Divider()
                .overlay(AppTheme.divider)

            navigationRow(
                title: "免责声明",
                detail: "解释地图、定位、通知、AA 计算与分享内容的使用边界。",
                systemImage: "exclamationmark.triangle",
                identifier: "settings-disclaimer-row",
                destination: LegalDocumentScreen(document: .disclaimer)
            )

            Divider()
                .overlay(AppTheme.divider)

            navigationRow(
                title: "数据来源与地图说明",
                detail: "说明餐厅搜索、地图数据、CloudKit 协作和大陆地区地图署名逻辑。",
                systemImage: "map",
                identifier: "settings-data-source-row",
                destination: LegalDocumentScreen(document: .dataSource)
            )

            Divider()
                .overlay(AppTheme.divider)

            navigationRow(
                title: "联系支持",
                detail: "查看支持邮箱、版本号、地图方案与问题反馈方式。",
                systemImage: "questionmark.bubble",
                identifier: "settings-support-center",
                destination: SupportCenterScreen()
            )
        }
        .templateSurface()
    }

    private func legalChip<Destination: View>(
        title: String,
        systemImage: String,
        identifier: String,
        destination: Destination
    ) -> some View {
        NavigationLink {
            destination
        } label: {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.caption.weight(.semibold))
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(AppTheme.copper)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppTheme.copper.opacity(0.12), in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
    }

    private func navigationRow<Destination: View>(
        title: String,
        detail: String,
        systemImage: String,
        identifier: String,
        destination: Destination
    ) -> some View {
        NavigationLink {
            destination
        } label: {
            HStack(spacing: 12) {
                TemplateSettingsRow(
                    title: title,
                    detail: detail,
                    systemImage: systemImage
                )

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.textTertiary)
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
    }
}

struct ComplianceNoticeSheet: View {
    @Environment(\.openURL) private var openURL
    let onContinue: () -> Void

    private let highlights: [(title: String, detail: String, systemImage: String)] = [
        ("产品说明", "食否 / Dinely 用于发起约饭、时间投票、餐厅选择、签到和 AA 战报，不提供与聚餐无关的后台采集。", "fork.knife"),
        ("隐私与定位", "定位权限只在约饭当天地图和自动签到场景中使用；关闭权限后，其他核心流程仍可继续。", "location"),
        ("数据与同步", "本地会保存你的草稿、偏好和约饭记录；当你分享饭局时，事件标题、参与人昵称和投票数据会通过 Apple CloudKit 协作同步。", "externaldrive.badge.icloud"),
        ("付费说明", "当前版本仅提供一次性买断 Pro，不会自动续费；恢复购买与隐私、条款入口可在设置页随时查看。", "creditcard")
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                TemplateSectionHeader(
                    title: "首次使用说明",
                    subtitle: "为了让审核员和真实用户都能快速理解产品用途、边界和隐私处理方式，这些关键信息会在首次启动时集中说明一次。"
                )

                ForEach(highlights, id: \.title) { item in
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: item.systemImage)
                            .font(.headline)
                            .foregroundStyle(AppTheme.copper)
                            .frame(width: 24, height: 24)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.title)
                                .font(.headline)
                                .foregroundStyle(AppTheme.textPrimary)
                            Text(item.detail)
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .templateSurface(highlighted: item.title == (highlights.first?.title ?? ""))
                }

                Text("完整的《隐私政策》《服务条款 / EULA》《免责声明》《数据来源说明》和“联系支持”入口，都可以在设置页随时重新打开。")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.horizontal, 4)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .background(AppBackgroundView())
        .navigationTitle("使用前说明")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            BottomActionBar {
                Button("我已了解，继续使用") {
                    onContinue()
                }
                .buttonStyle(TemplatePrimaryButtonStyle())
            } secondaryAction: {
                Button("查看服务条款") {
                    openURL(AppConfig.standardEULAURL)
                }
                .buttonStyle(TemplateSecondaryButtonStyle())
            }
        }
    }
}

private enum LegalDocument: String, Identifiable, CaseIterable {
    case privacyPolicy
    case terms
    case disclaimer
    case dataSource

    var id: String { rawValue }

    var title: String {
        switch self {
        case .privacyPolicy:
            "隐私政策"
        case .terms:
            "服务条款 / EULA"
        case .disclaimer:
            "免责声明"
        case .dataSource:
            "数据来源与地图说明"
        }
    }

    var subtitle: String {
        switch self {
        case .privacyPolicy:
            "说明应用收集、存储、同步和权限使用方式。"
        case .terms:
            "说明许可范围、买断权益和 Apple 标准 EULA 的适用。"
        case .disclaimer:
            "说明地图、定位、提醒、AA 与战报等能力的使用边界。"
        case .dataSource:
            "说明地图服务、餐厅搜索、CloudKit 协作和大陆地区署名逻辑。"
        }
    }

    var sections: [(title: String, body: String)] {
        let brandName = AppConfig.localizedBrandName()

        switch self {
        case .privacyPolicy:
            return [
                (
                    "1. 我们处理哪些数据",
                    "\(brandName) 不要求你注册开发者自有账号。应用会在当前设备保存草稿、约饭记录、段位档案、主题偏好、通知与 Live Activity 开关等必要信息。"
                ),
                (
                    "2. 云端协作与共享",
                    "当你创建可分享的约饭局时，饭局标题、参与人昵称、头像 Emoji、时间投票、餐厅投票、签到状态以及位置共享开关等协作数据会同步到 Apple CloudKit，以便受邀参与者加入同一场饭局。我们不会将这些数据出售给广告平台，也不会用于画像投放。"
                ),
                (
                    "3. 定位、地图与权限",
                    "定位权限仅用于约饭当天地图页显示你距离餐厅还有多远，以及支持自动签到。地图展示与餐厅搜索使用 Apple MapKit；在中国大陆，地图底图可能显示高德地图署名。关闭定位权限后，投票、分享、AA 与战报功能仍可继续使用。"
                ),
                (
                    "4. 购买与支付信息",
                    "Pro 为一次性买断数字功能，由 Apple App Store 完成支付、恢复购买和账单处理。我们不会接触你的银行卡、Apple ID 密码或支付凭证原文。"
                ),
                (
                    "5. 删除、撤回与联系",
                    "你可以通过系统设置撤回定位或通知权限，也可以删除 App 清除本地缓存数据。若需反馈隐私相关问题，请通过 \(AppConfig.supportEmail) 联系支持。"
                )
            ]
        case .terms:
            return [
                (
                    "1. 使用许可",
                    "\(brandName) 面向约饭组织、时间投票、餐厅选择、签到、AA 记录和战报分享场景提供数字化工具。你不得将本应用用于违法活动、骚扰他人或规避平台规则。"
                ),
                (
                    "2. Pro 买断说明",
                    "当前版本仅提供一次性买断 Pro。买断后可解锁更高人数上限、圈子排行榜和高清战报图片导出；买断不会自动续费，恢复购买由 Apple 提供。"
                ),
                (
                    "3. 服务变更与可用性",
                    "我们会持续优化地图搜索、CloudKit 协作与分享能力，但不会承诺所有第三方服务在任何地区、任何网络环境下始终可用。"
                ),
                (
                    "4. Apple 标准 EULA",
                    "除本页面的产品说明外，应用的授权使用同时适用 Apple Standard Licensed Application End User License Agreement。你可以在本页底部打开 Apple 官方版本查看完整文本。"
                )
            ]
        case .disclaimer:
            return [
                (
                    "1. 产品边界",
                    "\(brandName) 是熟人约饭协作工具，不构成交通、消费、法律、医疗或其他专业建议。"
                ),
                (
                    "2. 地图与定位边界",
                    "餐厅搜索结果、距离计算和导航跳转依赖系统地图、设备定位、网络环境与第三方地图服务，可能存在延迟、偏差或临时不可用。"
                ),
                (
                    "3. 通知与后台边界",
                    "提醒、后台刷新、Live Activity 与 Widget 受系统调度、权限配置、电量策略与网络状态影响，不能承诺绝对实时。"
                ),
                (
                    "4. AA 与战报边界",
                    "AA 结果和战报仅用于聚餐协作与分享展示，最终付款、收款与实际出席情况仍应以参与人线下确认结果为准。"
                )
            ]
        case .dataSource:
            return [
                (
                    "1. 用户输入数据",
                    "饭局标题、时间候选、预算、参与人昵称、头像 Emoji、餐厅偏好和签到结果主要来自用户主动输入与投票。"
                ),
                (
                    "2. 地图与 POI 数据",
                    "地图显示、地理编码、附近餐厅搜索和距离计算使用 Apple MapKit 与系统定位能力；中国大陆地区可能显示高德地图署名，这是 Apple 地图在该地区的数据提供关系。"
                ),
                (
                    "3. 云端同步",
                    "多人协作饭局通过 Apple CloudKit 同步元数据、参与人和投票记录。若用户未登录 iCloud、CloudKit 不可用或网络异常，应用会回退到本地缓存。"
                ),
                (
                    "4. 购买与许可数据",
                    "数字权益解锁依赖 Apple StoreKit。应用会读取购买结果和恢复状态，以决定是否开放 Pro 权益。"
                )
            ]
        }
    }
}

private struct LegalDocumentScreen: View {
    @Environment(\.openURL) private var openURL
    let document: LegalDocument

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                TemplateSectionHeader(
                    title: document.title,
                    subtitle: document.subtitle
                )

                ForEach(document.sections, id: \.title) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.title)
                            .font(.headline)
                            .foregroundStyle(AppTheme.textPrimary)
                        Text(section.body)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .templateSurface()
                }

                if document == .terms {
                    Button {
                        openURL(AppConfig.standardEULAURL)
                    } label: {
                        Label("查看 Apple 标准 EULA 官方原文", systemImage: "arrow.up.right.square")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(TemplateSecondaryButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .background(AppBackgroundView())
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SupportCenterScreen: View {
    @Environment(\.openURL) private var openURL
    private var mailURL: URL {
        URL(string: "mailto:\(AppConfig.supportEmail)")!
    }

    private var versionSummary: String {
        let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(shortVersion) (\(build))"
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                TemplateSectionHeader(
                    title: "联系支持",
                    subtitle: "当你需要反馈闪退、地图问题、购买恢复或隐私相关问题时，可以按这里的信息联系开发者。"
                )

                VStack(alignment: .leading, spacing: 12) {
                    KeyValueRow(title: "支持邮箱", value: AppConfig.supportEmail)
                    KeyValueRow(title: "当前版本", value: versionSummary)
                    KeyValueRow(title: "地图方案", value: AppConfig.mapProviderName)
                    KeyValueRow(title: "付费方式", value: "一次性买断 Pro（不自动续费）")
                }
                .templateSurface()

                VStack(alignment: .leading, spacing: 12) {
                    Text("建议反馈时一并提供")
                        .font(.headline)
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("1. 设备型号和系统版本\n2. 复现步骤\n3. 问题截图或录屏\n4. 触发问题的饭局标题")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .templateSurface()

                AdaptiveButtonGroup {
                    Button {
                        openURL(mailURL)
                    } label: {
                        Text("发邮件联系支持")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(TemplatePrimaryButtonStyle())
                } secondary: {
                    Button("复制支持邮箱") {
                        UIPasteboard.general.string = AppConfig.supportEmail
                    }
                    .buttonStyle(TemplateSecondaryButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .background(AppBackgroundView())
        .navigationTitle("联系支持")
        .navigationBarTitleDisplayMode(.inline)
    }
}
