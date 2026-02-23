import SwiftUI

/// Month grid component with 7-column layout.
/// Each cell shows Gregorian + Hebrew dates with day markers for special days.
struct CalendarGridView: View {
    let days: [JewishDay]
    let calendarMode: CalendarMode
    let leadingEmptyCells: Int
    let dayHeaders: [String]
    let isToday: (JewishDay) -> Bool
    let isSelected: (JewishDay) -> Bool
    let onDayTap: (JewishDay) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            // Day headers
            ForEach(dayHeaders, id: \.self) { header in
                Text(header)
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }

            // Leading empty cells
            ForEach(0..<leadingEmptyCells, id: \.self) { _ in
                Color.clear
                    .frame(height: 56)
            }

            // Day cells
            ForEach(days) { day in
                CalendarDayCell(
                    day: day,
                    calendarMode: calendarMode,
                    isTodayCell: isToday(day),
                    isSelectedCell: isSelected(day)
                )
                .onTapGesture {
                    onDayTap(day)
                }
            }
        }
    }
}

// MARK: - CalendarDayCell

/// Single day cell in the calendar grid.
struct CalendarDayCell: View {
    let day: JewishDay
    let calendarMode: CalendarMode
    let isTodayCell: Bool
    let isSelectedCell: Bool

    var body: some View {
        VStack(spacing: 2) {
            if calendarMode == .gregorianPrimary {
                // Large Gregorian, small Hebrew
                Text(gregorianDay)
                    .font(.system(.body, design: .rounded, weight: isTodayCell ? .bold : .regular))
                    .foregroundStyle(isTodayCell ? .white : dayTextColor)

                Text(hebrewDay)
                    .font(.system(size: 9))
                    .foregroundStyle(isTodayCell ? .white.opacity(0.8) : .secondary)
            } else {
                // Large Hebrew, small Gregorian
                Text(hebrewDay)
                    .font(.system(.body, design: .rounded, weight: isTodayCell ? .bold : .regular))
                    .foregroundStyle(isTodayCell ? .white : dayTextColor)

                Text(gregorianDay)
                    .font(.system(size: 9))
                    .foregroundStyle(isTodayCell ? .white.opacity(0.8) : .secondary)
            }

            // Day marker dot
            dayMarker
        }
        .frame(maxWidth: .infinity, minHeight: 56)
        .background(circleBackground)
        .overlay(circleSelectionOverlay)
        .contentShape(Rectangle())
    }

    // MARK: - Computed

    private var gregorianDay: String {
        let cal = Calendar(identifier: .gregorian)
        return "\(cal.component(.day, from: day.gregorianDate))"
    }

    private var hebrewDay: String {
        HebrewDateFormatterUtil.hebrewDayString(day.hebrewDay)
    }

    private var dayTextColor: Color {
        switch day.dayType {
        case .shabbat:
            return .purple
        case .yomTov:
            return .orange
        case .fastDay:
            return .red
        case .roshChodesh:
            return .blue
        case .cholHamoed:
            return .green
        case .regular:
            return .primary
        }
    }

    @ViewBuilder
    private var circleBackground: some View {
        if isTodayCell {
            Circle()
                .fill(Color(red: 0.85, green: 0.73, blue: 0.27))
                .frame(width: 40, height: 40)
        } else if isSelectedCell {
            Circle()
                .fill(Color(red: 0.85, green: 0.73, blue: 0.27).opacity(0.18))
                .frame(width: 40, height: 40)
        }
    }

    @ViewBuilder
    private var circleSelectionOverlay: some View {
        if isSelectedCell && !isTodayCell {
            Circle()
                .stroke(Color(red: 0.85, green: 0.73, blue: 0.27), lineWidth: 1.3)
                .frame(width: 40, height: 40)
        }
    }

    @ViewBuilder
    private var dayMarker: some View {
        switch day.dayType {
        case .shabbat:
            Circle().fill(.purple).frame(width: 5, height: 5)
        case .yomTov:
            Circle().fill(.orange).frame(width: 5, height: 5)
        case .fastDay:
            Circle().fill(.red).frame(width: 5, height: 5)
        case .roshChodesh:
            Circle().fill(.blue).frame(width: 5, height: 5)
        case .cholHamoed:
            Circle().fill(.green).frame(width: 5, height: 5)
        case .regular:
            Color.clear.frame(width: 5, height: 5)
        }
    }
}
