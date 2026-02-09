import SwiftUI

/// Full calendar screen (Tab 2).
/// Shows month grid with Hebrew dates overlaid, navigation arrows,
/// Gregorian/Hebrew toggle, and day detail sheets.
struct CalendarView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: CalendarViewModel?

    var body: some View {
        Group {
            if let viewModel {
                calendarContent(viewModel: viewModel)
            } else {
                ProgressView("Loading...")
            }
        }
        .navigationTitle("Calendar")
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

    @ViewBuilder
    private func calendarContent(viewModel: CalendarViewModel) -> some View {
        VStack(spacing: 0) {
            // Month navigation header
            monthHeader(viewModel: viewModel)

            Divider()

            // Calendar grid
            ScrollView {
                CalendarGridView(
                    days: viewModel.daysInMonth,
                    calendarMode: viewModel.calendarMode,
                    leadingEmptyCells: viewModel.leadingEmptyCells,
                    dayHeaders: viewModel.dayHeaders,
                    isToday: { viewModel.isToday($0) },
                    onDayTap: { day in
                        viewModel.selectDay(day)
                    }
                )
                .padding(.horizontal, 8)
                .padding(.top, 8)
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel.showDayDetail },
            set: { viewModel.showDayDetail = $0 }
        )) {
            if let day = viewModel.selectedDay {
                DayDetailSheet(
                    day: day,
                    zmanim: viewModel.zmanimForDay(day),
                    shabbatTimes: viewModel.shabbatTimesForDay(day)
                )
                .presentationDetents([.medium, .large])
            }
        }
    }

    @ViewBuilder
    private func monthHeader(viewModel: CalendarViewModel) -> some View {
        HStack {
            // Previous month
            Button {
                viewModel.goToPreviousMonth()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
            }

            Spacer()

            // Month title
            VStack(spacing: 2) {
                Text(viewModel.monthTitle)
                    .font(.headline)

                // Toggle button
                Button {
                    viewModel.calendarMode = viewModel.calendarMode == .gregorianPrimary
                        ? .hebrewPrimary
                        : .gregorianPrimary
                } label: {
                    Text(viewModel.calendarMode == .gregorianPrimary ? "\u{05E2}\u{05D1}\u{05E8}\u{05D9}" : "Gregorian")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.accentColor.opacity(0.15)))
                }
            }

            Spacer()

            // Today button + next month
            HStack(spacing: 12) {
                Button {
                    viewModel.goToToday()
                } label: {
                    Image(systemName: "calendar.badge.clock")
                        .font(.title3)
                }

                Button {
                    viewModel.goToNextMonth()
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
