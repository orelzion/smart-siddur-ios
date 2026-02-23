import SwiftUI

/// Picker for selecting one of 4 nusachot (prayer rites).
/// Shows both Hebrew and English names with checkmark selection.
/// Redesigned with dark/gold glassmorphism theme.
struct NusachPickerView: View {
    let selected: Nusach
    let onSelect: (Nusach) -> Void

    @Environment(\.dismiss) private var dismiss

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
                VStack(spacing: 12) {
                    ForEach(Nusach.allCases, id: \.self) { nusach in
                        Button {
                            onSelect(nusach)
                            hapticFeedback()
                            dismiss()
                        } label: {
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(nusach.displayName)
                                        .font(.body.weight(.medium))
                                        .foregroundStyle(.white)
                                    Text(nusach.hebrewName)
                                        .font(.subheadline)
                                        .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                                }
                                Spacer()
                                if nusach == selected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                                        .font(.title3)
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
        .navigationTitle("Nusach")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
