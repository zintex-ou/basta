import Foundation
import CoreLocation

/// Geofence monitoring. iOS relaunches the app in the background for
/// region events, so the delegate applies the shield directly.
@MainActor
final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationService()

    @Published private(set) var status: CLAuthorizationStatus = .notDetermined
    private let manager = CLLocationManager()

    override private init() {
        super.init()
        manager.delegate = self
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        status = manager.authorizationStatus
    }

    func requestAlways() {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            manager.requestAlwaysAuthorization()
        }
    }

    /// Registers one circular region per mode with a place. Max 20 regions per app.
    func syncAll(_ modes: [FocusMode]) {
        for r in manager.monitoredRegions { manager.stopMonitoring(for: r) }
        for mode in modes where mode.isEnabled {
            guard let p = mode.place, mode.blocksAnything else { continue }
            let region = CLCircularRegion(
                center: .init(latitude: p.latitude, longitude: p.longitude),
                radius: max(100, min(p.radius, 1000)),
                identifier: mode.id.uuidString
            )
            region.notifyOnEntry = true
            region.notifyOnExit = true
            manager.startMonitoring(for: region)
            manager.requestState(for: region)   // fixes state if we're already inside
        }
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManagerDidChangeAuthorization(_ m: CLLocationManager) {
        let s = m.authorizationStatus
        Task { @MainActor in
            self.status = s
            if s == .authorizedWhenInUse { m.requestAlwaysAuthorization() }
        }
    }

    nonisolated func locationManager(_ m: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let id = UUID(uuidString: region.identifier) else { return }
        ShieldService.activate(id)
    }

    nonisolated func locationManager(_ m: CLLocationManager, didExitRegion region: CLRegion) {
        guard let id = UUID(uuidString: region.identifier) else { return }
        ShieldService.deactivate(id)
    }

    nonisolated func locationManager(_ m: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        guard let id = UUID(uuidString: region.identifier) else { return }
        switch state {
        case .inside: ShieldService.activate(id)
        case .outside: ShieldService.deactivate(id)
        case .unknown: break
        }
    }
}
