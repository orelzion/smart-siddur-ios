import SwiftUI

/// Main Settings screen organized into sections covering all synced and local settings.
/// Per MIGRATION_SPEC Sections 6.2 (synced) and 6.3 (local).
struct SettingsView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel: SettingsViewModel?
    @State private var showLocationPicker = false

    private var backgroundGradient: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.09, blue: 0.16),
                    Color(red: 0.01, green: 0.02, blue: 0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [
                Color(red: 0.98, green: 0.97, blue: 0.96),
                Color.white
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var cardFill: Color {
        colorScheme == .dark ? Color.white.opacity(0.08) : Color.white
    }

    private var headerTint: Color {
        Color(red: 0.85, green: 0.73, blue: 0.27)
    }

    var body: some View {
        Group {
            if let viewModel {
                settingsContent(viewModel: viewModel)
            } else {
                ProgressView("Loading settings...")
            }
        }
        .navigationTitle("Settings")
        .background(backgroundGradient.ignoresSafeArea())
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

        List {
            // MARK: - Identity Section
            Section("Identity") {
                NavigationLink {
                    NusachPickerView(
                        selected: viewModel.syncedSettings.nusach,
                        onSelect: { viewModel.updateNusach($0) }
                    )
                } label: {
                    HStack {
                        Text("Nusach")
                        Spacer()
                        Text(viewModel.syncedSettings.nusach.displayName)
                            .foregroundStyle(.secondary)
                    }
                }

                Toggle("Woman", isOn: Binding(
                    get: { viewModel.syncedSettings.isWoman },
                    set: { viewModel.updateIsWoman($0) }
                ))

                Picker("Language", selection: Binding(
                    get: { viewModel.syncedSettings.language },
                    set: { viewModel.updateLanguage($0) }
                )) {
                    ForEach(AppLanguage.allCases, id: \.self) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }

                // Location row
                NavigationLink {
                    LocationPickerView()
                } label: {
                    HStack {
                        Text("Location")
                        Spacer()
                        if let loc = container.selectedLocationName {
                            Text(loc)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        } else {
                            Text("Not set")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .listRowBackground(cardFill)

            // MARK: - Location/Calendar Section
            Section("Location & Calendar") {
                Toggle("In Israel", isOn: Binding(
                    get: { viewModel.syncedSettings.isInIsrael },
                    set: { viewModel.updateIsInIsrael($0) }
                ))

                Toggle("Mizrochnik", isOn: Binding(
                    get: { viewModel.syncedSettings.isMizrochnik },
                    set: { viewModel.updateIsMizrochnik($0) }
                ))

                Picker("Mukaf Mode", selection: Binding(
                    get: { viewModel.syncedSettings.mukafMode },
                    set: { viewModel.updateMukafMode($0) }
                )) {
                    ForEach(MukafMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }

                Picker("Date Change", selection: Binding(
                    get: { viewModel.syncedSettings.dateChangeRule },
                    set: { viewModel.updateDateChangeRule($0) }
                )) {
                    ForEach(DateChangeRule.allCases, id: \.self) { rule in
                        Text(rule.displayName).tag(rule)
                    }
                }
            }
            .listRowBackground(cardFill)

            // MARK: - Zmanim Opinions Section
            Section("Zmanim Opinions") {
                NavigationLink {
                    ZmanimOpinionsView(viewModel: viewModel)
                } label: {
                    HStack {
                        Text("Halachic Opinions")
                        Spacer()
                        Text(viewModel.syncedSettings.zmanOpinion.displayName)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .listRowBackground(cardFill)

            // MARK: - Personal Insertions Section
            Section("Personal Insertions") {
                HStack {
                    Text("Pasuk")
                    Spacer()
                    TextField("Your personal verse", text: Binding(
                        get: { viewModel.syncedSettings.pasuk },
                        set: { viewModel.updatePasuk($0) }
                    ))
                    .multilineTextAlignment(.trailing)
                    .textFieldStyle(.plain)
                }

                HStack {
                    Text("Sick Name")
                    Spacer()
                    TextField("Name for Mi Sheberach", text: Binding(
                        get: { viewModel.syncedSettings.sickName },
                        set: { viewModel.updateSickName($0) }
                    ))
                    .multilineTextAlignment(.trailing)
                    .textFieldStyle(.plain)
                }

                Toggle("Include Tal", isOn: Binding(
                    get: { viewModel.syncedSettings.talPreference },
                    set: { viewModel.updateTalPreference($0) }
                ))
            }
            .listRowBackground(cardFill)

            // MARK: - Shabbat Section
            Section("Shabbat") {
                Stepper(
                    "Candle Lighting: \(viewModel.syncedSettings.shabbatCandleMinutes) min before",
                    value: Binding(
                        get: { viewModel.syncedSettings.shabbatCandleMinutes },
                        set: { viewModel.updateShabbatCandleMinutes($0) }
                    ),
                    in: 10...40
                )

                Stepper(
                    "Shabbat Ends: \(viewModel.syncedSettings.shabbatEndMinutes) min after",
                    value: Binding(
                        get: { viewModel.syncedSettings.shabbatEndMinutes },
                        set: { viewModel.updateShabbatEndMinutes($0) }
                    ),
                    in: 1...72
                )
            }
            .listRowBackground(cardFill)

            // MARK: - Appearance Section (Local)
            Section("Appearance") {
                NavigationLink {
                    AppearanceSettingsView(localSettings: local)
                } label: {
                    HStack {
                        Text("Theme & Fonts")
                        Spacer()
                        Text(local.appTheme.displayName)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .listRowBackground(cardFill)

            // MARK: - Display Preferences (Local)
            Section("Display") {
                Toggle("Keep Screen Awake", isOn: Binding(
                    get: { local.keepScreenAwake },
                    set: { local.keepScreenAwake = $0 }
                ))

                Toggle("Portrait Only", isOn: Binding(
                    get: { local.portraitOnly },
                    set: { local.portraitOnly = $0 }
                ))

                Toggle("Show Section Titles", isOn: Binding(
                    get: { local.showTitles },
                    set: { local.showTitles = $0 }
                ))

                Toggle("24-Hour Format", isOn: Binding(
                    get: { local.use24hFormat },
                    set: { local.use24hFormat = $0 }
                ))

                Toggle("Show Zman Bar", isOn: Binding(
                    get: { local.showZmanBar },
                    set: { local.showZmanBar = $0 }
                ))

                Toggle("Long Press Response", isOn: Binding(
                    get: { local.respondLongPress },
                    set: { local.respondLongPress = $0 }
                ))
            }
            .listRowBackground(cardFill)

            // MARK: - Prayer Mode (Local)
            Section("Prayer Mode") {
                Picker("Tfila Mode", selection: Binding(
                    get: { local.tfilaMode },
                    set: { local.tfilaMode = $0 }
                )) {
                    ForEach(TfilaMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }

                Picker("Silent Mode", selection: Binding(
                    get: { local.silentMode },
                    set: { local.silentMode = $0 }
                )) {
                    ForEach(SilentMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
            }
            .listRowBackground(cardFill)

            // MARK: - Temporary States (Local)
            Section("Temporary States") {
                Toggle("Avel Mode", isOn: Binding(
                    get: { local.isAvel },
                    set: { local.isAvel = $0 }
                ))

                Toggle("No Tahanun", isOn: Binding(
                    get: { local.noTahanun },
                    set: { local.noTahanun = $0 }
                ))

                Toggle("Vanenu (Fast Day)", isOn: Binding(
                    get: { local.isVanenu },
                    set: { local.isVanenu = $0 }
                ))

                Toggle("Nachem Always", isOn: Binding(
                    get: { local.nachemAlways },
                    set: { local.nachemAlways = $0 }
                ))
            }
            .listRowBackground(cardFill)

            // MARK: - Privacy (Local)
            Section("Privacy") {
                Toggle("Allow Tracking", isOn: Binding(
                    get: { local.allowTracking },
                    set: { local.allowTracking = $0 }
                ))
            }
            .listRowBackground(cardFill)

            // MARK: - Account Section
            Section("Account") {
                NavigationLink {
                    HomeView()
                } label: {
                    Text("Account & Sign Out")
                }

                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                        .foregroundStyle(.secondary)
                }
            }
            .listRowBackground(cardFill)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(backgroundGradient.ignoresSafeArea())
        .tint(headerTint)
        .environment(\.defaultMinListRowHeight, 46)
        .overlay {
            if viewModel.isLoading {
                ProgressView()
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
}
