import SwiftUI

/// A single row displaying a zman name and its time.
/// Highlighted state for the next upcoming zman.
struct ZmanRowView: View {
    let zman: ZmanTime
    let use24h: Bool
    let timeZone: TimeZone

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(zman.primaryLabel)
                    .font(zman.isNextUpcoming ? .body.bold() : .body)
                    .foregroundStyle(zman.isNextUpcoming ? Color.accentColor : .primary)
            }

            Spacer()

            Text(zman.formattedTime(use24h: use24h, timeZone: timeZone))
                .font(zman.isNextUpcoming ? .body.bold().monospacedDigit() : .body.monospacedDigit())
                .foregroundStyle(zman.isNextUpcoming ? Color.accentColor : .primary)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, zman.isNextUpcoming ? 8 : 0)
        .background(
            zman.isNextUpcoming
                ? Color.accentColor.opacity(0.1)
                : Color.clear
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
