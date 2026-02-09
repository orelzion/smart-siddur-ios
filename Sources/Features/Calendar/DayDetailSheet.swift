import SwiftUI

/// Bottom sheet shown when tapping a day in the calendar.
/// Displays Hebrew date, holiday info, parsha, omer count, Daf Yomi, and zmanim.
struct DayDetailSheet: View {
    @Environment(DependencyContainer.self) private var container
    let day: JewishDay
    let zmanim: [ZmanTime]
    let shabbatTimes: [ZmanTime]

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

                    // Show a message if no special info
                    if day.holiday == nil && day.parsha == nil && day.omerDay == nil
                        && day.dafYomi == nil && !day.isTaanis && !day.isRoshChodesh && !day.isCholHamoed {
                        Text("Regular day")
                            .foregroundStyle(.secondary)
                    }
                }

                // Shabbat times (if Friday/Shabbat)
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

                // Zmanim section
                Section("Zmanim") {
                    if zmanim.isEmpty {
                        Text("No location set")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(zmanim.filter(\.isEssential)) { zman in
                            ZmanRowView(
                                zman: zman,
                                use24h: container.localSettings.use24hFormat,
                                timeZone: .current
                            )
                        }
                    }
                }
            }
            .navigationTitle("Day Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Helpers

    private var formattedGregorianDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: day.gregorianDate)
    }
}
