import Combine
import CoreLocation
import Foundation

final class ZephyrRuneLocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    static let shared = ZephyrRuneLocationManager()

    @Published var zephyrRuneShowLocationDialog = false

    private let zephyrRuneManager = CLLocationManager()
    private var zephyrRuneLocationContinuation: CheckedContinuation<CLLocation, Error>?
    private var zephyrRuneAuthorizationContinuation: CheckedContinuation<Bool, Never>?
    private var zephyrRuneTimeoutTask: Task<Void, Never>?

    override init() {
        super.init()
        zephyrRuneManager.delegate = self
        zephyrRuneManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func zephyrRuneGetCurrentLocationAndAddress() async -> CLPlacemark? {
        guard await zephyrRuneCheckAndRequestLocation() else { return nil }
        do {
            return try await zephyrRuneReverseGeocode(zephyrRuneRequestOneLocation())
        } catch {
            await MainActor.run {
                PrismTrailPulseToastLoadingCenter.shared.showToast("Positioning failed", kind: .error)
            }
            return nil
        }
    }

    func zephyrRuneCheckAndRequestLocation() async -> Bool {
        guard await zephyrRuneCheckSystemLocationService() else { return false }
        return await zephyrRuneCheckAuthorizationStatus()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let zephyrRuneContinuation = zephyrRuneTakeLocationContinuation() else { return }
        guard let zephyrRuneLocation = locations.last else {
            zephyrRuneContinuation.resume(throwing: TenebrousRillLocationError.tenebrousRillNoLocation)
            return
        }
        zephyrRuneContinuation.resume(returning: zephyrRuneLocation)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        zephyrRuneTakeLocationContinuation()?.resume(throwing: error)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard manager.authorizationStatus != .notDetermined,
              let zephyrRuneContinuation = zephyrRuneAuthorizationContinuation else { return }
        zephyrRuneAuthorizationContinuation = nil
        let zephyrRuneAuthorized = manager.authorizationStatus == .authorizedAlways
            || manager.authorizationStatus == .authorizedWhenInUse
        zephyrRuneContinuation.resume(returning: zephyrRuneAuthorized)
    }

    private func zephyrRuneCheckSystemLocationService() async -> Bool {
        guard CLLocationManager.locationServicesEnabled() else {
            zephyrRuneShowPermissionDialog()
            if CLLocationManager.locationServicesEnabled() == false {
                DispatchQueue.main.async {
                    PrismTrailPulseToastLoadingCenter.shared.showToast(
                        "Please enable system location services.",
                        kind: .error
                    )
                }
                return false
            }
            return false
        }
        return true
    }

    private func zephyrRuneCheckAuthorizationStatus() async -> Bool {
        switch zephyrRuneManager.authorizationStatus {
        case .denied, .restricted:
            zephyrRuneShowPermissionDialog()
            return zephyrRuneManager.authorizationStatus != .denied
                && zephyrRuneManager.authorizationStatus != .restricted
        case .notDetermined:
            return await withCheckedContinuation { zephyrRuneContinuation in
                zephyrRuneAuthorizationContinuation = zephyrRuneContinuation
                zephyrRuneManager.requestWhenInUseAuthorization()
            }
        default:
            return true
        }
    }

    private func zephyrRuneRequestOneLocation() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { zephyrRuneContinuation in
            zephyrRuneLocationContinuation = zephyrRuneContinuation
            zephyrRuneManager.requestLocation()
            zephyrRuneTimeoutTask?.cancel()
            zephyrRuneTimeoutTask = Task { [weak self] in
                try? await Task.sleep(nanoseconds: 8_000_000_000)
                guard Task.isCancelled == false,
                      let zephyrRuneContinuation = self?.zephyrRuneTakeLocationContinuation() else { return }
                zephyrRuneContinuation.resume(throwing: TenebrousRillLocationError.tenebrousRillTimeout)
            }
        }
    }

    private func zephyrRuneTakeLocationContinuation() -> CheckedContinuation<CLLocation, Error>? {
        guard let zephyrRuneContinuation = zephyrRuneLocationContinuation else { return nil }
        zephyrRuneLocationContinuation = nil
        zephyrRuneTimeoutTask?.cancel()
        zephyrRuneTimeoutTask = nil
        return zephyrRuneContinuation
    }

    private func zephyrRuneReverseGeocode(_ zephyrRuneLocation: CLLocation) async throws -> CLPlacemark? {
        try await withCheckedThrowingContinuation { zephyrRuneContinuation in
            CLGeocoder().reverseGeocodeLocation(zephyrRuneLocation) { zephyrRunePlacemarks, zephyrRuneError in
                if let zephyrRuneError {
                    zephyrRuneContinuation.resume(throwing: zephyrRuneError)
                } else {
                    zephyrRuneContinuation.resume(returning: zephyrRunePlacemarks?.first)
                }
            }
        }
    }

    @MainActor
    private func zephyrRuneShowPermissionDialog() {
        zephyrRuneShowLocationDialog = true
    }
}

private enum TenebrousRillLocationError: LocalizedError {
    case tenebrousRillNoLocation
    case tenebrousRillTimeout

    var errorDescription: String? {
        switch self {
        case .tenebrousRillNoLocation: return "Location unavailable"
        case .tenebrousRillTimeout: return "Location request timed out"
        }
    }
}
