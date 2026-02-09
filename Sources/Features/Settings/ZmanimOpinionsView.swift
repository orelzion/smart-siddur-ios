import SwiftUI

/// Grouped pickers for all zmanim halachic opinions.
/// Each picker shows the current selection and available options.
struct ZmanimOpinionsView: View {
    let viewModel: SettingsViewModel

    var body: some View {
        List {
            Section {
                Picker("Dawn (Alot HaShachar)", selection: Binding(
                    get: { viewModel.syncedSettings.dawnOpinion },
                    set: { viewModel.updateDawnOpinion($0) }
                )) {
                    ForEach(DawnOpinion.allCases, id: \.self) { opinion in
                        Text(opinion.displayName).tag(opinion)
                    }
                }
                .pickerStyle(.navigationLink)
            } header: {
                Text("Dawn")
            } footer: {
                Text("Determines the earliest time for morning prayers.")
            }

            Section {
                Picker("Sunrise", selection: Binding(
                    get: { viewModel.syncedSettings.sunriseOpinion },
                    set: { viewModel.updateSunriseOpinion($0) }
                )) {
                    ForEach(SunriseOpinion.allCases, id: \.self) { opinion in
                        Text(opinion.displayName).tag(opinion)
                    }
                }
                .pickerStyle(.navigationLink)
            } header: {
                Text("Sunrise")
            } footer: {
                Text("Visible sunrise accounts for elevation; sea level does not.")
            }

            Section {
                Picker("General Opinion", selection: Binding(
                    get: { viewModel.syncedSettings.zmanOpinion },
                    set: { viewModel.updateZmanOpinion($0) }
                )) {
                    ForEach(ZmanOpinion.allCases, id: \.self) { opinion in
                        Text(opinion.displayName).tag(opinion)
                    }
                }
                .pickerStyle(.navigationLink)
            } header: {
                Text("Zman Calculation")
            } footer: {
                Text("MGA calculates from dawn to nightfall; GRA from sunrise to sunset.")
            }

            Section {
                Picker("Dusk (Tzeit HaKochavim)", selection: Binding(
                    get: { viewModel.syncedSettings.duskOpinion },
                    set: { viewModel.updateDuskOpinion($0) }
                )) {
                    ForEach(DuskOpinion.allCases, id: \.self) { opinion in
                        Text(opinion.displayName).tag(opinion)
                    }
                }
                .pickerStyle(.navigationLink)
            } header: {
                Text("Dusk")
            } footer: {
                Text("Determines nightfall for end of Shabbat and fast days.")
            }
        }
        .navigationTitle("Zmanim Opinions")
        .navigationBarTitleDisplayMode(.inline)
    }
}
