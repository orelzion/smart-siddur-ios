import SwiftUI

/// Grouped pickers for all zmanim halachic opinions.
/// Each picker shows the current selection and available options.
/// Redesigned with dark/gold glassmorphism theme.
struct ZmanimOpinionsView: View {
    let viewModel: SettingsViewModel

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
                    // Dawn Opinion
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Dawn")
                            .font(.headline)
                            .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                        Text("Determines the earliest time for morning prayers.")
                            .font(.caption)
                            .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                        
                        NavigationLink {
                            opinionPickerView(
                                title: "Dawn (Alot HaShachar)",
                                selected: viewModel.syncedSettings.dawnOpinion,
                                options: DawnOpinion.allCases.map { ($0.displayName, $0) },
                                onSelect: { viewModel.updateDawnOpinion($0 as! DawnOpinion) }
                            )
                        } label: {
                            HStack {
                                Text(viewModel.syncedSettings.dawnOpinion.displayName)
                                    .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                            }
                            .padding(16)
                            .glassCard()
                        }
                    }
                    .padding(.horizontal, 16)

                    // Sunrise Opinion
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sunrise")
                            .font(.headline)
                            .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                        Text("Visible sunrise accounts for elevation; sea level does not.")
                            .font(.caption)
                            .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                        
                        NavigationLink {
                            opinionPickerView(
                                title: "Sunrise",
                                selected: viewModel.syncedSettings.sunriseOpinion,
                                options: SunriseOpinion.allCases.map { ($0.displayName, $0) },
                                onSelect: { viewModel.updateSunriseOpinion($0 as! SunriseOpinion) }
                            )
                        } label: {
                            HStack {
                                Text(viewModel.syncedSettings.sunriseOpinion.displayName)
                                    .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                            }
                            .padding(16)
                            .glassCard()
                        }
                    }
                    .padding(.horizontal, 16)

                    // Zman Calculation Opinion
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Zman Calculation")
                            .font(.headline)
                            .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                        Text("MGA calculates from dawn to nightfall; GRA from sunrise to sunset.")
                            .font(.caption)
                            .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                        
                        NavigationLink {
                            opinionPickerView(
                                title: "General Opinion",
                                selected: viewModel.syncedSettings.zmanOpinion,
                                options: ZmanOpinion.allCases.map { ($0.displayName, $0) },
                                onSelect: { viewModel.updateZmanOpinion($0 as! ZmanOpinion) }
                            )
                        } label: {
                            HStack {
                                Text(viewModel.syncedSettings.zmanOpinion.displayName)
                                    .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                            }
                            .padding(16)
                            .glassCard()
                        }
                    }
                    .padding(.horizontal, 16)

                    // Dusk Opinion
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Dusk")
                            .font(.headline)
                            .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                        Text("Determines nightfall for end of Shabbat and fast days.")
                            .font(.caption)
                            .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                        
                        NavigationLink {
                            opinionPickerView(
                                title: "Dusk (Tzeit HaKochavim)",
                                selected: viewModel.syncedSettings.duskOpinion,
                                options: DuskOpinion.allCases.map { ($0.displayName, $0) },
                                onSelect: { viewModel.updateDuskOpinion($0 as! DuskOpinion) }
                            )
                        } label: {
                            HStack {
                                Text(viewModel.syncedSettings.duskOpinion.displayName)
                                    .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                            }
                            .padding(16)
                            .glassCard()
                        }
                    }
                    .padding(.horizontal, 16)

                    Spacer()
                        .frame(height: 32)
                }
                .padding(.vertical, 24)
            }
        }
        .navigationTitle("Zmanim Opinions")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    @ViewBuilder
    private func opinionPickerView<T: Hashable>(
        title: String,
        selected: T,
        options: [(String, T)],
        onSelect: @escaping (T) -> Void
    ) -> some View {
        VStack {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                .padding(.top, 16)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(options, id: \.1) { label, value in
                        Button {
                            onSelect(value)
                            hapticFeedback()
                        } label: {
                            HStack {
                                Text(label)
                                    .foregroundStyle(.white)
                                Spacer()
                                if value as! AnyHashable == selected as! AnyHashable {
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
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.06, green: 0.09, blue: 0.16),
                    Color(red: 0.01, green: 0.02, blue: 0.04)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }

    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
