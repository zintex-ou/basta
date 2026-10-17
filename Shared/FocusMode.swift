import Foundation
import FamilyControls

/// A "focus mode": a set of blocked apps that is switched on
/// by a weekly schedule, by entering a place, or manually.
struct FocusMode: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var icon: String = "moon.fill"
    var selection: FamilyActivitySelection = FamilyActivitySelection()
    var schedule: Schedule? = nil
    var place: Place? = nil
    var isEnabled: Bool = true
    var strict: Bool = false

    /// Weekly recurring window, e.g. Mon–Fri 09:00–17:00.
    struct Schedule: Codable, Equatable {
        var weekdays: Set<Int> = [2, 3, 4, 5, 6]   // Calendar weekday: 1 = Sunday
        var startHour: Int = 9
        var startMinute: Int = 0
        var endHour: Int = 17
        var endMinute: Int = 0

        var crossesMidnight: Bool {
            (endHour, endMinute) <= (startHour, startMinute)
        }
    }

    /// Circular geofence.
    struct Place: Codable, Equatable {
        var name: String
        var latitude: Double
        var longitude: Double
        var radius: Double = 150   // metres
    }

    static func == (lhs: FocusMode, rhs: FocusMode) -> Bool {
        lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.icon == rhs.icon
            && lhs.schedule == rhs.schedule
            && lhs.place == rhs.place
            && lhs.isEnabled == rhs.isEnabled
            && lhs.strict == rhs.strict
            && lhs.selection.applicationTokens == rhs.selection.applicationTokens
            && lhs.selection.categoryTokens == rhs.selection.categoryTokens
            && lhs.selection.webDomainTokens == rhs.selection.webDomainTokens
    }

    var blocksAnything: Bool {
        !selection.applicationTokens.isEmpty
            || !selection.categoryTokens.isEmpty
            || !selection.webDomainTokens.isEmpty
    }
}

/// Persistence in the App Group so the DeviceActivity extension
/// can read the same modes the user configured in the app.
enum ModeStore {
    static func load() -> [FocusMode] {
        guard let data = AppGroup.defaults.data(forKey: AppGroup.Key.modes) else { return [] }
        return (try? JSONDecoder().decode([FocusMode].self, from: data)) ?? []
    }

    static func save(_ modes: [FocusMode]) {
        if let data = try? JSONEncoder().encode(modes) {
            AppGroup.defaults.set(data, forKey: AppGroup.Key.modes)
        }
    }

    static func activeIDs() -> Set<UUID> {
        let raw = AppGroup.defaults.stringArray(forKey: AppGroup.Key.activeModeIDs) ?? []
        return Set(raw.compactMap(UUID.init(uuidString:)))
    }

    static func setActive(_ ids: Set<UUID>) {
        AppGroup.defaults.set(ids.map(\.uuidString), forKey: AppGroup.Key.activeModeIDs)
    }

    static func strictUntil() -> Date? {
        let t = AppGroup.defaults.double(forKey: AppGroup.Key.strictUntil)
        return t > 0 ? Date(timeIntervalSince1970: t) : nil
    }

    static func setStrictUntil(_ date: Date?) {
        AppGroup.defaults.set(date?.timeIntervalSince1970 ?? 0, forKey: AppGroup.Key.strictUntil)
    }
}
