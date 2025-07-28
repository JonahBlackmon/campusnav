import SwiftUI

let animationDuration: Double = 1.0

struct HeaderView: View {
    @State var animateFavorites: Bool = false    
    var collegePrimary: Color
    var collegeSecondary: Color
    @EnvironmentObject var headerVM: HeaderViewModel
    @EnvironmentObject var navState: NavigationUIState
    @EnvironmentObject var buildingVM: BuildingViewModel
    @EnvironmentObject var settingsManager: SettingsManager
    var body: some View {
        ZStack {
            if navState.isSearching {
                SearchView(collegePrimary: collegePrimary, collegeSecondary: collegeSecondary)
                    .environmentObject(headerVM)
                    .environmentObject(navState)
                    .environmentObject(buildingVM)
            }
            if headerVM.showFavorites {
                FavoritesView(collegePrimary: collegePrimary, collegeSecondary: collegeSecondary)
                    .environmentObject(navState)
                    .environmentObject(buildingVM)
                    .environmentObject(settingsManager)
                    .environmentObject(headerVM)
            }
            if headerVM.showSettings {
                SettingsView(collegePrimary: collegePrimary, collegeSecondary: collegeSecondary)
                    .environmentObject(navState)
                    .environmentObject(buildingVM)
                    .environmentObject(settingsManager)
                    .environmentObject(headerVM)
            }
            ZStack {
                SearchButton(collegePrimary: collegePrimary, collegeSecondary: collegeSecondary)
                    .environmentObject(headerVM)
                    .environmentObject(navState)
                    .offset(y: navState.isNavigating ? -200 : 0)
                HStack {
                    SettingsButton(collegePrimary: collegePrimary, collegeSecondary: collegeSecondary)
                        .environmentObject(headerVM)
                        .environmentObject(navState)
                        .offset(x: navState.isSearching || navState.isNavigating ? -200 : 0)
                    Spacer()
                    FavoritesIconButton(collegePrimary: collegePrimary, collegeSecondary: collegeSecondary)
                        .environmentObject(headerVM)
                        .environmentObject(navState)
                        .offset(x: navState.isSearching || navState.isNavigating ? 200 : 0)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding()
            .shadow(color: .black.opacity(0.5), radius: 5)
        }
    }
}

