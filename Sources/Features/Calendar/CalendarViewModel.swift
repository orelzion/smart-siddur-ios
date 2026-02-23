import Foundation
import Observation

// MARK: - CalendarViewMode

/// Toggle between day and month calendar views.
enum CalendarViewMode: String, Sendable {
    case day
    case month
}

// MARK: - DateDisplayMode

/// Toggle between Hebrew and Gregorian date display.
enum DateDisplayMode: String, Sendable {
    case hebrew
    case gregorian
}

// MARK: - CalendarMode (Deprecated - use DateDisplayMode)

/// Toggle between Gregorian-primary and Hebrew-primary calendar views.
enum CalendarMode: String, Sendable {
    case gregorianPrimary
    case hebrewPrimary
}

// MARK: - CalendarViewModel

/// ViewModel for the Calendar screen.
/// Manages month navigation, day type calculations, and day detail presentation.
@MainActor
@Observable
final class CalendarViewModel {
    // MARK: - Dependencies

    private let jewishCalendarService: JewishCalendarService
    private let zmanimService: ZmanimService
    private let settingsRepository: SettingsRepositoryProtocol
    private let locationRepository: LocationRepositoryProtocol

    // MARK: - State

    /// First day of the currently displayed month.
    var currentMonth: Date

    /// Current view mode (day or month).
    var viewMode: CalendarViewMode = .month

    /// Date display mode (Hebrew or Gregorian primary).
    var dateDisplayMode: DateDisplayMode = .gregorian

    /// Calendar display mode (deprecated - use dateDisplayMode).
    var calendarMode: CalendarMode = .gregorianPrimary

    /// Currently selected date.
    var selectedDate: Date

    /// All JewishDay entries for the current month.
    var daysInMonth: [JewishDay] = []

    /// Currently selected day (tapped).
    var selectedDay: JewishDay?

    /// Whether to show the day detail sheet.
    var showDayDetail: Bool = false

    /// Whether to show all zmanim (vs. essential only).
    var showAllZmanim: Bool = false

    /// Loading state.
    var isLoading: Bool = false

    /// Whether user is in Israel (affects holidays).
    private var isInIsrael: Bool = false

    /// User location for zmanim in day detail.
    private var userLocation: UserLocation?

    /// User opinions for zmanim in day detail.
    private var userOpinions: ZmanimOpinions = .defaults

    // MARK: - Computed

