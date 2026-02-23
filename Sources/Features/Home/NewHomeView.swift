import SwiftUI

/// NewHomeView is the redesigned home screen with dark/gold glassmorphism aesthetic.
///
/// Layout:
/// 1. Greeting header with date
/// 2. Hero card showing next prayer with countdown
/// 3. Suggested For You section with seasonal badge and suggested prayers grid
/// 4. All Prayers grid showing filtered daily prayers with current prayer highlight
///
/// Supports RTL layout and spring animations throughout.
struct NewHomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.colorScheme) var colorScheme
    
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
            
            // Content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // MARK: - Greeting Header
                    greetingHeader
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    
                    // MARK: - Hero Card (Next Prayer)
                    heroCardSection
                        .padding(.horizontal, 16)
                    
                    // MARK: - Suggested For You Section
                    suggestedSection
                        .padding(.horizontal, 16)
                    
                    // MARK: - All Prayers Grid
                    allPrayersSection
                        .padding(.horizontal, 16)
                    
                    // Bottom spacing
                    Color.clear
                        .frame(height: 20)
                }
                .padding(.bottom, 16)
            }
        }
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
    }
    
    // MARK: - Greeting Header
    
    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.greetingText)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
            
            Text(viewModel.dateText)
                .font(.subheadline)
                .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Hero Card Section
    
    private var heroCardSection: some View {
        Group {
            if viewModel.nextPrayerState != .empty {
                HeroCard(
                    prayerName: viewModel.nextPrayerState.prayer.displayName,
                    hebrewName: viewModel.nextPrayerState.prayer.hebrewName,
                    milestoneTitle: viewModel.nextPrayerState.currentMilestone.name,
                    countdown: countdownString(for: viewModel.nextPrayerState.currentMilestone.time),
                    halachicContext: viewModel.nextPrayerState.currentMilestone.halachicDescription,
                    alternativePrayer: viewModel.nextPrayerState.alternativePrayer?.displayName,
                    isTransitional: viewModel.nextPrayerState.isTransitional,
                    action: {
                        // Navigate to prayer text
                    }
                )
                .transition(.opacity.combined(with: .scale))
            } else {
                Text("Loading next prayer...")
                    .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
            }
        }
    }
    
    // MARK: - Suggested For You Section
    
    private var suggestedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title with seasonal badge
            HStack(spacing: 12) {
                Text("Suggested For You")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                if let badge = viewModel.seasonalBadge {
                    SeasonalBadge(text: badge)
                }
                
                Spacer()
            }
            
            // 2-column grid of suggested items
            if !viewModel.suggestedItems.isEmpty {
                VStack(spacing: 12) {
                    ForEach(Array(viewModel.suggestedItems.enumerated()), id: \.element.id) { idx, item in
                        if idx % 2 == 0 {
                            HStack(spacing: 12) {
                                SuggestedCard(
                                    icon: item.icon,
                                    title: item.title,
                                    badge: item.badgeText,
                                    action: {
                                        // Navigate to prayer
                                    }
                                )
                                
                                if idx + 1 < viewModel.suggestedItems.count {
                                    let nextItem = viewModel.suggestedItems[idx + 1]
                                    SuggestedCard(
                                        icon: nextItem.icon,
                                        title: nextItem.title,
                                        badge: nextItem.badgeText,
                                        action: {
                                            // Navigate to prayer
                                        }
                                    )
                                } else {
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - All Prayers Grid Section
    
    private var allPrayersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("All Prayers")
                .font(.headline)
                .foregroundStyle(.white)
            
            // 2-column grid
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                ForEach(viewModel.gridPrayers) { prayer in
                    prayerGridCell(for: prayer)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Prayer Grid Cell
    
    private func prayerGridCell(for prayer: Prayer) -> some View {
        let isCurrentPrayer = viewModel.nextPrayerState.prayer == prayer.type
        
        return Button(action: {
            // Navigate to prayer text
        }) {
            VStack(spacing: 12) {
                Image(systemName: prayer.type.iconName)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(
                        isCurrentPrayer
                            ? Color(red: 0.85, green: 0.73, blue: 0.27)  // Gold for current
                            : Color(red: 0.70, green: 0.72, blue: 0.78)  // Gray otherwise
                    )
                
                VStack(spacing: 4) {
                    Text(prayer.displayName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    
                    Text(prayer.hebrewName)
                        .font(.caption2)
                        .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                }
                
                Spacer()
            }
            .padding(16)
            .frame(minHeight: 120)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.11, green: 0.13, blue: 0.20))
                    .opacity(0.4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isCurrentPrayer
                            ? LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.85, green: 0.73, blue: 0.27),  // accentGold
                                    Color(red: 0.72, green: 0.58, blue: 0.12)   // accentGoldDark
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.50, green: 0.52, blue: 0.58),
                                    Color(red: 0.40, green: 0.42, blue: 0.48)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                        lineWidth: isCurrentPrayer ? 2 : 1
                    )
            )
        }
        .scaleEffect(0.98)
        .hoverEffect(.lift)
    }
    
    // MARK: - Helpers
    
    private func countdownString(for time: Date?) -> String {
        guard let time = time else { return "00:00" }
        
        let now = Date()
        let interval = time.timeIntervalSince(now)
        
        if interval <= 0 {
            return "00:00"
        }
        
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

#Preview {
    let container = DependencyContainer.shared
    let viewModel = HomeViewModel(dependencyContainer: container)
    
    NewHomeView(viewModel: viewModel)
}
