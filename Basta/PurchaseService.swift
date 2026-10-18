import Foundation
import StoreKit

/// StoreKit 2 subscriptions. Hard paywall: without an active
/// entitlement the app shows the paywall and nothing else.
@MainActor
final class PurchaseService: ObservableObject {
    static let shared = PurchaseService()

    enum ProductID: String, CaseIterable {
        case weekly = "com.zintex.basta.weekly"
        case yearly = "com.zintex.basta.yearly"
    }

    @Published private(set) var products: [Product] = []
    @Published private(set) var isSubscribed = false
    @Published private(set) var isLoading = true

    private var updates: Task<Void, Never>?

    private init() {
        updates = Task { await listenForTransactions() }
        Task {
            await loadProducts()
            await refreshEntitlements()
            isLoading = false
        }
    }

    deinit { updates?.cancel() }

    func loadProducts() async {
        do {
            let ids = ProductID.allCases.map(\.rawValue)
            products = try await Product.products(for: ids).sorted { $0.price < $1.price }
        } catch {
            products = []
        }
    }

    func product(_ id: ProductID) -> Product? {
        products.first { $0.id == id.rawValue }
    }

    @discardableResult
    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let tx) = verification {
                    await tx.finish()
                    await refreshEntitlements()
                    return true
                }
                return false
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            return false
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await refreshEntitlements()
    }

    func refreshEntitlements() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result,
               tx.productType == .autoRenewable,
               tx.revocationDate == nil {
                active = true
                break
            }
        }
        isSubscribed = active
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            if case .verified(let tx) = result {
                await tx.finish()
                await refreshEntitlements()
            }
        }
    }
}
