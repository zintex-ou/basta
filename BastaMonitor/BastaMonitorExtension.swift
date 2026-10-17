import DeviceActivity
import ManagedSettings

/// Woken by iOS at schedule boundaries. Flips modes on/off and reapplies the shield.
final class BastaMonitorExtension: DeviceActivityMonitor {

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        if let (id, _) = ScheduleService.parse(activity) {
            ShieldService.activate(id)
            // Strict schedules lock until the window ends.
            if let mode = ModeStore.load().first(where: { $0.id == id }), mode.strict,
               let end = ScheduleService.windowEnd(mode) {
                ModeStore.setStrictUntil(end)
            }
        }
        // One-off sessions are activated by the app itself; nothing to do here.
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        if let (id, _) = ScheduleService.parse(activity) {
            ShieldService.deactivate(id)
        } else if let id = ScheduleService.parseOnce(activity) {
            ShieldService.deactivate(id)
            ModeStore.setStrictUntil(nil)
        }
    }
}
