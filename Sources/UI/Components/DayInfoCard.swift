import SwiftUI

/// DayInfoCard displays comprehensive day information including Hebrew date, Gregorian date,
/// Parsha, Daf Yomi, and conditionally shown special zmanim (Shabbat, Yom Tov, Chanukah, etc.)
struct DayInfoCard: View {
    /// The Jewish day information to display
    let jewishDay: JewishDay
    
    /// Special zmanim for this day (from ZmanimService.specialZmanim)
    let specialZmanim: [SpecialZman]
    
    /// Whether to show this in Hebrew or English
    let showHebrewDates: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            // Primary date section
            VStack(spacing: 8) {
                // Hebrew date (always primary)
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                    
                    Text(jewishDay.hebrewDateString)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Gregorian date (secondary)
                let gregorianFormatter = DateFormatter()
                gregorianFormatter.dateFormat = "EEEE, MMMM d, yyyy"
                Text(gregorianFormatter.string(from: jewishDay.gregorianDate))
                    .font(.callout)
                    .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Divider()
                .background(Color(red: 0.20, green: 0.26, blue: 0.42))
            
            // Parsha (if Shabbat)
            if let parsha = jewishDay.parsha {
                VStack(spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                        
                        Text("Parsha")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                        
                        Spacer()
                    }
                    
                    Text(parsha)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            // Daf Yomi
            if let dafYomi = jewishDay.dafYomi {
                VStack(spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "book.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                        
                        Text("Daf Yomi")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                        
                        Spacer()
                    }
                    
                    Text(dafYomi)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            // Holiday/Yom Tov (if applicable)
            if let holiday = jewishDay.holiday {
                VStack(spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                        
                        Text("Holiday")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                        
                        Spacer()
                    }
                    
                    Text(holiday)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            // Omer count (if during Sefirat HaOmer)
            if let omerDay = jewishDay.omerDay {
                VStack(spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "number.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                        
                        Text("Sefirat HaOmer")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                        
                        Spacer()
                    }
                    
                    let weekNumber = (omerDay - 1) / 7 + 1
                    let dayInWeek = (omerDay - 1) % 7 + 1
                    let omerDisplay = omerDay <= 7 ? "Day \(omerDay)" : "Week \(weekNumber), Day \(dayInWeek)"
                    
                    Text(omerDisplay)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            // Special zmanim (Shabbat, Yom Tov, Chanukah, etc.)
            if !specialZmanim.isEmpty {
                Divider()
                    .background(Color(red: 0.20, green: 0.26, blue: 0.42))
                
                VStack(spacing: 12) {
                    Text("Special Times")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach(specialZmanim, id: \.name) { zman in
                        specialZmanSection(zman)
                    }
                }
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 16)
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    func specialZmanSection(_ zman: SpecialZman) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(zman.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    
                    Text(zman.context)
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                        .lineLimit(2)
                }
                
                Spacer()
                
                if let time = zman.time {
                    let timeFormatter = DateFormatter()
                    timeFormatter.timeStyle = .short
                    Text(timeFormatter.string(from: time))
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
                } else {
                    Text("--:--")
                        .font(.body)
                        .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                }
            }
            .padding(10)
            .background(Color(red: 0.10, green: 0.14, blue: 0.26).opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.06, green: 0.09, blue: 0.16),  // #0f172a
                Color(red: 0.01, green: 0.02, blue: 0.04)   // #020617
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack(spacing: 20) {
            DayInfoCard(
                jewishDay: JewishDay(
                    gregorianDate: Date(),
                    hebrewDay: 15,
                    hebrewMonth: 5,
                    hebrewYear: 5785,
                    hebrewDateString: "ט״ו שבט ה׳תשפ״ה",
                    parsha: "Parashat Beshalach",
                    holiday: nil,
                    isShabbat: true,
                    isYomTov: false,
                    isCholHamoed: false,
                    isRoshChodesh: false,
                    isTaanis: false,
                    omerDay: nil,
                    dafYomi: "Daf 45a",
                    dayType: .shabbat,
                    yomTovIndex: 0,
                    isChanukah: false
                ),
                specialZmanim: [
                    SpecialZman(
                        name: "Candle Lighting",
                        hebrewName: "הדלקת נרות",
                        time: Date().addingTimeInterval(3600),
                        context: "Last time to light Shabbat candles"
                    ),
                    SpecialZman(
                        name: "Havdala",
                        hebrewName: "הבדלה",
                        time: Date().addingTimeInterval(7200),
                        context: "Earliest time to recite Havdala"
                    )
                ],
                showHebrewDates: true
            )
            
            Spacer()
        }
        .padding(16)
    }
}
