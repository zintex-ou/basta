import SwiftUI

@main
struct BastaApp: App {
    @StateObject private var model = AppModel()
    @StateObject private var purchases = PurchaseService.shared
    @StateObject private var location = LocationService.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(model)
                .environmentObject(purchases)
                .environmentObject(location)
                .tint(Theme.accent)
                .preferredColorScheme(.dark)
        }
    }
}

/// Onboarding → Paywall → Home. Hard paywall: no free tier.
struct RootView: View {
    @EnvironmentObject var model: AppModel
    @EnvironmentObject var purchases: PurchaseService

    var body: some View {
        Group {
            if !model.onboardingDone {
                OnboardingView()
            } else if purchases.isLoading {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity).background(Theme.bg)
            } else if !purchases.isSubscribed {
                PaywallView()
            } else {
                HomeView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: model.onboardingDone)
        .animation(.easeInOut(duration: 0.25), value: purchases.isSubscribed)
    }
}
