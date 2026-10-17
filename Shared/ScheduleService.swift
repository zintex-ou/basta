import Foundation
import DeviceActivity

/// Registers weekly schedules with DeviceActivity. iOS then wakes the
/// BastaMonitor extension at interval start/end even if the app is closed.
enum ScheduleService {
    private static let center = DeviceActivityCenter()

    /// Activity name encodes mode id + weekday so the extension can map it back.
    static func activityName(mode: UUID, weekday: Int) -> DeviceActivityName {
        DeviceActivityName("basta.\(mode.uuidString).\(weekday)")
    }

    static func parse(_ name: DeviceActivityName) -> (mode: UUID, weekday: Int)? {
        let parts = name.rawValue.split(separator: ".")
        guard parts.count == 3, parts[0] == "basta",
              let id = UUID(uuidString: String(parts[1])),
              let wd = Int(parts[2]) else { return nil }
        return (id, wd)
    }

    /// Re-registers every scheduled mode. Call after any change.
    static func syncAll(_ modes: [FocusMode]) {
        // Only clear weekly schedules; keep one-off quick-focus sessions alive.
        let weekly = center.activities.filter { parse($0) != nil }
        center.stopMonitoring(weekly)
        for mode in modes where mode.isEnabled {
            guard let s = mode.schedule, mode.blocksAnything else { continue }
            for wd in s.weekdays {
                var start = DateComponents(hour: s.startHour, minute: s.startMinute, weekday: wd)
                var end = DateComponents(hour: s.endHour, minute: s.endMinute, weekday: wd)
                if s.crossesMidnight {
                    // Window like 22:00 → 06:00 ends the next day.
                    end.weekday = wd == 7 ? 1 : wd + 1
                }
                start.calendar = .current
                end.calendar = .current
                let schedule = DeviceActivitySchedule(intervalStart: start, intervalEnd: end, repeats: true)
                do {
                    try center.startMonitoring(activityName(mode: mode.id, weekday: wd), during: schedule)
                } catch {
                    // A window shorter than 15 min or malformed components throws; skip it.
                    continue
                }
            }
        }
    }

    /// One-off quick-focus session. Name prefix "basta.once." so the monitor
    /// extension deactivates the mode on intervalDidEnd.
    static func onceName(mode: UUID) -> DeviceActivityName {
        DeviceActivityName("basta.once.\(mode.uuidString)")
    }

    static func parseOnce(_ name: DeviceActivityName) -> UUID? {
        let p = "basta.once."
        guard name.rawValue.hasPrefix(p) else { return nil }
        return UUID(uuidString: String(name.rawValue.dropFirst(p.count)))
    }

    static func startOneOff(mode: UUID, until: Date) {
        let cal = Calendar.current
        let now = Date()
        // DeviceActivity requires ≥15 min; pad short sessions.
        let end = max(until, now.addingTimeInterval(15 * 60))
        let start = cal.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        let stop = cal.dateComponents([.year, .month, .day, .hour, .minute], from: end)
        let schedule = DeviceActivitySchedule(intervalStart: start, intervalEnd: stop, repeats: false)
        center.stopMonitoring([onceName(mode: mode)])
        try? center.startMonitoring(onceName(mode: mode), during: schedule)
    }

    /// Is `mode` inside one of its windows right now? Used on app launch
    /// to recover state if an interval event was missed.
    static func isInsideWindow(_ mode: FocusMode, now: Date = Date()) -> Bool {
        guard let s = mode.schedule else { return false }
        let cal = Calendar.current
        let wd = cal.component(.weekday, from: now)
        let minutes = cal.component(.hour, from: now) * 60 + cal.component(.minute, from: now)
        let start = s.startHour * 60 + s.startMinute
        let end = s.endHour * 60 + s.endMinute

        if !s.crossesMidnight {
            return s.weekdays.contains(wd) && minutes >= start && minutes < end
        }
        // Overnight: today's tail or yesterday's head.
        let yesterday = wd == 1 ? 7 : wd - 1
        return (s.weekdays.contains(wd) && minutes >= start)
            || (s.weekdays.contains(yesterday) && minutes < end)
    }

    /// End of the current window (for strict lock).
    static func windowEnd(_ mode: FocusMode, now: Date = Date()) -> Date? {
        guard let s = mode.schedule, isInsideWindow(mode, now: now) else { return nil }
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: now)
        comps.hour = s.endHour
        comps.minute = s.endMinute
        guard var end = cal.date(from: comps) else { return nil }
        if end <= now { end = cal.date(byAdding: .day, value: 1, to: end) ?? end }
        return end
    }
}
