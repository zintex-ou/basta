import SwiftUI
import StoreKit

/// Hard paywall, no free trial. Yearly preselected; weekly as the escape hatch.
struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseService
    @State private var selected: PurchaseService.ProductID = .yearly
    @State private var busy = false

    private var yearly: Product? { purchases.product(.yearly) }
    private var weekly: Product? { purchases.product(.weekly) }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer(minLength: 24)
            Text("pw.title").font(.largeTitle.bold())
            Text("pw.subtitle").foregroundStyle(Theme.textDim)

            VStack(alignment: .leading, spacing: 10) {
                bullet("pw.b1"); bullet("pw.b2"); bullet("pw.b3"); bullet("pw.b4")
            }

            Spacer()

            if let y = yearly {
                planCard(product: y, id: .yearly, title: "pw.yearly", badge: "pw.best")
            }
            if let w = weekly {
                planCard(product: w, id: .weekly, title: "pw.weekly", badge: nil)
            }

            PrimaryButton(title: "pw.cta", disabled: busy || purchases.products.isEmpty) {
                guard let p = purchases.product(selected) ?? yearly else { return }
                busy = true
                Task { await purchases.purchase(p); busy = false }
            }

            HStack {
                SecondaryButton(title: "pw.restore") { Task { await purchases.restore() } }
                Link("pw.terms", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    .font(.subheadline).foregroundStyle(Theme.textDim).frame(maxWidth: .infinity)
                Link("pw.privacy", destination: URL(string: "https://basta.app/privacy")!)
                    .font(.subheadline).foregroundStyle(Theme.textDim).frame(maxWidth: .infinity)
            }
            Text("pw.legal").font(.caption2).foregroundStyle(Theme.textDim.opacity(0.7))
        }
        .padding(Theme.pad)
        .screen()
    }

    private func bullet(_ key: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill").foregroundStyle(Theme.success)
            Text(key)
        }
    }

    private func planCard(product: Product, id: PurchaseService.ProductID,
                          title: LocalizedStringKey, badge: LocalizedStringKey?) -> some View {
        Button { selected = id } label: {
            Card(highlighted: selected == id) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(title).font(.headline)
                            if let b = badge {
                                Text(b).font(.caption2.bold())
                                    .padding(.horizontal, 8).padding(.vertical, 3)
                                    .background(Theme.accent).foregroundStyle(.black)
                                    .clipShape(Capsule())
                            }
                        }
                        Text(product.displayPrice + " " + period(product))
                            .font(.subheadline).foregroundStyle(Theme.textDim)
                    }
                    Spacer()
                    Image(systemName: selected == id ? "largecircle.fill.circle" : "circle")
                        .foregroundStyle(selected == id ? Theme.accent : Theme.textDim)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func period(_ p: Product) -> String {
        guard let unit = p.subscription?.subscriptionPeriod.unit else { return "" }
        switch unit {
        case .week: return String(localized: "pw.perWeek")
        case .year: return String(localized: "pw.perYear")
        case .month: return String(localized: "pw.perMonth")
        default: return ""
        }
    }
}
