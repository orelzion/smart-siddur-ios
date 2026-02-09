import SwiftUI

/// Picker for selecting one of 4 nusachot (prayer rites).
/// Shows both Hebrew and English names with checkmark selection.
struct NusachPickerView: View {
    let selected: Nusach
    let onSelect: (Nusach) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(Nusach.allCases, id: \.self) { nusach in
                Button {
                    onSelect(nusach)
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(nusach.displayName)
                                .foregroundStyle(.primary)
                            Text(nusach.hebrewName)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if nusach == selected {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                                .fontWeight(.semibold)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Nusach")
        .navigationBarTitleDisplayMode(.inline)
    }
}
