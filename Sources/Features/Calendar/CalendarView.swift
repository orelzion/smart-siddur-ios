import SwiftUI

struct CalendarView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel: CalendarViewModel?

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

    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.08)
    }

    private var primaryText: Color {
        colorScheme == .dark ? .white : Color(red: 0.10, green: 0.10, blue: 0.18)
    }

    private var secondaryText: Color {
        colorScheme == .dark
            ? Color(red: 0.70, green: 0.72, blue: 0.78)
            : Color(red: 0.40, green: 0.45, blue: 0.55)
    }

    private let gold = Color(red: 0.85, green: 0.73, blue: 0.27)

    var body: some View {
        Group {
            if let viewModel {
                content(viewModel)
            } else {
                ProgressView("Loading...")
                    .tint(primaryText)
                    .background(backgroundGradient.ignoresSafeArea())
            }
        }
        .navigationTitle("calendar")
        .task {
            if viewModel == nil {
                let vm = CalendarViewModel(
                    jewishCalendarService: container.jewishCalendarService,
                    zmanimService: container.zmanimService,
                    settingsRepository: container.settingsRepository,
                    locationRepository: container.locationRepository
                )
                viewModel = vm
                await vm.initialLoad()
            }
        }
    }

    private func content(_ viewModel: CalendarViewModel) -> some View {
        ScrollView {
            VStack(spacing: 14) {
                header(viewModel)
                modeControls(viewModel)
                datesCard(viewModel)
                if viewModel.viewMode == .month {
                    monthGrid(viewModel)
                }
                dayInfoCard(viewModel)
                zmanimSection(viewModel)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .background(backgroundGradient.ignoresSafeArea())
        .onChange(of: viewModel.dateDisplayMode) { _, newValue in
            viewModel.calendarMode = newValue == .gregorian ? .gregorianPrimary : .hebrewPrimary
            viewModel.loadMonth()
        }
    }

    private func header(_ viewModel: CalendarViewModel) -> some View {
        HStack(spacing: 12) {
            Button {
                if viewModel.viewMode == .month {
                    viewModel.goToPreviousMonth()
                } else {
                    viewModel.goToPreviousDay()
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .foregroundStyle(primaryText)
                    .frame(width: 34, height: 34)
                    .background(cardFill, in: .circle)
            }

            VStack(spacing: 4) {
                Text(viewModel.monthTitle)
                    .font(.headline)
                    .foregroundStyle(primaryText)
            }
            .frame(maxWidth: .infinity)

            HStack(spacing: 8) {
                Button {
                    viewModel.goToToday()
                    viewModel.selectedDate = Date()
                } label: {
                    Text("today")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(primaryText)
                        .frame(height: 34)
                        .padding(.horizontal, 10)
                        .background(cardFill, in: .capsule)
                }

                Button {
                    if viewModel.viewMode == .month {
                        viewModel.goToNextMonth()
                    } else {
                        viewModel.goToNextDay()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundStyle(primaryText)
                        .frame(width: 34, height: 34)
                        .background(cardFill, in: .circle)
                }
            }
        }
    }

    private func modeControls(_ viewModel: CalendarViewModel) -> some View {
        VStack(spacing: 10) {
            Picker("View", selection: Binding(
                get: { viewModel.viewMode },
                set: { viewModel.viewMode = $0 }
            )) {
                Text("Day").tag(CalendarViewMode.day)
                Text("Month").tag(CalendarViewMode.month)
            }
            .pickerStyle(.segmented)

            if viewModel.viewMode == .month {
                Picker("Date Mode", selection: Binding(
                    get: { viewModel.dateDisplayMode },
                    set: { viewModel.dateDisplayMode = $0 }
                )) {
                    Text("Gregorian").tag(DateDisplayMode.gregorian)
                    Text("Hebrew").tag(DateDisplayMode.hebrew)
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private func monthGrid(_ viewModel: CalendarViewModel) -> some View {
        CalendarGridView(
            days: viewModel.daysInMonth,
            calendarMode: viewModel.calendarMode,
            leadingEmptyCells: viewModel.leadingEmptyCells,
            dayHeaders: viewModel.dayHeaders,
            isToday: { viewModel.isToday($0) },
            isSelected: { day in
                Calendar(identifier: .gregorian).isDate(day.gregorianDate, inSameDayAs: viewModel.selectedDate)
            },
            onDayTap: { day in
                viewModel.selectDay(day)
            }
        )
        .padding(12)
        .background(cardFill, in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(borderColor, lineWidth: 1)
        )
        .gesture(
            DragGesture(minimumDistance: 28)
                .onEnded { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    if value.translation.width < 0 {
                        viewModel.goToNextMonth()
                    } else {
                        viewModel.goToPreviousMonth()
                    }
                }
        )
    }

    private func datesCard(_ viewModel: CalendarViewModel) -> some View {
        let day = viewModel.selectedDayInfo
        return VStack(alignment: .leading, spacing: 10) {
            if let day {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(day.hebrewDateString)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(formattedGregorianDate(day.gregorianDate))
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(primaryText)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(cardFill, in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(borderColor, lineWidth: 1)
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 28)
                .onEnded { value in
                    guard viewModel.viewMode == .day else { return }
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    if value.translation.width < 0 {
                        viewModel.goToNextDay()
                    } else {
                        viewModel.goToPreviousDay()
                    }
                }
        )
    }

    private func dayInfoCard(_ viewModel: CalendarViewModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Day Info")
                .font(.headline)
                .foregroundStyle(primaryText)

            if let day = viewModel.selectedDayInfo {
                if day.isRoshChodesh, let roshChodeshName = viewModel.roshChodeshName {
                    dayInfoRow("Rosh Chodesh", value: roshChodeshName)
                }
                if let parsha = day.parsha {
                    dayInfoRow("Parsha", value: parsha)
                }
                if let daf = day.dafYomi {
                    dayInfoRow("Daf Yomi", value: daf)
                }
                if viewModel.isShabbosMevorchim {
                    dayInfoLabelOnly("Shabbat Mevarchim")
                    if let molad = viewModel.upcomingMoladTraditionalHebrew {
                        dayInfoRow("Zman HaMolad", value: molad)
                    }
                }
                if let holiday = day.holiday {
                    dayInfoRow("Holiday", value: holiday)
                }
                ForEach(viewModel.specialZmanim.filter { !$0.name.localizedCaseInsensitiveContains("rosh chodesh") }.prefix(4), id: \.name) { special in
                    dayInfoRow(special.displayName, value: special.time.map(formattedTime) ?? "--")
                }
            } else {
                Text("Select a day in month view to see details.")
                    .font(.subheadline)
                    .foregroundStyle(secondaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(cardFill, in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(borderColor, lineWidth: 1)
        )
    }

    private func dayInfoRow(_ key: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(key)
                .foregroundStyle(secondaryText)
            Spacer()
            Text(value)
                .foregroundStyle(primaryText)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }

    private func dayInfoLabelOnly(_ text: String) -> some View {
        HStack {
            Text(text)
                .foregroundStyle(secondaryText)
            Spacer()
        }
        .font(.subheadline)
    }

    private func zmanimSection(_ viewModel: CalendarViewModel) -> some View {
        let displayedZmanim = viewModel.showAllZmanim ? viewModel.allZmanim : viewModel.essentialZmanim
        let nextUpcomingID = displayedZmanim.first(where: { ($0.time ?? .distantPast) > Date() })?.id

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("zmanim")
                    .font(.headline)
                    .foregroundStyle(primaryText)
                Spacer()
                Button(viewModel.showAllZmanim ? "Show Essential" : "Show All") {
                    viewModel.showAllZmanim.toggle()
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(gold)
            }

            ForEach(displayedZmanim) { zman in
                HStack {
                    Text(zman.primaryLabel)
                        .font(.subheadline)
                        .foregroundStyle(primaryText)
                    Spacer()
                    Text(zman.time.map(formattedTime) ?? "--")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(gold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(cardFill, in: .rect(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(nextUpcomingID == zman.id ? gold : borderColor, lineWidth: nextUpcomingID == zman.id ? 1.2 : 1)
                )
            }
        }
    }

    private func formattedGregorianDate(_ date: Date) -> String {
        LocaleFormatters.longDate(date)
    }

    private func formattedTime(_ date: Date) -> String {
        LocaleFormatters.shortTime(date, use24h: container.localSettings.use24hFormat)
    }

}
