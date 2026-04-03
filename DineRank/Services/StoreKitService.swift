import Foundation
import StoreKit
#if canImport(WidgetKit)
import WidgetKit
#endif

enum StoreKitServiceError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        L10n.string("交易校验失败，请稍后重试。")
    }
}

enum StorePurchaseStatus: Equatable {
    case idle
    case loadingProducts
    case purchasing(String)
    case pending
    case restored
    case completed(String)
    case failed(String)
}

@MainActor
final class StoreEntitlementStore: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var entitlement: StoreEntitlementSnapshot
    @Published private(set) var purchaseStatus: StorePurchaseStatus = .idle
    @Published private(set) var storefront: Storefront?
    @Published private(set) var isLoadingProducts = false
    @Published var lastErrorMessage: String?

    private var updatesTask: Task<Void, Never>?
    private var isRefreshingEntitlements = false
    private var hasStarted = false

    init() {
        entitlement = SharedDefaults.loadStoreEntitlement()
    }

    deinit {
        updatesTask?.cancel()
    }

    func startIfNeeded() async {
        guard !hasStarted else { return }
        hasStarted = true

        guard !AppRuntime.isUITesting else { return }

        updatesTask = Task.detached(priority: .background) { [weak self] in
            guard let self else { return }
            for await update in Transaction.updates {
                await self.process(transactionResult: update, shouldFinish: true)
            }
        }

        await refreshProducts()
        await refreshEntitlements()
    }

    var hasProAccess: Bool {
        entitlement.hasProAccess
    }

    var availableProducts: [Product] {
        products.sorted { lhs, rhs in
            sortIndex(for: lhs.id) < sortIndex(for: rhs.id)
        }
    }

    var storefrontSummary: String {
        guard let storefront else { return L10n.string("未获取") }
        return "\(storefront.countryCode) / \(storefront.id)"
    }

    func refreshProducts() async {
        guard !isLoadingProducts else { return }

        isLoadingProducts = true
        purchaseStatus = .loadingProducts
        defer {
            isLoadingProducts = false
            if case .loadingProducts = purchaseStatus {
                purchaseStatus = .idle
            }
        }

        do {
            let fetched = try await Product.products(for: TemplateProduct.publiclyOfferedProducts.map(\.rawValue))
            products = fetched.sorted { lhs, rhs in
                sortIndex(for: lhs.id) < sortIndex(for: rhs.id)
            }
        } catch {
            lastErrorMessage = L10n.string("商品信息加载失败，请先在 App Store Connect 或本地 StoreKit 配置中补齐商品。")
        }
    }

    func refreshEntitlements() async {
        guard !isRefreshingEntitlements else { return }
        isRefreshingEntitlements = true
        defer { isRefreshingEntitlements = false }

        storefront = await Storefront.current

        var unlockedProductIDs = Set<String>()

        for await result in Transaction.currentEntitlements {
            guard case let .verified(transaction) = result else { continue }
            guard TemplateProduct(rawValue: transaction.productID) != nil else { continue }
            guard transaction.revocationDate == nil else { continue }

            if let expirationDate = transaction.expirationDate, expirationDate < Date() {
                continue
            }

            unlockedProductIDs.insert(transaction.productID)
        }

        apply(
            StoreEntitlementSnapshot(
                unlockedProductIDs: unlockedProductIDs.sorted { sortIndex(for: $0) < sortIndex(for: $1) },
                updatedAt: Date()
            )
        )
    }

    func purchase(_ product: Product) async {
        purchaseStatus = .purchasing(product.id)
        lastErrorMessage = nil

        do {
            let result = try await product.purchase()

            switch result {
            case let .success(verification):
                let transaction = try verified(verification)
                await transaction.finish()
                await refreshEntitlements()
                purchaseStatus = .completed(product.id)

            case .pending:
                purchaseStatus = .pending

            case .userCancelled:
                purchaseStatus = .idle

            @unknown default:
                purchaseStatus = .failed(L10n.string("出现未知购买状态。"))
            }
        } catch {
            purchaseStatus = .failed(error.localizedDescription)
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            purchaseStatus = .restored
        } catch {
            purchaseStatus = .failed(L10n.string("恢复购买失败，请检查账号状态后重试。"))
        }
    }

    private func process(transactionResult: VerificationResult<Transaction>, shouldFinish: Bool) async {
        do {
            let transaction = try verified(transactionResult)
            guard TemplateProduct(rawValue: transaction.productID) != nil else { return }
            if shouldFinish {
                await transaction.finish()
            }
            await refreshEntitlements()
        } catch {
            lastErrorMessage = L10n.string("交易校验失败，请稍后重试。")
        }
    }

    private func verified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case let .verified(payload):
            payload
        case .unverified:
            throw StoreKitServiceError.failedVerification
        }
    }

    private func apply(_ snapshot: StoreEntitlementSnapshot) {
        entitlement = snapshot
        SharedDefaults.saveStoreEntitlement(snapshot)

        guard AppRuntime.allowsWidgetRefresh else { return }

        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }

    private func sortIndex(for id: String) -> Int {
        TemplateProduct.allCases.firstIndex { $0.rawValue == id } ?? .max
    }
}
