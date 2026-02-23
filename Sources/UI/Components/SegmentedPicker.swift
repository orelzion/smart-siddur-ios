import SwiftUI

/// SegmentedPicker provides custom styling matching the design system
/// Uses gold accent for selection with glass background integration
struct SegmentedPicker<T: Hashable>: View {
    let options: [T]
    let optionLabels: [T: String]
    @Binding var selection: T
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                VStack {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selection = option
                        }
                    }) {
                        Text(optionLabels[option] ?? "")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .foregroundStyle(
                                selection == option
                                    ? Color(red: 0.01, green: 0.02, blue: 0.04)  // #020617
                                    : Color(red: 0.70, green: 0.72, blue: 0.78)   // textSecondary
                            )
                            .background(
                                selection == option
                                    ? Color(red: 0.85, green: 0.73, blue: 0.27)  // #dab946 - accentGold
                                    : Color.clear
                            )
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.11, green: 0.13, blue: 0.20))  // #1c2230
                .opacity(0.4)
        )
        .clipShape(.rect(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    Color(red: 0.20, green: 0.22, blue: 0.31),  // #343847
                    lineWidth: 1
                )
                .opacity(0.5)
        )
    }
}

#Preview {
    ZStack {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.06, green: 0.09, blue: 0.16),  // #0f172a
                Color(red: 0.01, green: 0.02, blue: 0.04)   // #020617
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack(spacing: 30) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Day / Month")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                SegmentedPicker(
                    options: ["Day", "Month"],
                    optionLabels: ["Day": "Day", "Month": "Month"],
                    selection: .constant("Day")
                )
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Hebrew / Gregorian")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                SegmentedPicker(
                    options: ["Hebrew", "Gregorian"],
                    optionLabels: ["Hebrew": "Hebrew", "Gregorian": "Gregorian"],
                    selection: .constant("Hebrew")
                )
            }
            
            Spacer()
        }
        .padding(20)
    }
}
