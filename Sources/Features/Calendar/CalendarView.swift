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

            // Month title + mode picker
            VStack(spacing: 4) {
                Text(viewModel.monthTitle)
                    .font(.headline)

                // Segmented control for calendar mode
                Picker("Calendar Mode", selection: Binding(
                    get: { viewModel.calendarMode },
                    set: { viewModel.calendarMode = $0 }
                )) {
                    Text("Gregorian")
                        .tag(CalendarMode.gregorianPrimary)
                    Text("\u{05E2}\u{05D1}\u{05E8}\u{05D9}")
                        .tag(CalendarMode.hebrewPrimary)
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
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