    /// Month title based on current mode.
    var monthTitle: String {
        let gregorianCalendar = Calendar(identifier: .gregorian)
        let year = gregorianCalendar.component(.year, from: currentMonth)
        let month = gregorianCalendar.component(.month, from: currentMonth)

        if calendarMode == .gregorianPrimary {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: currentMonth)
        } else {
            // Hebrew-primary: show the Hebrew month(s) that span this Gregorian month
            // Use the 15th of the month as a representative date
            if let midMonth = gregorianCalendar.date(from: DateComponents(year: year, month: month, day: 15)) {
                let day = jewishCalendarService.getJewishDay(for: midMonth, isInIsrael: isInIsrael)
                let isLeap = isHebrewLeapYear(day.hebrewYear)
                let monthName = HebrewDateFormatterUtil.hebrewMonthName(month: day.hebrewMonth, isLeapYear: isLeap)
                let yearStr = HebrewDateFormatterUtil.hebrewYearString(day.hebrewYear)
                return "\(monthName) \(yearStr)"
            }
            return ""
        }
    }

    /// Day headers for the grid (Sun-Sat).
    var dayHeaders: [String] {
        ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    }

    /// Leading empty cells before the first day of the month.
    var leadingEmptyCells: Int {
        let gregorianCalendar = Calendar(identifier: .gregorian)
        let weekday = gregorianCalendar.component(.weekday, from: currentMonth)
        return weekday - 1 // Sunday = 1, so 0 empty cells for Sunday start
    }

    // MARK: - Init

    init(
        jewishCalendarService: JewishCalendarService,
        zmanimService: ZmanimService,
        settingsRepository: SettingsRepositoryProtocol,
        locationRepository: LocationRepositoryProtocol
    ) {
        self.jewishCalendarService = jewishCalendarService
        self.zmanimService = zmanimService
        self.settingsRepository = settingsRepository
        self.locationRepository = locationRepository

        // Initialize to first day of current month
        let cal = Calendar(identifier: .gregorian)
        let comps = cal.dateComponents([.year, .month], from: Date())
        self.currentMonth = cal.date(from: comps) ?? Date()
        self.selectedDate = Date()
    }

    // MARK: - Navigation

    func goToNextMonth() {
        let cal = Calendar(identifier: .gregorian)
        if let next = cal.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = next
            loadMonth()
        }
    }

    func goToPreviousMonth() {
        let cal = Calendar(identifier: .gregorian)
        if let prev = cal.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = prev
            loadMonth()
        }
    }

    func goToToday() {
        let cal = Calendar(identifier: .gregorian)
        let comps = cal.dateComponents([.year, .month], from: Date())
        currentMonth = cal.date(from: comps) ?? Date()
        loadMonth()
    }

    // MARK: - Day Selection

    func selectDay(_ day: JewishDay) {
        selectedDay = day
        showDayDetail = true
    }

    // MARK: - Loading

    /// Initial load: fetch settings and calculate month.
    func initialLoad() async {
        // Fetch settings
        do {
            let settings = try await settingsRepository.fetchSyncedSettings()
            isInIsrael = settings.isInIsrael
            userOpinions = ZmanimOpinions(
                dawnOpinion: settings.dawnOpinion,
                sunriseOpinion: settings.sunriseOpinion,
                zmanOpinion: settings.zmanOpinion,
                duskOpinion: settings.duskOpinion,
                shabbatCandleMinutes: settings.shabbatCandleMinutes,
                shabbatEndMinutes: settings.shabbatEndMinutes
            )
        } catch {
            // Use defaults
        }

        // Fetch location
        do {
            userLocation = try await locationRepository.getSelectedLocation()
        } catch {
            // No location available
        }

        loadMonth()
    }

    /// Calculate all JewishDay entries for the current month.
    func loadMonth() {
        isLoading = true
        let cal = Calendar(identifier: .gregorian)
        let year = cal.component(.year, from: currentMonth)
        let month = cal.component(.month, from: currentMonth)

        daysInMonth = jewishCalendarService.getJewishDaysForMonth(
            year: year,
            month: month,
            isInIsrael: isInIsrael
        )
        isLoading = false
    }

    // MARK: - Day Detail Data

    /// Calculate zmanim for a specific day (used by DayDetailSheet).
    func zmanimForDay(_ day: JewishDay) -> [ZmanTime] {
        guard let location = userLocation else { return [] }
        return zmanimService.calculateZmanim(
            date: day.gregorianDate,
            location: location,
            opinions: userOpinions
        )
    }

    /// Calculate Shabbat times for a specific day.
    func shabbatTimesForDay(_ day: JewishDay) -> [ZmanTime] {
        guard let location = userLocation else { return [] }
        return zmanimService.shabbatTimes(
            date: day.gregorianDate,
            location: location,
            opinions: userOpinions
        )
    }

    /// Get essential zmanim for the selected date (5-8 key times).
    var essentialZmanim: [ZmanTime] {
        guard let location = userLocation else { return [] }
        return zmanimService.calculateZmanim(
            date: selectedDate,
            location: location,
            opinions: userOpinions
        ).filter { $0.isEssential }
    }

    /// Get all zmanim for the selected date (full 16).
    var allZmanim: [ZmanTime] {
        guard let location = userLocation else { return [] }
        return zmanimService.calculateZmanim(
            date: selectedDate,
            location: location,
            opinions: userOpinions
        )
    }

    /// Get special zmanim for the selected date (Shabbat, Yom Tov, Chanukah, etc.).
    var specialZmanim: [SpecialZman] {
        guard let location = userLocation else { return [] }
        return zmanimService.specialZmanim(
            for: selectedDate,
            location: location,
            opinions: userOpinions,
            isInIsrael: isInIsrael
        )
    }

    /// Day navigation for day view mode.
    func goToNextDay() {
        let cal = Calendar(identifier: .gregorian)
        if let nextDate = cal.date(byAdding: .day, value: 1, to: selectedDate) {
            selectedDate = nextDate
            updateCurrentMonthIfNeeded()
        }
    }

    /// Previous day navigation for day view mode.
    func goToPreviousDay() {
        let cal = Calendar(identifier: .gregorian)
        if let prevDate = cal.date(byAdding: .day, value: -1, to: selectedDate) {
            selectedDate = prevDate
            updateCurrentMonthIfNeeded()
        }
    }

    /// Update the current month if selectedDate moved to a different month.
    func updateCurrentMonthIfNeeded() {
        let cal = Calendar(identifier: .gregorian)
        let selectedComps = cal.dateComponents([.year, .month], from: selectedDate)
        let currentComps = cal.dateComponents([.year, .month], from: currentMonth)
        
        if selectedComps.year != currentComps.year || selectedComps.month != currentComps.month {
            if let newMonth = cal.date(from: DateComponents(
                year: selectedComps.year,
                month: selectedComps.month,
                day: 1
            )) {
                currentMonth = newMonth
                loadMonth()
            }
        }
    }

    /// Get Jewish day info for the selected date.
    var selectedDayInfo: JewishDay? {
        daysInMonth.first { $0.gregorianDate.compare(selectedDate) == .orderedSame }
    }

    /// Get day type indicator color for a specific day.
    func dayTypeColor(for dayType: DayType) -> String {
        switch dayType {
        case .shabbat:
            return "purple"
        case .yomTov:
            return "orange"
        case .fastDay:
            return "red"
        case .roshChodesh:
            return "blue"
        case .cholHamoed:
            return "green"
        case .regular:
            return "gray"
        }
    }

    // MARK: - Helpers

    /// Check if today is in the current month.
    func isToday(_ day: JewishDay) -> Bool {
        Calendar(identifier: .gregorian).isDateInToday(day.gregorianDate)
    }

    /// Check if a Hebrew year is a leap year (has Adar I and Adar II).
    private func isHebrewLeapYear(_ year: Int) -> Bool {
        let mod = year % 19
        return [3, 6, 8, 11, 14, 17, 0].contains(mod)
    }
}
