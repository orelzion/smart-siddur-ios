import SwiftUI

/// Appearance settings: theme, font family, font size with live preview.
/// All local (UserDefaults) -- instant response, no network.
/// Redesigned with dark/gold glassmorphism theme.
struct AppearanceSettingsView: View {
    let localSettings: LocalSettings

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

            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Theme
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Theme")
                            .font(.headline)
                            .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                            .padding(.horizontal, 16)

                        VStack(spacing: 0) {
                            HStack(spacing: 12) {
                                Text("App Theme")
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            .padding(16)
                            .glassCard()
                        }
                        .padding(.horizontal, 16)
                    }

                    // MARK: - Font Family
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Font")
                            .font(.headline)
                            .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                            .padding(.horizontal, 16)

                        NavigationLink {
                            fontFamilyPickerView()
                        } label: {
                            VStack(spacing: 0) {
                                HStack(spacing: 12) {
                                    Text("Font Family")
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Text(localSettings.fontFamily.displayName)
                                        .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                                }
                                .padding(16)
                                .glassCard()
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // MARK: - Font Size
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Size")
                            .font(.headline)
                            .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                            .padding(.horizontal, 16)

                        VStack(spacing: 12) {
                            HStack {
                                Text("Font Size")
                                    .foregroundStyle(.white)
                                Spacer()
                                Text("\(Int(localSettings.fontSize)) pt")
                                    .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                            }
                            
                            Slider(
                                value: Binding(
                                    get: { Double(localSettings.fontSize) },
                                    set: { localSettings.fontSize = Float($0) }
                                ),
                                in: 12...32,
                                step: 1
                            )
                            .tint(Color(red: 0.85, green: 0.73, blue: 0.27))
                        }
                        .padding(16)
                        .glassCard()
                        .padding(.horizontal, 16)
                    }

                    // MARK: - Live Preview
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Preview")
                            .font(.headline)
                            .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                            .padding(.horizontal, 16)

                        Text("Shema Yisrael Hashem Elokeinu Hashem Echad")
                            .font(.system(size: CGFloat(localSettings.fontSize)))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(16)
                            .glassCard()
                            .padding(.horizontal, 16)
                    }

                    Spacer()
                        .frame(height: 32)
                }
                .padding(.vertical, 24)
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    @ViewBuilder
    private func fontFamilyPickerView() -> some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.06, green: 0.09, blue: 0.16),
                    Color(red: 0.01, green: 0.02, blue: 0.04)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(FontFamily.allCases, id: \.self) { family in
                        Button {
                            localSettings.fontFamily = family
                            hapticFeedback()
                        } label: {
                            HStack {
                                Text(family.displayName)
                                    .foregroundStyle(.white)
                                Spacer()
                                if family == localSettings.fontFamily {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                                }
                            }
                            .padding(16)
                            .glassCard()
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("Font Family")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
