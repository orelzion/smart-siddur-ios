import SwiftUI

/// Main Settings screen organized into sections covering all synced and local settings.
/// Per MIGRATION_SPEC Sections 6.2 (synced) and 6.3 (local).
/// Redesigned with dark/gold glassmorphism theme and haptic feedback.
struct SettingsView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(\.colorScheme) var colorScheme
    @State private var viewModel: SettingsViewModel?

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.06, green: 0.09, blue: 0.16),  // #0f172a
                    Color(red: 0.01, green: 0.02, blue: 0.04)   // #020617
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Group {
                if let viewModel {
                    settingsContent(viewModel: viewModel)
                } else {
                    ProgressView()
                        .tint(Color(red: 0.85, green: 0.73, blue: 0.27))
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            if viewModel == nil {
                let vm = SettingsViewModel(
                    settingsRepository: container.settingsRepository,
                    localSettings: container.localSettings
                )
                self.viewModel = vm
                vm.loadSettings()
            }
        }
    }

    @ViewBuilder
    private func settingsContent(viewModel: SettingsViewModel) -> some View {
        @Bindable var vm = viewModel
        let local = viewModel.localSettings

        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Identity Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Identity")
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                        .padding(.horizontal, 16)

                    VStack(spacing: 0) {
                        NavigationLink {
                            NusachPickerView(
                                selected: viewModel.syncedSettings.nusach,
                                onSelect: { viewModel.updateNusach($0) }
                            )
                        } label: {
                            SettingsRow(
                                label: "Nusach",
                                value: viewModel.syncedSettings.nusach.displayName
                            )
                        }

                        Divider()
                            .background(Color(red: 0.20, green: 0.22, blue: 0.31))

                        HStack(spacing: 12) {
                            Text("Woman")
                                .foregroundStyle(.white)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { viewModel.syncedSettings.isWoman },
                                set: {
                                    viewModel.updateIsWoman($0)
                                    hapticFeedback()
                                }
                            ))
                            .tint(Color(red: 0.85, green: 0.73, blue: 0.27))
                        }
                        .padding(16)

                        Divider()
                            .background(Color(red: 0.20, green: 0.22, blue: 0.31))

                        SettingsPickerRow(
                            label: "Language",
                            value: viewModel.syncedSettings.language.displayName,
                            onTap: {}
                        )
                    }
                    .glassCard()
                    .padding(.horizontal, 16)

                    NavigationLink {
                        LocationPickerView()
                    } label: {
                        VStack(spacing: 0) {
                            HStack(spacing: 12) {
                                Text("Location")
                                    .foregroundStyle(.white)
                                Spacer()
                                if let loc = container.selectedLocationName {
                                    Text(loc)
                                        .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                                        .lineLimit(1)
                                } else {
                                    Text("Not set")
                                        .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                                }
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                            }
                            .padding(16)
                        }
                        .glassCard()
                    }
                    .padding(.horizontal, 16)
                }

                // MARK: - Location/Calendar Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Location & Calendar")
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                        .padding(.horizontal, 16)

                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            Text("In Israel")
                                .foregroundStyle(.white)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { viewModel.syncedSettings.isInIsrael },
                                set: {
                                    viewModel.updateIsInIsrael($0)
                                    hapticFeedback()
                                }
                            ))
                            .tint(Color(red: 0.85, green: 0.73, blue: 0.27))
                        }
                        .padding(16)

                        Divider()
                            .background(Color(red: 0.20, green: 0.22, blue: 0.31))

                        HStack(spacing: 12) {
                            Text("Mizrochnik")
                                .foregroundStyle(.white)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { viewModel.syncedSettings.isMizrochnik },
                                set: {
                                    viewModel.updateIsMizrochnik($0)
                                    hapticFeedback()
                                }
                            ))
                            .tint(Color(red: 0.85, green: 0.73, blue: 0.27))
                        }
                        .padding(16)

                        Divider()
                            .background(Color(red: 0.20, green: 0.22, blue: 0.31))

                        SettingsPickerRow(
                            label: "Mukaf Mode",
                            value: viewModel.syncedSettings.mukafMode.displayName,
                            onTap: {}
                        )

                        Divider()
                            .background(Color(red: 0.20, green: 0.22, blue: 0.31))

                        SettingsPickerRow(
                            label: "Date Change",
                            value: viewModel.syncedSettings.dateChangeRule.displayName,
                            onTap: {}
                        )
                    }
                    .glassCard()
                    .padding(.horizontal, 16)
                }

                // MARK: - Zmanim Opinions Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Zmanim Opinions")
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                        .padding(.horizontal, 16)

                    NavigationLink {
                        ZmanimOpinionsView(viewModel: viewModel)
                    } label: {
                        VStack(spacing: 0) {
                            HStack(spacing: 12) {
                                Text("Halachic Opinions")
                                    .foregroundStyle(.white)
                                Spacer()
                                Text(viewModel.syncedSettings.zmanOpinion.displayName)
                                    .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                            }
                            .padding(16)
                        }
                        .glassCard()
                    }
                    .padding(.horizontal, 16)
                }

                // MARK: - Personal Insertions Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Personal Insertions")
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                        .padding(.horizontal, 16)

                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            Text("Pasuk")
                                .foregroundStyle(.white)
                            Spacer()
                            TextField("Your verse", text: Binding(
                                get: { viewModel.syncedSettings.pasuk },
                                set: { viewModel.updatePasuk($0) }
                            ))
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(.white)
                            .textFieldStyle(.plain)
                        }
                        .padding(16)

                        Divider()
                            .background(Color(red: 0.20, green: 0.22, blue: 0.31))

                        HStack(spacing: 12) {
                            Text("Sick Name")
                                .foregroundStyle(.white)
                            Spacer()
                            TextField("For Mi Sheberach", text: Binding(
                                get: { viewModel.syncedSettings.sickName },
                                set: { viewModel.updateSickName($0) }
                            ))
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(.white)
                            .textFieldStyle(.plain)
                        }
                        .padding(16)

                        Divider()
                            .background(Color(red: 0.20, green: 0.22, blue: 0.31))

                        HStack(spacing: 12) {
                            Text("Include Tal")
                                .foregroundStyle(.white)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { viewModel.syncedSettings.talPreference },
                                set: {
                                    viewModel.updateTalPreference($0)
                                    hapticFeedback()
                                }
                            ))
                            .tint(Color(red: 0.85, green: 0.73, blue: 0.27))
                        }
                        .padding(16)
                    }
                    .glassCard()
                    .padding(.horizontal, 16)
                }

                // MARK: - Shabbat Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Shabbat")
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                        .padding(.horizontal, 16)

                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Candle Lighting")
                                    .foregroundStyle(.white)
                                Text("\(viewModel.syncedSettings.shabbatCandleMinutes) min before")
                                    .font(.caption)
                                    .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                            }
                            Spacer()
                            HStack(spacing: 8) {
                                Button {
                                    if viewModel.syncedSettings.shabbatCandleMinutes > 10 {
                                        viewModel.updateShabbatCandleMinutes(viewModel.syncedSettings.shabbatCandleMinutes - 1)
                                        hapticFeedback()
                                    }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                                }

                                Text("\(viewModel.syncedSettings.shabbatCandleMinutes)")
                                    .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                                    .frame(width: 30, alignment: .center)

                                Button {
                                    if viewModel.syncedSettings.shabbatCandleMinutes < 40 {
                                        viewModel.updateShabbatCandleMinutes(viewModel.syncedSettings.shabbatCandleMinutes + 1)
                                        hapticFeedback()
                                    }
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                                }
                            }
                        }
                        .padding(16)

                        Divider()
                            .background(Color(red: 0.20, green: 0.22, blue: 0.31))

                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Shabbat Ends")
                                    .foregroundStyle(.white)
                                Text("\(viewModel.syncedSettings.shabbatEndMinutes) min after")
                                    .font(.caption)
                                    .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                            }
                            Spacer()
                            HStack(spacing: 8) {
                                Button {
                                    if viewModel.syncedSettings.shabbatEndMinutes > 1 {
                                        viewModel.updateShabbatEndMinutes(viewModel.syncedSettings.shabbatEndMinutes - 1)
                                        hapticFeedback()
                                    }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                                }

                                Text("\(viewModel.syncedSettings.shabbatEndMinutes)")
                                    .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                                    .frame(width: 30, alignment: .center)

                                Button {
                                    if viewModel.syncedSettings.shabbatEndMinutes < 72 {
                                        viewModel.updateShabbatEndMinutes(viewModel.syncedSettings.shabbatEndMinutes + 1)
                                        hapticFeedback()
                                    }
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                                }
                            }
                        }
                        .padding(16)
                    }
                    .glassCard()
                    .padding(.horizontal, 16)
                }

                // MARK: - Appearance Section (Local)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Appearance")
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                        .padding(.horizontal, 16)

                    NavigationLink {
                        AppearanceSettingsView(localSettings: local)
                    } label: {
                        VStack(spacing: 0) {
                            HStack(spacing: 12) {
                                Text("Theme & Fonts")
                                    .foregroundStyle(.white)
                                Spacer()
                                Text(local.appTheme.displayName)
                                    .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                            }
                            .padding(16)
                        }
                        .glassCard()
                    }
                    .padding(.horizontal, 16)
                }

                // MARK: - Display Preferences (Local)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Display")
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                        .padding(.horizontal, 16)

                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            Text("Keep Screen Awake")
                                .foregroundStyle(.white)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { local.keepScreenAwake },
                                set: {
                                    local.keepScreenAwake = $0
                                    hapticFeedback()
                                }
                            ))
                            .tint(Color(red: 0.85, green: 0.73, blue: 0.27))
                        }
                        .padding(16)

                        Divider()
                            .background(Color(red: 0.20, green: 0.22, blue: 0.31))

                        HStack(spacing: 12) {
                            Text("Portrait Only")
                                .foregroundStyle(.white)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { local.portraitOnly },
                                set: {
                                    local.portraitOnly = $0
                                    hapticFeedback()
                                }
                            ))
                            .tint(Color(red: 0.85, green: 0.73, blue: 0.27))
                        }
                        .padding(16)

                        Divider()
                            .background(Color(red: 0.20, green: 0.22, blue: 0.31))

                        HStack(spacing: 12) {
                            Text("Show Section Titles")
                                .foregroundStyle(.white)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { local.showTitles },
                                set: {
                                    local.showTitles = $0
                                    hapticFeedback()
                                }
                            ))
                            .tint(Color(red: 0.85, green: 0.73, blue: 0.27))
                        }
                        .padding(16)

                        Divider()
                            .background(Color(red: 0.20, green: 0.22, blue: 0.31))

                        HStack(spacing: 12) {
                            Text("24-Hour Format")
                                .foregroundStyle(.white)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { local.use24hFormat },
                                set: {
                                    local.use24hFormat = $0
                                    hapticFeedback()
                                }
                            ))
                            .tint(Color(red: 0.85, green: 0.73, blue: 0.27))
                        }
                        .padding(16)

                        Divider()
                            .background(Color(red: 0.20, green: 0.22, blue: 0.31))

                        HStack(spacing: 12) {
                            Text("Show Zman Bar")
                                .foregroundStyle(.white)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { local.showZmanBar },
                                set: {
                                    local.showZmanBar = $0
                                    hapticFeedback()
                                }
                            ))
                            .tint(Color(red: 0.85, green: 0.73, blue: 0.27))
                        }
                        .padding(16)

                        Divider()
                            .background(Color(red: 0.20, green: 0.22, blue: 0.31))

                        HStack(spacing: 12) {
                            Text("Long Press Response")
                                .foregroundStyle(.white)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { local.respondLongPress },
                                set: {
                                    local.respondLongPress = $0
                                    hapticFeedback()
                                }
                            ))
                            .tint(Color(red: 0.85, green: 0.73, blue: 0.27))
                        }
                        .padding(16)
                    }
                    .glassCard()
                    .padding(.horizontal, 16)
                }

                // MARK: - Prayer Mode (Local)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Prayer Mode")
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                        .padding(.horizontal, 16)

                    VStack(spacing: 0) {
                        SettingsPickerRow(
                            label: "Tfila Mode",
                            value: local.tfilaMode.displayName,
                            onTap: {}
                        )

                        Divider()
                            .background(Color(red: 0.20, green: 0.22, blue: 0.31))

                        SettingsPickerRow(
                            label: "Silent Mode",
                            value: local.silentMode.displayName,
                            onTap: {}
                        )
                    }
                    .glassCard()
                    .padding(.horizontal, 16)
                }

                // MARK: - Temporary States (Local)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Temporary States")
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                        .padding(.horizontal, 16)

                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            Text("Avel Mode")
                                .foregroundStyle(.white)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { local.isAvel },
                                set: {
                                    local.isAvel = $0
                                    hapticFeedback()
                                }
                            ))
                            .tint(Color(red: 0.85, green: 0.73, blue: 0.27))
                        }
                        .padding(16)

                        Divider()
                            .background(Color(red: 0.20, green: 0.22, blue: 0.31))

                        HStack(spacing: 12) {
                            Text("No Tahanun")
                                .foregroundStyle(.white)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { local.noTahanun },
                                set: {
                                    local.noTahanun = $0
                                    hapticFeedback()
                                }
                            ))
                            .tint(Color(red: 0.85, green: 0.73, blue: 0.27))
                        }
                        .padding(16)

                        Divider()
                            .background(Color(red: 0.20, green: 0.22, blue: 0.31))

                        HStack(spacing: 12) {
                            Text("Vanenu (Fast Day)")
                                .foregroundStyle(.white)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { local.isVanenu },
                                set: {
                                    local.isVanenu = $0
                                    hapticFeedback()
                                }
                            ))
                            .tint(Color(red: 0.85, green: 0.73, blue: 0.27))
                        }
                        .padding(16)

                        Divider()
                            .background(Color(red: 0.20, green: 0.22, blue: 0.31))

                        HStack(spacing: 12) {
                            Text("Nachem Always")
                                .foregroundStyle(.white)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { local.nachemAlways },
                                set: {
                                    local.nachemAlways = $0
                                    hapticFeedback()
                                }
                            ))
                            .tint(Color(red: 0.85, green: 0.73, blue: 0.27))
                        }
                        .padding(16)
                    }
                    .glassCard()
                    .padding(.horizontal, 16)
                }

                // MARK: - Privacy (Local)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Privacy")
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                        .padding(.horizontal, 16)

                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            Text("Allow Tracking")
                                .foregroundStyle(.white)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { local.allowTracking },
                                set: {
                                    local.allowTracking = $0
                                    hapticFeedback()
                                }
                            ))
                            .tint(Color(red: 0.85, green: 0.73, blue: 0.27))
                        }
                        .padding(16)
                    }
                    .glassCard()
                    .padding(.horizontal, 16)
                }

                // MARK: - Account Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Account")
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                        .padding(.horizontal, 16)

                    VStack(spacing: 0) {
                        NavigationLink {
                            HomeView()
                        } label: {
                            HStack(spacing: 12) {
                                Text("Account & Sign Out")
                                    .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                            }
                            .padding(16)
                        }

                        Divider()
                            .background(Color(red: 0.20, green: 0.22, blue: 0.31))

                        HStack(spacing: 12) {
                            Text("Version")
                                .foregroundStyle(.white)
                            Spacer()
                            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                                .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                        }
                        .padding(16)
                    }
                    .glassCard()
                    .padding(.horizontal, 16)
                }

                Spacer()
                    .frame(height: 32)
            }
            .padding(.vertical, 24)
        }
        .overlay {
            if viewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .tint(Color(red: 0.85, green: 0.73, blue: 0.27))
            }
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )) {
            Button("OK") { viewModel.error = nil }
        } message: {
            Text(viewModel.error ?? "")
        }
    }

    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// MARK: - Helper Components

struct SettingsRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .foregroundStyle(.white)
            Spacer()
            Text(value)
                .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
        }
        .padding(16)
    }
}

struct SettingsPickerRow: View {
    let label: String
    let value: String
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .foregroundStyle(.white)
            Spacer()
            Text(value)
                .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
        }
        .padding(16)
    }
}
