import SwiftUI

/// Main Zmanim tab screen displaying halachic times for the user's location.
/// Shows essential times by default with toggle for comprehensive list.
/// Shabbat times (candle lighting / havdalah) displayed in separate section.
struct ZmanimView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: ZmanimViewModel?

    var body: some View {
        Group {
            if let viewModel {
                zmanimContent(viewModel: viewModel)
            } else {
                ProgressView("Loading...")
            }
        }
        .navigationTitle("zmanim")
        .task {
            if viewModel == nil {
                let vm = ZmanimViewModel(
                    zmanimService: container.zmanimService,
                    settingsRepository: container.settingsRepository,
                    locationRepository: container.locationRepository,
                    localSettings: container.localSettings
                )
                viewModel = vm
                await vm.loadZmanim()
            }
        }
        .onChange(of: container.zmanimDateOverride) { _, newDate in
            guard let newDate, let viewModel else { return }
            viewModel.selectedDate = newDate
            container.zmanimDateOverride = nil
            Task {
                await viewModel.loadZmanim()
            }
        }
    }

    @ViewBuilder
    private func zmanimContent(viewModel: ZmanimViewModel) -> some View {
        List {
            // Header section with dates and location
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    if !viewModel.hebrewDateString.isEmpty {
                        Text(viewModel.hebrewDateString)
                            .font(.headline)
                    }
                    Text(formattedGregorianDate(viewModel.selectedDate))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if !viewModel.locationName.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.caption)
                            Text(viewModel.locationName)
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
            }

            // Shabbat times section (Friday / Saturday only)
            if viewModel.hasShabbatTimes {
                Section {
                    ForEach(viewModel.shabbatTimes) { zman in
                        ZmanRowView(
                            zman: zman,
                            use24h: container.localSettings.use24hFormat,
                            timeZone: currentTimeZone
                        )
                    }
                } header: {
                    Label("Shabbat Times", systemImage: "flame")
                }
            }

            // Zmanim list
            Section {
                ForEach(viewModel.displayedZmanim) { zman in
                    ZmanRowView(
                        zman: zman,
                        use24h: container.localSettings.use24hFormat,
                        timeZone: currentTimeZone
                    )
                }
            } header: {
                HStack {
                    Text("notification_type_zman")
                    Spacer()
                    Button {
                        viewModel.showAllTimes.toggle()
                    } label: {
                        Text(viewModel.showAllTimes ? "Essential Times" : "All Times")
                            .font(.caption)
                    }
                }
            }

            // Error message
            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Helpers

    private var currentTimeZone: TimeZone {
        // Use the location's timezone if available
        .current
    }

    private func formattedGregorianDate(_ date: Date) -> String {
        LocaleFormatters.longDate(date)
    }
}
