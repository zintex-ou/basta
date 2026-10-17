import Foundation
import SwiftUI
import FamilyControls
import Combine

/// App-wide state: modes, Screen Time authorization, onboarding flag.
@MainActor
final class AppModel: ObservableObject {
    @Published var modes: [FocusMode] {
        didSet { persistAndSync() }
    }
    @Published private(set) var screenTimeAuthorized: Bool
    @Published var onboardingDone: Bool {
        didSet { AppGroup.defaults.set(onboardingDone, forKey: AppGroup.Key.onboardingDone) }
    }
    /// Ticks once a minute so the UI re-evaluates "active now".
    @Published private(set) var now = Date()

    private var timer: AnyCancellable?

    init() {
        modes = ModeStore.load()
        screenTimeAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        onboardingDone = AppGroup.defaults.bool(forKey: AppGroup.Key.onboardingDone)
        timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
            .sink { [weak self] d in self?.now = d }
        recoverState()
    }

    // MARK: - Screen Time authorization

    func requestScreenTime() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            screenTimeAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        } catch {
            screenTimeAuthorized = false
        }
    }

    // MARK: - Modes

    func add(_ mode: FocusMode) { modes.append(mode) }

    func update(_ mode: FocusMode) {
        guard let i = modes.firstIndex(where: { $0.id == mode.id }) else { return }
        modes[i] = mode
    }

    func delete(_ mode: FocusMode) {
        ShieldService.deactivate(mode.id)
        modes.removeAll { $0.id == mode.id }
    }

    func isActive(_ mode: FocusMode) -> Bool {
        ShieldService.isActive(mode.id)
    }

    /// Manual toggle from the home screen.
    func toggle(_ mode: FocusMode) {
        if isActive(mode) {
            guard !ShieldService.isLockedByStrict() else { return }
            ShieldService.deactivate(mode.id)
        } else {
            ShieldService.activate(mode.id)
            if mode.strict, let end = ScheduleService.windowEnd(mode) {
                ModeStore.setStrictUntil(end)
            }
        }
        objectWillChange.send()
    }

    /// Quick focus: block a mode's apps for N minutes, no schedule needed.
    func quickFocus(_ mode: FocusMode, minutes: Int) {
        ShieldService.activate(mode.id)
        let until = Date().addingTimeInterval(TimeInterval(minutes * 60))
        if mode.strict { ModeStore.setStrictUntil(until) }
        // A one-off DeviceActivity interval ends the session even if the app is killed.
        ScheduleService.startOneOff(mode: mode.id, until: until)
        objectWillChange.send()
    }

    var strictLockedUntil: Date? {
        ShieldService.isLockedByStrict() ? ModeStore.strictUntil() : nil
    }

    // MARK: - Internals

    private func persistAndSync() {
        ModeStore.save(modes)
        ScheduleService.syncAll(modes)
        LocationService.shared.syncAll(modes)
        ShieldService.apply()
    }

    /// If an interval event was missed (reinstall, reboot), rebuild
    /// the active set from schedules on launch.
    private func recoverState() {
        var ids = ModeStore.activeIDs()
        for m in modes where m.schedule != nil {
            if ScheduleService.isInsideWindow(m) { ids.insert(m.id) } else { ids.remove(m.id) }
        }
        ModeStore.setActive(ids)
        ShieldService.apply()
        ScheduleService.syncAll(modes)
        LocationService.shared.syncAll(modes)
    }
}
