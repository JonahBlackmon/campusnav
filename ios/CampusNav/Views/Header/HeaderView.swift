import SwiftUI

let animationDuration: Double = 1.0

struct HeaderView: View {
    @State var animateFavorites: Bool = false
    @FocusState var searchFocused: Bool
    @EnvironmentObject var headerVM: HeaderViewModel
    @EnvironmentObject var navState: NavigationUIState
    @EnvironmentObject var buildingVM: BuildingViewModel
    @EnvironmentObject var settingsManager: SettingsManager
    var body: some View {
        ZStack {
            if navState.isSearching {
                SearchView(searchFocused: $searchFocused)
                    .environmentObject(headerVM)
                    .environmentObject(navState)
                    .environmentObject(buildingVM)
                    .environmentObject(settingsManager)
            }
            if headerVM.showFavorites {
                FavoritesView()
                    .environmentObject(navState)
                    .environmentObject(buildingVM)
                    .environmentObject(settingsManager)
                    .environmentObject(headerVM)
            }
            ZStack {
                SearchButton(searchFocused: $searchFocused)
                    .environmentObject(headerVM)
                    .environmentObject(navState)
                    .environmentObject(settingsManager)
                    .offset(y: navState.isNavigating || navState.events || navState.settings ? -200 : 0)
                HStack {
                    GenericIconFromImage(animate: $headerVM.animateLocation, closedIcon: "LocationPin", openIcon: "LocationPin", size: 28, onSelect: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            navState.isSearching = false
                            headerVM.animateFavorites = false
                            headerVM.showFavorites = false
                            searchFocused = false
                            headerVM.animateLocation.toggle()
                            navState.centerLocation.toggle()
                        }
                    })
                    .offset(x: navState.isSearching || navState.isNavigating || navState.events || navState.settings ? -200 : 0)
                    .environmentObject(settingsManager)
                    Spacer()
                    GenericIcon(animate: $headerVM.animateFavorites, closedIcon: "star", openIcon: "star.fill", size: 20, onSelect: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            navState.isSearching = false
                            searchFocused = false
                            headerVM.animateFavorites.toggle()
                            headerVM.showFavorites.toggle()
                        }
                    })
                    .offset(x: navState.isSearching || navState.isNavigating || navState.events || navState.settings ? 200 : 0)
                    .environmentObject(settingsManager)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.leading)
            .padding(.trailing)
            .shadow(color: settingsManager.textColor.opacity(0.3), radius: 3)
        }
    }
}

