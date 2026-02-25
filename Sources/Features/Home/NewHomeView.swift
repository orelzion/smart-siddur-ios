import SwiftUI

struct NewHomeView: View {
    @Bindable var viewModel: HomeViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase

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
        colorScheme == .dark
            ? Color.white.opacity(0.08)
            : Color.white
    }

    private var borderColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.12)
            : Color.black.opacity(0.08)
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
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                greetingHeader
                heroCard
                suggestedSection
                prayersSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 30)
        }
        .scrollIndicators(.hidden)
        .background(backgroundGradient.ignoresSafeArea())
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .active {
                viewModel.onSceneDidBecomeActive()
            }
        }
    }

    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(viewModel.greetingText)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [primaryText, gold],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text(viewModel.dateText)
                .font(.subheadline)
                .foregroundStyle(secondaryText)
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.nextPrayerState.isTransitional ? "Between Mincha and Arvit" : heroTitle)
                .font(.headline)
                .foregroundStyle(primaryText)

            Text(viewModel.nextPrayerState.currentMilestone.displayName)
                .font(.title3.weight(.semibold))
                .foregroundStyle(gold)

            TimelineView(.periodic(from: .now, by: 1)) { context in
                Text(timeOrCountdownText(to: viewModel.nextPrayerState.currentMilestone.time, now: context.date))
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundStyle(primaryText)
                    .monospacedDigit()
            }

            Text(viewModel.nextPrayerState.currentMilestone.halachicDescription)
                .font(.subheadline)
                .foregroundStyle(secondaryText)

            HStack(spacing: 10) {
                if viewModel.nextPrayerState.isTransitional {
                    NavigationLink(destination: PrayerTextView(prayer: Prayer(type: .mincha))) {
                        heroButton("Open Mincha")
                    }
                    NavigationLink(destination: PrayerTextView(prayer: Prayer(type: .arvit))) {
                        heroButton("Open Arvit")
                    }
                } else if let prayer = viewModel.nextPrayerState.prayer {
                    NavigationLink(destination: PrayerTextView(prayer: Prayer(type: prayer))) {
                        heroButton("Open \(prayer.displayName)")
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardFill, in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(gold.opacity(0.6), lineWidth: 1)
        )
    }

    private var suggestedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Suggested For You")
                .font(.headline)
                .foregroundStyle(primaryText)

            if let badge = viewModel.seasonalBadgeText {
                HStack(spacing: 8) {
                    Image(systemName: "leaf.fill")
                    Text(badge)
                        .lineLimit(2)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color(red: 0.29, green: 0.77, blue: 0.50))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(red: 0.29, green: 0.77, blue: 0.50).opacity(0.15), in: .rect(cornerRadius: 12))
            }

            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 10) {
                ForEach(viewModel.suggestedItems) { item in
                    NavigationLink(destination: PrayerTextView(prayer: Prayer(type: item.prayerType))) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: item.icon)
                                Spacer()
                                if let badge = item.badgeText {
                                    Text(badge)
                                        .font(.caption2.weight(.semibold))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(gold.opacity(0.18), in: .capsule)
                                }
                            }
                            .foregroundStyle(gold)

                            Text(Prayer(type: item.prayerType).displayName)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(primaryText)
                                .lineLimit(2)
                                .minimumScaleFactor(0.9)

                            Spacer(minLength: 0)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 112, alignment: .topLeading)
                        .background(cardFill, in: .rect(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(borderColor, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var prayersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Prayers")
                .font(.headline)
                .foregroundStyle(primaryText)

            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 10) {
                ForEach(viewModel.filteredPrayers, id: \.self) { prayer in
                    NavigationLink(destination: PrayerTextView(prayer: Prayer(type: prayer))) {
                        VStack(alignment: .leading, spacing: 8) {
                            Image(systemName: prayer.iconName.replacingOccurrences(of: " ", with: ""))
                                .font(.headline)
                                .foregroundStyle(gold)
                            Text(prayer.displayName)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(primaryText)
                                .lineLimit(2)
                                .minimumScaleFactor(0.9)

                            Spacer(minLength: 0)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 112, alignment: .topLeading)
                        .background(cardFill, in: .rect(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(viewModel.highlightedPrayer == prayer ? gold : borderColor, lineWidth: 1.2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var heroTitle: String {
        if let prayer = viewModel.nextPrayerState.prayer {
            return "Next Prayer: \(prayer.displayName)"
        }
        return "Next Prayer Window"
    }

    private func heroButton(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color.black.opacity(0.85))
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(gold, in: .capsule)
    }

    private func timeOrCountdownText(to target: Date?, now: Date) -> String {
        guard let target else { return "--:--:--" }
        let remaining = Int(target.timeIntervalSince(now))
        if remaining <= 0 {
            return "00:00:00"
        }

        if remaining >= 3600 {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .none
            return formatter.string(from: target)
        }

        let hours = remaining / 3600
        let minutes = (remaining % 3600) / 60
        let seconds = remaining % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
