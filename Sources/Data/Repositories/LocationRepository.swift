import Foundation
import Supabase

// MARK: - Protocol

/// Defines operations for location search and user location management.
protocol LocationRepositoryProtocol: Sendable {
    /// Search geo_locations using the search_locations RPC function.
    func searchLocations(query: String) async throws -> [GeoLocation]
    /// Find the nearest seeded city to a GPS coordinate using bounding box + Haversine.
    func findNearestCity(latitude: Double, longitude: Double) async throws -> GeoLocation?
    /// Get the user's currently selected location.
    func getSelectedLocation() async throws -> UserLocation?
    /// Get all saved locations for the user.
    func getUserLocations() async throws -> [UserLocation]
    /// Save a geo location as the user's selected location.
    /// Deselects any previously selected location first (EXCLUDE constraint).
    func saveLocation(_ geo: GeoLocation, isFromGps: Bool) async throws -> UserLocation
}

// MARK: - RPC Parameters

/// Parameters for the search_locations RPC function.
private struct SearchLocationParams: Encodable, Sendable {
    let query: String
    let maxResults: Int

    enum CodingKeys: String, CodingKey {
        case query
        case maxResults = "max_results"
    }
}

// MARK: - Implementation

final class LocationRepository: LocationRepositoryProtocol, @unchecked Sendable {
    private let supabase: SupabaseClient

    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }

    private var userId: UUID {
        get throws {
            guard let user = supabase.auth.currentUser else {
                throw LocationError.notAuthenticated
            }
            return user.id
        }
    }

    func searchLocations(query: String) async throws -> [GeoLocation] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let params = SearchLocationParams(query: trimmed, maxResults: 20)
        let response: [GeoLocation] = try await supabase
            .rpc("search_locations", params: params)
            .execute()
            .value
        return response
    }

    func findNearestCity(latitude: Double, longitude: Double) async throws -> GeoLocation? {
        // Use a bounding box approach: fetch cities within ~1 degree (~111km),
        // then sort client-side by Haversine distance for accuracy.
        let delta = 1.0
        let results: [GeoLocation] = try await supabase
            .from("geo_locations")
            .select()
            .gte("latitude", value: latitude - delta)
            .lte("latitude", value: latitude + delta)
            .gte("longitude", value: longitude - delta)
            .lte("longitude", value: longitude + delta)
            .limit(50)
            .execute()
            .value

        // Sort by Haversine distance and return the nearest
        return results.min(by: {
            haversineDistance(lat1: latitude, lon1: longitude, lat2: $0.latitude, lon2: $0.longitude) <
            haversineDistance(lat1: latitude, lon1: longitude, lat2: $1.latitude, lon2: $1.longitude)
        })
    }

    func getSelectedLocation() async throws -> UserLocation? {
        let uid = try userId
        let results: [UserLocation] = try await supabase
            .from("user_locations")
            .select()
            .eq("user_id", value: uid)
            .eq("is_selected", value: true)
            .limit(1)
            .execute()
            .value
        return results.first
    }

    func getUserLocations() async throws -> [UserLocation] {
        let uid = try userId
        let results: [UserLocation] = try await supabase
            .from("user_locations")
            .select()
            .eq("user_id", value: uid)
            .execute()
            .value
        return results
    }

    func saveLocation(_ geo: GeoLocation, isFromGps: Bool) async throws -> UserLocation {
        let uid = try userId

        // Deselect any currently selected location first (to honor EXCLUDE constraint)
        try await supabase
            .from("user_locations")
            .update(["is_selected": false])
            .eq("user_id", value: uid)
            .eq("is_selected", value: true)
            .execute()

        // Parse elevation from geo (string) to double
        let elevationValue = Double(geo.elevation ?? "") ?? 0.0

        // Insert new location as selected
        let newLocation = NewUserLocation(
            userId: uid,
            geonameId: geo.geonameId,
            name: geo.name,
            countryCode: geo.countryCode,
            countryName: geo.countryName,
            latitude: geo.latitude,
            longitude: geo.longitude,
            elevation: elevationValue,
            timezoneId: geo.timezone,
            isSelected: true,
            isFromGps: isFromGps
        )

        let saved: UserLocation = try await supabase
            .from("user_locations")
            .insert(newLocation)
            .select()
            .single()
            .execute()
            .value

        return saved
    }

    // MARK: - Haversine Distance

    /// Haversine formula: returns distance in kilometers between two coordinates.
    private func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let earthRadius = 6371.0 // km
        let dLat = (lat2 - lat1) * .pi / 180.0
        let dLon = (lon2 - lon1) * .pi / 180.0
        let a = sin(dLat / 2) * sin(dLat / 2) +
                cos(lat1 * .pi / 180.0) * cos(lat2 * .pi / 180.0) *
                sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return earthRadius * c
    }
}

// MARK: - Insert DTO

/// DTO for inserting a new user_location row.
private struct NewUserLocation: Encodable, Sendable {
    let userId: UUID
    let geonameId: String
    let name: String
    let countryCode: String
    let countryName: String
    let latitude: Double
    let longitude: Double
    let elevation: Double
    let timezoneId: String
    let isSelected: Bool
    let isFromGps: Bool

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case geonameId = "geoname_id"
        case name
        case countryCode = "country_code"
        case countryName = "country_name"
        case latitude
        case longitude
        case elevation
        case timezoneId = "timezone_id"
        case isSelected = "is_selected"
        case isFromGps = "is_from_gps"
    }
}

// MARK: - Errors

enum LocationError: LocalizedError {
    case notAuthenticated
    case noNearbyCity

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            "No authenticated user found. Please sign in."
        case .noNearbyCity:
            "No city found near your location."
        }
    }
}
