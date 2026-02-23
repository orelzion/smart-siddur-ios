import SwiftUI

struct NewHomeView: View {
    @Bindable var viewModel: HomeViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.06, green: 0.09, blue: 0.16),
                    Color(red: 0.01, green: 0.02, blue: 0.04)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    greetingHeader
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        if let badge = viewModel.seasonalBadgeText {
                            seasonalBadge(badge)
                                .padding(.horizontal, 16)
                        }
                        
                        prayersSection
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 32)
            }
        }
    }
    
    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.greetingText)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color(red: 0.85, green: 0.73, blue: 0.27)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            Text(viewModel.dateText)
                .font(.subheadline)
                .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func seasonalBadge(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "leaf.fill")
                .foregroundStyle(Color(red: 0.29, green: 0.77, blue: 0.50))
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color(red: 0.29, green: 0.77, blue: 0.50))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.29, green: 0.77, blue: 0.50).opacity(0.15))
        )
    }
    
    private var prayersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("All Prayers")
                .font(.headline)
                .foregroundStyle(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(viewModel.filteredPrayers, id: \.self) { prayer in
                    HomePrayerCard(prayer: prayer)
                }
            }
        }
    }
}

struct HomePrayerCard: View {
    let prayer: PrayerType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(prayer.rawValue.capitalized)
                .font(.headline)
                .foregroundStyle(.white)
            
            Text(prayerTimeText)
                .font(.caption)
                .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.11, green: 0.13, blue: 0.20))
                .opacity(0.6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 0.20, green: 0.22, blue: 0.31), lineWidth: 1)
        )
    }
    
    private var prayerTimeText: String {
        switch prayer {
        case .shacharit: return "Morning"
        case .mincha: return "Afternoon"
        case .arvit: return "Evening"
        case .mazon: return "After meals"
        default: return "Daily"
        }
    }
}
