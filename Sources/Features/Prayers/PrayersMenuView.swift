import SwiftUI

struct PrayersMenuView: View {
    @State private var viewModel: PrayersMenuViewModel
    
    init(viewModel: PrayersMenuViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.hasError {
                    errorView
                } else {
                    prayersList
                }
            }
            .navigationTitle("תפילות")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        Task {
                            await viewModel.refreshPrayers()
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .task {
                await viewModel.loadPrayers()
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading prayers...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error View
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Unable to load prayers")
                .font(.headline)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button("Try Again") {
                Task {
                    await viewModel.refreshPrayers()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Prayers List
    private var prayersList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Today's Prayers Section
                if viewModel.hasTodaysPrayers {
                    todaysPrayersSection
                        .padding(.bottom, 24)
                }
                
                // All Prayers by Category
                ForEach(viewModel.prayerSections, id: \.id) { section in
                    prayerCategorySection(section)
                        .padding(.bottom, 24)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Today's Prayers Section
    private var todaysPrayersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(
                title: "Today's Prayers",
                icon: "calendar",
                color: .blue
            )
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(viewModel.todaysPrayers, id: \.id) { prayer in
                    NavigationLink(destination: PrayerTextView(prayer: prayer)) {
                        PrayerCard(prayer: prayer, isCompact: true)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Prayer Category Section
    private func prayerCategorySection(_ section: PrayerSection) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(
                title: section.title,
                icon: iconForCategory(section.category),
                color: colorForCategory(section.category)
            )
            
            LazyVStack(spacing: 8) {
                ForEach(viewModel.prayersForSection(section), id: \.id) { prayer in
                    NavigationLink(destination: PrayerTextView(prayer: prayer)) {
                        PrayerRow(prayer: prayer)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func iconForCategory(_ category: PrayerCategory) -> String {
        switch category {
        case .daily: return "clock"
        case .blessings: return "hands.sparkles"
        case .special: return "star.circle"
        }
    }
    
    private func colorForCategory(_ category: PrayerCategory) -> Color {
        switch category {
        case .daily: return .blue
        case .blessings: return .green
        case .special: return .purple
        }
    }
}

// MARK: - Section Header
private struct SectionHeader: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 16, weight: .semibold))
            
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Prayer Row
private struct PrayerRow: View {
    let prayer: Prayer
    
    var body: some View {
        HStack(spacing: 12) {
            Text(prayer.displayName)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }
}

// MARK: - Prayer Card (for Today's Prayers)
private struct PrayerCard: View {
    let prayer: Prayer
    let isCompact: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(prayer.displayName)
                .font(.system(size: isCompact ? 16 : 20, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }
}

// MARK: - Preview
#Preview {
    let container = DependencyContainer()
    let viewModel = PrayersMenuViewModel(
        prayerService: container.prayerService,
        jewishCalendarService: container.jewishCalendarService,
        zmanimService: container.zmanimService,
        localSettings: container.localSettings,
        syncedSettings: SyncedUserSettings.defaults
    )
    
    PrayersMenuView(viewModel: viewModel)
}
