import Foundation
import ManagedSettings
import FamilyControls

/// Applies / clears the block for the union of all currently active modes.
/// Used from the app (manual + geofence) and from the DeviceActivity extension (schedules).
enum ShieldService {
    private static let store = ManagedSettingsStore(named: .init(AppGroup.storeName))

    /// Recomputes the shield from the set of active modes and applies it.
    static func apply() {
        let modes = ModeStore.load()
        let active = ModeStore.activeIDs()
        let live = modes.filter { active.contains($0.id) && $0.isEnabled }

        guard !live.isEmpty else {
            clear()
            return
        }

        var apps = Set<ApplicationToken>()
        var cats = Set<ActivityCategoryToken>()
        var webs = Set<WebDomainToken>()
        for m in live {
            apps.formUnion(m.selection.applicationTokens)
            cats.formUnion(m.selection.categoryTokens)
            webs.formUnion(m.selection.webDomainTokens)
        }

        store.shield.applications = apps.isEmpty ? nil : apps
        store.shield.applicationCategories = cats.isEmpty ? nil : .specific(cats)
        store.shield.webDomains = webs.isEmpty ? nil : webs
        store.shield.webDomainCategories = cats.isEmpty ? nil : .specific(cats)
    }

    static func clear() {
        store.clearAllSettings()
    }

    // MARK: - Activation helpers

    static func activate(_ id: UUID) {
        var ids = ModeStore.activeIDs()
        ids.insert(id)
        ModeStore.setActive(ids)
        apply()
    }

    static func deactivate(_ id: UUID) {
        var ids = ModeStore.activeIDs()
        ids.remove(id)
        ModeStore.setActive(ids)
        apply()
    }

    static func isActive(_ id: UUID) -> Bool {
        ModeStore.activeIDs().contains(id)
    }

    /// Strict mode: while any active mode is strict, the user cannot
    /// switch it off from the app until its window ends.
    static func isLockedByStrict() -> Bool {
        guard let until = ModeStore.strictUntil() else { return false }
        return until > Date()
    }
}
