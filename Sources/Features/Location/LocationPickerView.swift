import SwiftUI

/// Location picker: searchable city list with GPS auto-detect.
/// Searches 141K cities via Supabase search_locations RPC.
struct LocationPickerView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: LocationViewModel?

    var body: some View {
        Group {
            if let viewModel {
                locationContent(viewModel: viewModel)
            } else {
                ProgressView("Loading...")
            }
        }
        .navigationTitle("Location")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel == nil {
                let vm = LocationViewModel(
                    locationRepository: container.locationRepository,
                    onLocationSelected: { name in
                        container.selectedLocationName = name
                    }
                )
                self.viewModel = vm
                vm.loadSelectedLocation()
            }
        }
    }

    @ViewBuilder
    private func locationContent(viewModel: LocationViewModel) -> some View {
        List {
            // MARK: - GPS Section
            Section {
                gpsButton(viewModel: viewModel)
                gpsStatusView(viewModel: viewModel)
            }

            // MARK: - Current Location
            if let selected = viewModel.selectedLocation {
                Section("Current Location") {
                    HStack {
                        Text(selected.countryFlag)
                        VStack(alignment: .leading) {
                            Text(selected.name)
                                .fontWeight(.medium)
                            Text(selected.countryName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }

            // MARK: - Search Results
            if !viewModel.searchText.isEmpty {
                Section {
                    if viewModel.isSearching {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else if viewModel.searchResults.isEmpty {
                        Text("No cities found for \"\(viewModel.searchText)\"")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(viewModel.searchResults) { geo in
                            Button {
                                viewModel.selectLocation(geo, isFromGps: false)
                                dismiss()
                            } label: {
                                HStack {
                                    Text(geo.countryFlag)
                                    VStack(alignment: .leading) {
                                        Text(geo.name)
                                            .foregroundStyle(.primary)
                                        Text(geo.countryName)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: {
                    Text("Search Results")
                }
            } else if viewModel.selectedLocation == nil {
                // Empty state
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 36))
                            .foregroundStyle(.secondary)
                        Text("Search for a city")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("Or use GPS to detect your location")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                }
            }
        }
        .searchable(text: Binding(
            get: { viewModel.searchText },
            set: { viewModel.searchText = $0 }
        ), prompt: "Search cities (e.g. Jerusalem, Paris France)")
        .alert("Error", isPresented: Binding(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )) {
            Button("OK") { viewModel.error = nil }
        } message: {
            Text(viewModel.error ?? "")
        }
    }

    // MARK: - GPS Button

    @ViewBuilder
    private func gpsButton(viewModel: LocationViewModel) -> some View {
        Button {
            viewModel.detectGPSLocation()
        } label: {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundStyle(.blue)
                Text("Use Current Location")
                Spacer()
                if case .detecting = viewModel.gpsStatus {
                    ProgressView()
                }
            }
        }
        .disabled({
            if case .detecting = viewModel.gpsStatus { return true }
            return false
        }())
    }

    // MARK: - GPS Status

    @ViewBuilder
    private func gpsStatusView(viewModel: LocationViewModel) -> some View {
        switch viewModel.gpsStatus {
        case .found(let geo, let distanceKm):
            Button {
                viewModel.selectLocation(geo, isFromGps: true)
                dismiss()
            } label: {
                HStack {
                    Text(geo.countryFlag)
                    VStack(alignment: .leading) {
                        Text(geo.name)
                            .foregroundStyle(.primary)
                        Text("\(geo.countryName) (\(String(format: "%.0f", distanceKm))km away)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("Select")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
            .buttonStyle(.plain)

        case .denied:
            HStack {
                Image(systemName: "location.slash")
                    .foregroundStyle(.red)
                Text("Location access denied. Enable in Settings.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

        case .error(let message):
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

        default:
            EmptyView()
        }
    }
}
