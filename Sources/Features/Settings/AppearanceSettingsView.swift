import SwiftUI

/// Appearance settings: theme, font family, font size with live preview.
/// All local (UserDefaults) -- instant response, no network.
struct AppearanceSettingsView: View {
    let localSettings: LocalSettings

    var body: some View {
        List {
            // MARK: - Theme
            Section("Theme") {
                Picker("App Theme", selection: Binding(
                    get: { localSettings.appTheme },
                    set: { localSettings.appTheme = $0 }
                )) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                }
                .pickerStyle(.segmented)
            }

            // MARK: - Font Family
            Section("Font") {
                Picker("Font Family", selection: Binding(
                    get: { localSettings.fontFamily },
                    set: { localSettings.fontFamily = $0 }
                )) {
                    ForEach(FontFamily.allCases, id: \.self) { family in
                        Text(family.displayName).tag(family)
                    }
                }
                .pickerStyle(.navigationLink)
            }

            // MARK: - Font Size
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Font Size")
                        Spacer()
                        Text("\(Int(localSettings.fontSize)) pt")
                            .foregroundStyle(.secondary)
                    }
                    Slider(
                        value: Binding(
                            get: { Double(localSettings.fontSize) },
                            set: { localSettings.fontSize = Float($0) }
                        ),
                        in: 12...32,
                        step: 1
                    )
                }
            } header: {
                Text("Size")
            }

            // MARK: - Live Preview
            Section("Preview") {
                Text("Shema Yisrael Hashem Elokeinu Hashem Echad")
                    .font(.system(size: CGFloat(localSettings.fontSize)))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}
