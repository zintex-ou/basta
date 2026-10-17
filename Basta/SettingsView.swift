import SwiftUI
import DeviceActivity

struct SettingsView: View {
    @EnvironmentObject var purchases: PurchaseService
    @EnvironmentObject var location: LocationService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("settings.report") {
                    // DeviceActivityReport renders inside the CalmaReport extension sandbox;
                    // the app never sees raw usage data.
                    DeviceActivityReport(.init("today"), filter: todayFilter)
                        .frame(minHeight: 220)
                        .listRowBackground(Color.clear)
                }
                Section("settings.permissions") {
                    LabeledContent("settings.location") {
                        Text(locationText).foregroundStyle(Theme.textDim)
                    }
                    Button("settings.openSettings") {
                        if let u = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(u) }
                    }
                }
                Section("settings.subscription") {
                    Button("pw.restore") { Task { await purchases.restore() } }
                    Button("settings.manage") {
                        if let u = URL(string: "https://apps.apple.com/account/subscriptions") { UIApplication.shared.open(u) }
                    }
                }
                Section {
                    Link("settings.support", destination: URL(string: "mailto:support@basta.app")!)
                    Link("pw.privacy", destination: URL(string: "https://basta.app/privacy")!)
                    Link("pw.terms", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.bg)
            .navigationTitle("settings.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("settings.done") { dismiss() } } }
        }
        .preferredColorScheme(.dark)
    }

    private var todayFilter: DeviceActivityFilter {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        return DeviceActivityFilter(
            segment: .daily(during: DateInterval(start: start, end: Date())),
            users: .all,
            devices: .init([.iPhone])
        )
    }

    private var locationText: String {
        switch location.status {
        case .authorizedAlways: return String(localized: "settings.location.always")
        case .authorizedWhenInUse: return String(localized: "settings.location.inUse")
        case .denied, .restricted: return String(localized: "settings.location.denied")
        default: return String(localized: "settings.location.none")
        }
    }
}
