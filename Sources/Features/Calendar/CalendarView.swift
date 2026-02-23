import SwiftUI

/// Unified Calendar/Zmanim Tab - supports both Month View and Day View.
/// Shows Jewish calendar with dates, holidays, zmanim, and special times.
/// Features:
/// - Month View: 7-column grid with day indicators and inline day detail
/// - Day View: Full-screen day display with swipe navigation
/// - Dual date display (Hebrew/Gregorian toggle)
/// - Special zmanim display (Shabbat candles, Chanukah, fast days, etc.)
/// - RTL layout support
struct UnifiedCalendarView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: CalendarViewModel?
    @State private var horizontalSwipeOffset: CGFloat = 0

    var body: some View {
        Group {
            if let viewModel {
                unifiedCalendarContent(viewModel: viewModel)
            } else {
                ProgressView("Loading...")
            }
        }
        .navigationTitle("Calendar & Zmanim")
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
    private func unifiedCalendarContent(viewModel: CalendarViewModel) -> some View {
        VStack(spacing: 0) {
            // Top controls: view mode and date display mode
            HStack(spacing: 12) {
                // View mode toggle
                SegmentedPicker(
                    options: [CalendarViewMode.month, CalendarViewMode.day],
                    optionLabels: [
                        CalendarViewMode.month: "Month",
                        CalendarViewMode.day: "Day"
                    ],
                    selection: Binding(
                        get: { viewModel.viewMode },
                        set: { viewModel.viewMode = $0 }
                    )
                )
                
                Spacer()
                
                // Date display mode toggle
                SegmentedPicker(
                    options: [DateDisplayMode.gregorian, DateDisplayMode.hebrew],
                    optionLabels: [
                        DateDisplayMode.gregorian: "Gregorian",
                        DateDisplayMode.hebrew: "עברית"
                    ],
                    selection: Binding(
                        get: { viewModel.dateDisplayMode },
                        set: { viewModel.dateDisplayMode = $0 }
                    )
                )
            }
            .padding(16)
            
            Divider()
                .background(Color(red: 0.20, green: 0.26, blue: 0.42))
            
            // Content based on view mode
            if viewModel.viewMode == .month {
                monthViewContent(viewModel: viewModel)
            } else {
                dayViewContent(viewModel: viewModel)
            }
        }
    }

    // MARK: - Month View
    
    @ViewBuilder
    private func monthViewContent(viewModel: CalendarViewModel) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                // Month header with navigation
                monthNavigationHeader(viewModel: viewModel)
                
                // 7-column grid
                monthGridSection(viewModel: viewModel)
                
                // Inline day detail
                if let selectedDay = viewModel.selectedDay {
                    dayDetailSection(viewModel: viewModel, day: selectedDay)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                
                Spacer(minLength: 20)
            }
            .padding(16)
        }
    }

    @ViewBuilder
    private func monthNavigationHeader(viewModel: CalendarViewModel) -> some View {
        HStack(spacing: 12) {
            // Previous month button
            Button {
                viewModel.goToPreviousMonth()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                    .frame(width: 32, height: 32)
            }
            
            Spacer()
            
            // Month title
            VStack(spacing: 2) {
                Text(viewModel.monthTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                
                let selectedDateFormatter = DateFormatter()
                selectedDateFormatter.dateFormat = "EEEE"
                Text(selectedDateFormatter.string(from: viewModel.selectedDate))
                    .font(.caption)
                    .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
            }
            
            Spacer()
            
            // Today + Next month buttons
            HStack(spacing: 12) {
                Button {
                    viewModel.goToToday()
                } label: {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                        .frame(width: 32, height: 32)
                }
                
                Button {
                    viewModel.goToNextMonth()
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                        .frame(width: 32, height: 32)
                }
            }
        }
    }

    @ViewBuilder
    private func monthGridSection(viewModel: CalendarViewModel) -> some View {
        VStack(spacing: 8) {
            // Day headers (Sun-Sat)
            HStack(spacing: 0) {
                ForEach(viewModel.dayHeaders, id: \.self) { header in
                    Text(header)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                }
            }
            
            // Grid of days
            let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
            LazyVGrid(columns: columns, spacing: 8) {
                // Leading empty cells
                ForEach(0..<viewModel.leadingEmptyCells, id: \.self) { _ in
                    Color.clear
                        .frame(height: 56)
                }
                
                // Days in month
                ForEach(viewModel.daysInMonth, id: \.id) { day in
                    dayCell(viewModel: viewModel, day: day)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .animation(.easeInOut(duration: 0.15), value: viewModel.daysInMonth)
        }
        .padding(12)
        .glassCard(cornerRadius: 16)
    }

    @ViewBuilder
    private func dayCell(viewModel: CalendarViewModel, day: JewishDay) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                viewModel.selectedDay = day
                viewModel.selectedDate = day.gregorianDate
            }
        } label: {
            VStack(spacing: 2) {
                // Primary date (large)
                Text("\(day.hebrewDay)")
                    .font(.system(.body, design: .default))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                
                // Secondary date (tiny)
                let gregFormatter = DateFormatter()
                gregFormatter.dateFormat = "d"
                Text(gregFormatter.string(from: day.gregorianDate))
                    .font(.system(size: 10))
                    .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                ZStack {
                    // Background color based on selection
                    if viewModel.isToday(day) {
                        Circle()
                            .fill(Color(red: 0.85, green: 0.73, blue: 0.27).opacity(0.3))
                    }
                    
                    if day.gregorianDate.compare(viewModel.selectedDate) == .orderedSame {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 0.85, green: 0.73, blue: 0.27), lineWidth: 2)
                    }
                }
            )
            .overlay(alignment: .bottom) {
                // Day type indicator dot
                Circle()
                    .fill(dayTypeColor(viewModel: viewModel, dayType: day.dayType))
                    .frame(width: 6, height: 6)
                    .padding(.bottom, 4)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    @ViewBuilder
    private func dayDetailSection(viewModel: CalendarViewModel, day: JewishDay) -> some View {
        VStack(spacing: 16) {
            // Day Info Card
            DayInfoCard(
                jewishDay: day,
                specialZmanim: viewModel.specialZmanim,
                showHebrewDates: viewModel.dateDisplayMode == .hebrew
            )
            
            // Zmanim toggle and list
            zmanimSection(viewModel: viewModel)
        }
    }

    // MARK: - Day View
    
    @ViewBuilder
    private func dayViewContent(viewModel: CalendarViewModel) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                // Day navigation header
                dayViewNavigationHeader(viewModel: viewModel)
                
                // Single day info card
                if let dayInfo = viewModel.selectedDayInfo {
                    DayInfoCard(
                        jewishDay: dayInfo,
                        specialZmanim: viewModel.specialZmanim,
                        showHebrewDates: viewModel.dateDisplayMode == .hebrew
                    )
                }
                
                // Full zmanim section
                zmanimSection(viewModel: viewModel)
                
                Spacer(minLength: 20)
            }
            .padding(16)
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    let threshold: CGFloat = 50
                    if value.translation.width > threshold {
                        // Swiped right -> previous day
                        viewModel.goToPreviousDay()
                    } else if value.translation.width < -threshold {
                        // Swiped left -> next day
                        viewModel.goToNextDay()
                    }
                }
        )
    }

    @ViewBuilder
    private func dayViewNavigationHeader(viewModel: CalendarViewModel) -> some View {
        HStack(spacing: 12) {
            // Previous day
            Button {
                viewModel.goToPreviousDay()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                    .frame(width: 32, height: 32)
            }
            
            Spacer()
            
            // Date display
            let selectedFormatter = DateFormatter()
            selectedFormatter.dateFormat = "EEEE, MMM d"
            Text(selectedFormatter.string(from: viewModel.selectedDate))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            
            Spacer()
            
            // Today + Next day
            HStack(spacing: 12) {
                Button {
                    viewModel.selectedDate = Date()
                    viewModel.updateCurrentMonthIfNeeded()
                } label: {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                        .frame(width: 32, height: 32)
                }
                
                Button {
                    viewModel.goToNextDay()
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                        .frame(width: 32, height: 32)
                }
            }
        }
    }

    // MARK: - Shared Zmanim Section
    
    @ViewBuilder
    private func zmanimSection(viewModel: CalendarViewModel) -> some View {
        VStack(spacing: 12) {
            // Toggle button for essential vs all
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    viewModel.showAllZmanim.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.showAllZmanim ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                    
                    Text(viewModel.showAllZmanim ? "Show Essential Zmanim" : "Show All Zmanim (16)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.10, green: 0.14, blue: 0.26).opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Zmanim list
            let zmanim = viewModel.showAllZmanim ? viewModel.allZmanim : viewModel.essentialZmanim
            
            VStack(spacing: 8) {
                ForEach(zmanim, id: \.id) { zman in
                    zmanimRow(zman: zman)
                }
            }
        }
    }

    @ViewBuilder
    private func zmanimRow(zman: ZmanTime) -> some View {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let timeString = zman.time.map { timeFormatter.string(from: $0) } ?? "--:--"
        
        ZmanRow(
            icon: zmanimIcon(for: zman.category),
            label: zman.name,
            time: timeString,
            isNextUpcoming: zman.isNextUpcoming
        )
    }

    // MARK: - Helpers
    
    private func dayTypeColor(viewModel: CalendarViewModel, dayType: DayType) -> Color {
        switch dayType {
        case .shabbat:
            return Color(red: 0.63, green: 0.31, blue: 0.78)  // purple
        case .yomTov:
            return Color(red: 1.0, green: 0.65, blue: 0.0)   // orange
        case .fastDay:
            return Color(red: 1.0, green: 0.27, blue: 0.27)  // red
        case .roshChodesh:
            return Color(red: 0.27, green: 0.52, blue: 1.0)  // blue
        case .cholHamoed:
            return Color(red: 0.30, green: 0.86, blue: 0.39) // green
        case .regular:
            return Color(red: 0.56, green: 0.56, blue: 0.58) // gray
        }
    }

    private func zmanimIcon(for category: ZmanCategory) -> String {
        switch category {
        case .dawn:
            return "sun.max"
        case .morning:
            return "sunrise"
        case .midday:
            return "sun.max.fill"
        case .afternoon:
            return "sun.max"
        case .evening:
            return "sunset"
        case .night:
            return "moon.stars"
        case .shabbat:
            return "star.fill"
        }
    }
}

// For backward compatibility
typealias CalendarView = UnifiedCalendarView
