import DeviceActivity
import SwiftUI

/// Renders today's screen time in the app's Settings screen.
/// Runs in Apple's sandbox — usage data never reaches the main app.
@main
struct BastaReportExtension: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        TodayReport { TodayView(data: $0) }
    }
}

struct TodayData {
    var total: TimeInterval = 0
    var top: [(name: String, seconds: TimeInterval)] = []
}

struct TodayReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .init("today")
    let content: (TodayData) -> TodayView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> TodayData {
        var out = TodayData()
        var perApp: [String: TimeInterval] = [:]
        for await d in data {
            for await seg in d.activitySegments {
                out.total += seg.totalActivityDuration
                for await cat in seg.categories {
                    for await app in cat.applications {
                        let name = app.application.localizedDisplayName ?? "—"
                        perApp[name, default: 0] += app.totalActivityDuration
                    }
                }
            }
        }
        out.top = perApp.sorted { $0.value > $1.value }.prefix(5).map { ($0.key, $0.value) }
        return out
    }
}

struct TodayView: View {
    let data: TodayData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(format(data.total)).font(.system(size: 40, weight: .bold, design: .rounded))
            Text("report.today").font(.subheadline).foregroundStyle(.secondary)
            ForEach(data.top, id: \.name) { row in
                HStack {
                    Text(row.name).lineLimit(1)
                    Spacer()
                    Text(format(row.seconds)).foregroundStyle(.secondary).monospacedDigit()
                }
                .font(.subheadline)
            }
        }
        .padding(.vertical, 8)
    }

    private func format(_ t: TimeInterval) -> String {
        let h = Int(t) / 3600, m = (Int(t) % 3600) / 60
        return h > 0 ? "\(h) h \(m) min" : "\(m) min"
    }
}
