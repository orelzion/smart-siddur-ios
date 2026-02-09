import SwiftUI

/// Bottom sheet shown when tapping a day in the calendar.
/// Shows Hebrew date, day info, sunrise/sunset + special zmanim only,
/// with a "View Full Zmanim" button to navigate to the Zmanim tab.
struct DayDetailSheet: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss
    let day: JewishDay
    let zmanim: [ZmanTime]
    let shabbatTimes: [ZmanTime]

    /// Only sunrise and sunset from the full zmanim list.
    private var keyZmanim: [ZmanTime] {
        zmanim.filter { $0.id == "netz" || $0.id == "shkia" }
    }

    var body: some View {
        NavigationStack {
            List {
                // Header: Full dates
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(day.hebrewDateString)
                            .font(.title2.bold())

                        Text(formattedGregorianDate)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                // Day Info section
                if hasDayInfo {
                    Section("Day Info") {
                        // Holiday
                        if let holiday = day.holiday {
                            Label {
                                Text(holiday)
                                    .font(.body.bold())
                                    .foregroundStyle(.orange)
                            } icon: {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.orange)
                            }
                        }

                        // Parsha (Shabbat only)
                        if let parsha = day.parsha {
                            Label {
                                Text("Parashat \(parsha)")
                            } icon: {
                                Image(systemName: "book.fill")
                                    .foregroundStyle(.purple)
                            }
                        }

                        // Omer count
                        if let omer = day.omerDay {
                            Label {
                                Text("Day \(omer) of the Omer")
                            } icon: {
                                Image(systemName: "number.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }

                        // Daf Yomi
                        if let daf = day.dafYomi {
                            Label {
                                Text("Daf Yomi: \(daf)")
                            } icon: {
                                Image(systemName: "text.book.closed.fill")
                                    .foregroundStyle(.blue)
                            }
                        }

                        // Fast day
                        if day.isTaanis {
                            Label {
                                Text("Fast Day")
                                    .foregroundStyle(.red)
                            } icon: {
                                Image(systemName: "moon.circle.fill")
                                    .foregroundStyle(.red)
                            }
                        }

                        // Rosh Chodesh
                        if day.isRoshChodesh {
                            Label {
                                Text("Rosh Chodesh")
                            } icon: {
                                Image(systemName: "moon.stars.fill")
                                    .foregroundStyle(.blue)
                            }
                        }

                        // Chol HaMoed
                        if day.isCholHamoed {
                            Label {
                                Text("Chol HaMoed")
                            } icon: {
                                Image(systemName: "leaf.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }

                // Shabbat times (candle lighting / havdalah)
                if !shabbatTimes.isEmpty {
                    Section("Shabbat Times") {
                        ForEach(shabbatTimes) { zman in
                            ZmanRowView(
                                zman: zman,
                                use24h: container.localSettings.use24hFormat,
                                timeZone: .current
                            )
                        }
                    }
                }

                // Key zmanim: sunrise and sunset only
                if !keyZmanim.isEmpty {
                    Section("Sun Times") {
                        ForEach(keyZmanim) { zman in
                            ZmanRowView(
                                zman: zman,
                                use24h: container.localSettings.use24hFormat,
                                timeZone: .current
                            )
                        }
                    }
                }

                // View Full Zmanim button
                Section {
                    Button {
                        navigateToFullZmanim()
                    } label: {
                        HStack {
                            Image(systemName: "clock.fill")
                            Text("View Full Zmanim")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Day Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Helpers

    private var hasDayInfo: Bool {
        day.holiday != nil || day.parsha != nil || day.omerDay != nil
            || day.dafYomi != nil || day.isTaanis || day.isRoshChodesh || day.isCholHamoed
    }

    private var formattedGregorianDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: day.gregorianDate)
    }

    /// Dismiss the sheet, set the date override, and switch to the Zmanim tab.
    private func navigateToFullZmanim() {
        container.zmanimDateOverride = day.gregorianDate
        container.selectedTab = 0
        dismiss()
    }
}
