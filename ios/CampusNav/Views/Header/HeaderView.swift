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
            if headerVM.showSettings {
                SettingsView(searchFocused: $searchFocused)
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
                    .offset(y: navState.isNavigating || navState.events ? -200 : 0)
                HStack {
                    GenericIcon(animate: $headerVM.animateSettings, navStateVar: Binding<Bool>(
                        get: {
                            !navState.isSearching && !navState.isNavigating && !navState.events
                        },
                        set: { _ in }
                    ), closedIcon: "gearshape", openIcon: "gearshape.fill", offset: -200, size: 22, onSelect: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            navState.isSearching = false
                            headerVM.animateFavorites = false
                            headerVM.showFavorites = false
                            searchFocused = false
                            headerVM.animateSettings.toggle()
                            headerVM.showSettings.toggle()
                        }
                    })
                    .environmentObject(settingsManager)
                    Spacer()
                    GenericIcon(animate: $headerVM.animateFavorites, navStateVar: Binding<Bool>(
                        get: {
                            !navState.isSearching && !navState.isNavigating && !navState.events
                        },
                        set: { _ in }
                    ), closedIcon: "star", openIcon: "star.fill", offset: 200, size: 20, onSelect: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            navState.isSearching = false
                            headerVM.showSettings = false
                            headerVM.animateSettings = false
                            searchFocused = false
                            headerVM.animateFavorites.toggle()
                            headerVM.showFavorites.toggle()
                        }
                    })
                    .environmentObject(settingsManager)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.leading)
            .padding(.trailing)
            .shadow(color: .black.opacity(0.5), radius: 5)
        }
    }
}

