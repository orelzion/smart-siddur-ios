import Foundation
import Observation
import CoreLocation

// MARK: - GPS Status

enum GPSStatus: Sendable {
    case notDetermined
    case authorized
    case denied
    case detecting
    case found(GeoLocation, distanceKm: Double)
    case error(String)
}

// MARK: - CLLocationManager Delegate

/// Separate delegate class to avoid @Observable + NSObject conflicts.
/// Forwards CLLocationManager events back to LocationViewModel via closures.
final class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    var onLocationUpdate: ((_ coordinate: CLLocationCoordinate2D) -> Void)?
    var onError: ((_ error: Error) -> Void)?
    var onAuthorizationChange: ((_ status: CLAuthorizationStatus) -> Void)?

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        onLocationUpdate?(location.coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        onError?(error)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        onAuthorizationChange?(manager.authorizationStatus)
    }
}

// MARK: - LocationViewModel

/// View model for the location picker.
/// Handles search debouncing, GPS detection, and location selection.
@MainActor
@Observable
final class LocationViewModel {
    // MARK: - Published State

    var searchText: String = "" {
        didSet { debounceSearch() }
    }
    var searchResults: [GeoLocation] = []
    var selectedLocation: UserLocation?
    var isSearching = false
    var gpsStatus: GPSStatus = .notDetermined
    var error: String?

    // MARK: - Dependencies

    private let locationRepository: LocationRepositoryProtocol
    private let onLocationSelected: ((String) -> Void)?

    // MARK: - Private

    private var searchTask: Task<Void, Never>?

    @ObservationIgnored
    private let locationManager = CLLocationManager()

    @ObservationIgnored
    private let locationDelegate = LocationManagerDelegate()

    // MARK: - Init

    init(locationRepository: LocationRepositoryProtocol, onLocationSelected: ((String) -> Void)? = nil) {
        self.locationRepository = locationRepository
        self.onLocationSelected = onLocationSelected

        locationManager.delegate = locationDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer

        setupDelegateCallbacks()
    }

    private func setupDelegateCallbacks() {
        locationDelegate.onLocationUpdate = { [weak self] coordinate in
            Task { @MainActor [weak self] in
                self?.handleGPSCoordinate(coordinate)
            }
        }
        locationDelegate.onError = { [weak self] error in
            Task { @MainActor [weak self] in
                self?.gpsStatus = .error("GPS error: \(error.localizedDescription)")
            }
        }
        locationDelegate.onAuthorizationChange = { [weak self] status in
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch status {
                case .authorizedWhenInUse, .authorizedAlways:
                    self.gpsStatus = .authorized
                    self.locationManager.requestLocation()
                case .denied, .restricted:
                    self.gpsStatus = .denied
                case .notDetermined:
                    self.gpsStatus = .notDetermined
                @unknown default:
                    break
                }
            }
        }
    }

    // MARK: - Load

    func loadSelectedLocation() {
        Task {
            do {
                let location = try await locationRepository.getSelectedLocation()
                self.selectedLocation = location
                if let location {
                    self.onLocationSelected?(location.displayName)
                }
            } catch {
                // Not critical if this fails -- user can still search
            }
        }
    }

    // MARK: - Search

    private func debounceSearch() {
        searchTask?.cancel()
        let query = searchText
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        isSearching = true
        searchTask = Task {
            // 300ms debounce
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            do {
                let results = try await locationRepository.searchLocations(query: query)
                guard !Task.isCancelled else { return }
                self.searchResults = results
            } catch {
                guard !Task.isCancelled else { return }
                self.error = error.localizedDescription
            }
            self.isSearching = false
        }
    }

    // MARK: - GPS Detection

    func detectGPSLocation() {
        gpsStatus = .detecting
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            gpsStatus = .denied
        @unknown default:
            gpsStatus = .error("Unknown authorization status")
        }
    }

    // MARK: - Select Location

    func selectLocation(_ geo: GeoLocation, isFromGps: Bool) {
        Task {
            do {
                let saved = try await locationRepository.saveLocation(geo, isFromGps: isFromGps)
                self.selectedLocation = saved
                self.onLocationSelected?(saved.displayName)
            } catch {
                self.error = "Failed to save location: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Private GPS Helpers

    private func handleGPSCoordinate(_ coordinate: CLLocationCoordinate2D) {
        Task {
            do {
                guard let nearest = try await locationRepository.findNearestCity(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                ) else {
                    gpsStatus = .error("No city found near your location.")
                    return
                }
                let distanceKm = haversineDistance(
                    lat1: coordinate.latitude, lon1: coordinate.longitude,
                    lat2: nearest.latitude, lon2: nearest.longitude
                )
                gpsStatus = .found(nearest, distanceKm: distanceKm)
            } catch {
                gpsStatus = .error(error.localizedDescription)
            }
        }
    }

    private func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let earthRadius = 6371.0
        let dLat = (lat2 - lat1) * .pi / 180.0
        let dLon = (lon2 - lon1) * .pi / 180.0
        let a = sin(dLat / 2) * sin(dLat / 2) +
                cos(lat1 * .pi / 180.0) * cos(lat2 * .pi / 180.0) *
                sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return earthRadius * c
    }
}
