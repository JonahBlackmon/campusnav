import SwiftUI

struct HeaderView: View {
    @State var searching: Bool = false
    @State var animateFavorites: Bool = false
//    @Binding var searchingView: Bool
//    @Binding var routing: Bool
    let animationDuration: Double = 1.0
    var collegePrimary: Color
    var collegeSecondary: Color
    @State var searchText: String = ""
    @FocusState private var isSearchFieldFocused: Bool
    @State var settingsView: Bool = false
    @State var showMenu: Bool = false
    @State var animateSettings: Bool = false
    @EnvironmentObject var navState: NavigationUIState
    @EnvironmentObject var buildingVM: BuildingViewModel
    @EnvironmentObject var settingsManager: SettingsManager
    var body: some View {
        ZStack {
            if searching {
                SearchView(collegePrimary: collegePrimary, isSearchFieldFocused: _isSearchFieldFocused, exitHeader: ExitHeader, searchText: $searchText)
                    .environmentObject(navState)
                    .environmentObject(buildingVM)
            }
            if showMenu {
                FavoritesView(menuView: $showMenu, animateFavorites: $animateFavorites, collegePrimary: collegePrimary)
                    .environmentObject(navState)
                    .environmentObject(buildingVM)
                    .environmentObject(settingsManager)
            }
            if settingsView {
                SettingsView(settingsView: $settingsView, animateSettings: $animateSettings, collegePrimary: collegePrimary)
                    .environmentObject(navState)
                    .environmentObject(buildingVM)
                    .environmentObject(settingsManager)
            }
            ZStack {
                SearchButton
                    .offset(y: navState.isNavigating ? -200 : 0)
                HStack {
                    SettingsButton
                        .offset(x: searching || navState.isNavigating ? -200 : 0)
                    Spacer()
                    favoritesButton
                        .offset(x: searching || navState.isNavigating ? 200 : 0)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding()
            .shadow(color: .black.opacity(0.5), radius: 5)
        }
    }
    
    private var favoritesButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                searching = false
                navState.isSearching = false
                settingsView = false
                animateSettings = false
                isSearchFieldFocused = false
                animateFavorites.toggle()
                showMenu.toggle()
            }
        } label: {
            ZStack {
                collegePrimary
                Image(systemName: animateFavorites ? "star.fill" : "star")
                    .foregroundStyle(collegeSecondary)
                    .font(.system(size: 20))
            }
            .frame(width: 50, height: 50)
            .cornerRadius(24)
            .keyframeAnimator(initialValue: FavoritesProperties(), trigger: animateFavorites) {
                content, value in
                content
                    .scaleEffect(value.verticalStretch)
                    .rotationEffect(Angle(degrees: value.rotation))
            } keyframes: { _ in
                KeyframeTrack(\.verticalStretch) {
                    SpringKeyframe(1.15, duration: animationDuration * 0.25)
                    CubicKeyframe(1, duration: animationDuration * 0.25)
                }
                KeyframeTrack(\.rotation) {
                    CubicKeyframe(30, duration: animationDuration * 0.15)
                    CubicKeyframe(-30, duration: animationDuration * 0.15)
                    CubicKeyframe(0, duration: animationDuration * 0.15)
                }
            }
        }
        .sensoryFeedback(.impact(flexibility: .rigid, intensity: 1.0), trigger: animateFavorites)
    }

    struct FavoritesProperties {
        var rotation: Double = 0.0
        var verticalStretch: Double = 1.0
    }
    
    private var SettingsButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                searching = false
                navState.isSearching = false
                animateFavorites = false
                showMenu = false
                isSearchFieldFocused = false
                animateSettings.toggle()
                settingsView.toggle()
            }
        } label: {
            ZStack {
                collegePrimary
                Image(systemName: animateSettings ? "gearshape.fill" : "gearshape")
                    .foregroundStyle(collegeSecondary)
                    .font(.system(size: 22))
            }
            .frame(width: 50, height: 50)
            .cornerRadius(24)
            .keyframeAnimator(initialValue: FavoritesProperties(), trigger: animateSettings) {
                content, value in
                content
                    .scaleEffect(value.verticalStretch)
                    .rotationEffect(Angle(degrees: value.rotation))
            } keyframes: { _ in
                KeyframeTrack(\.verticalStretch) {
                    SpringKeyframe(1.15, duration: animationDuration * 0.25)
                    CubicKeyframe(1, duration: animationDuration * 0.25)
                }
                KeyframeTrack(\.rotation) {
                    CubicKeyframe(30, duration: animationDuration * 0.15)
                    CubicKeyframe(-30, duration: animationDuration * 0.15)
                    CubicKeyframe(0, duration: animationDuration * 0.15)
                }
            }
        }
        .sensoryFeedback(.impact(flexibility: .rigid, intensity: 1.0), trigger: animateSettings)
    }
    
    func ExitHeader() {
        withAnimation(.easeInOut(duration: 0.3)) {
            searching = false
            navState.isSearching = false
            settingsView = false
            animateSettings = false
            animateFavorites = false
            showMenu = false
            isSearchFieldFocused = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            searchText = ""
        }
    }
    
    private var BackButton: some View {
        Button {
            ExitHeader()
        } label: {
            Image(systemName: "chevron.backward")
                .foregroundStyle(.black.opacity(0.3))
        }
    }
    
    private var SearchButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.4)) {
                settingsView = false
                animateSettings = false
                animateFavorites = false
                showMenu = false
                searching = true
                navState.isSearching = true
                isSearchFieldFocused = true
            }
        } label: {
            HStack(spacing: 20) {
                if searching {
                    BackButton
                        .padding(.leading)
                        .transition(
                                .asymmetric(
                                    insertion: .offset(x: -UIScreen.main.bounds.width / 2.5),
                                    removal: .offset(x: -UIScreen.main.bounds.width / 2.5)
                                )
                            )
                }
                ZStack {
                    collegePrimary
                    SearchButtonLabel
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, alignment: searching ? .leading : .center)
                        .animation(.easeInOut(duration: 0.4), value: searching)
                }
                .frame(height: 50)
                .frame(maxWidth: searching ? .infinity : 175)
                .cornerRadius(24)
                .animation(.spring(duration: 0.4), value: searching)
                .foregroundColor(collegeSecondary)
            }
        }
    }

    private var SearchButtonLabel: some View {
        HStack(spacing: 8) {
            if !searching {
                Text("Search")
                    .transition(
                        .opacity.combined(with:
                            .asymmetric(
                                insertion: .offset(x: -UIScreen.main.bounds.width / 2.5).combined(with: .opacity),
                                removal: .offset(x: -UIScreen.main.bounds.width / 2.5).combined(with: .opacity)
                            )
                        )
                    )
            }
            Image(systemName: "magnifyingglass")
            if searching {
                TextField(
                    "",
                    text: $searchText,
                    prompt: Text("E.g. PCL...")
                        .foregroundColor(.offWhite.opacity(0.8))
                        .italic()
                )
                .multilineTextAlignment(.leading)
                .focused($isSearchFieldFocused)
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
    }
    
    struct SettingsView: View {
        @EnvironmentObject var settingsManager: SettingsManager
        @Binding var settingsView: Bool
        @Binding var animateSettings: Bool
        var collegePrimary: Color
        var body: some View {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .transition(.opacity)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        settingsView = false
                        animateSettings = false
                    }
                }
            ZStack {
                collegePrimary
                ScrollView {
                    Text("Settings View")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .cornerRadius(12)
            .shadow(radius: 5)
            .padding(.top, 85)
            .padding(.bottom, 75)
            .padding(.leading, 10)
            .padding(.trailing, 10)
        }
    }
    
    struct FavoritesView: View {
        @EnvironmentObject var settingsManager: SettingsManager
        @EnvironmentObject var buildingVM: BuildingViewModel
        @EnvironmentObject var navState: NavigationUIState
        @Binding var menuView: Bool
        @Binding var animateFavorites: Bool
        var collegePrimary: Color
        var body: some View {
            ZStack {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            menuView = false
                            animateFavorites = false
                        }
                    }
                ZStack {
                    collegePrimary
                    if !settingsManager.favorites.isEmpty {
                        ScrollView {
                            ForEach(Array(settingsManager.favorites.keys.enumerated()), id: \.element) { index, key in
                                FavoritesItem(key: key, index: index, menuView: $menuView, animateFavorites: $animateFavorites)
                                    .environmentObject(settingsManager)
                                    .environmentObject(buildingVM)
                                    .environmentObject(navState)
                            }
                        }
                    } else {
                        Text("Try favoriting some locations!")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding(.top, 85)
                .padding(.bottom, 75)
                .padding(.leading, 10)
                .padding(.trailing, 10)
                
            }
            
        }
    }
    
    struct FavoritesItem: View {
        let key: String
        let index: Int
        @State var show: Bool = false
        @Binding var menuView: Bool
        @Binding var animateFavorites: Bool
        @EnvironmentObject var navState: NavigationUIState
        @EnvironmentObject var settingsManager: SettingsManager
        @EnvironmentObject var buildingVM: BuildingViewModel
        var name: String {
            return settingsManager.favorites[key]?.name ?? key
        }
        var url: String {
            return settingsManager.favorites[key]?.photoURL ?? ""
        }
        var body: some View {
            Button {
                menuView = false
                animateFavorites = false
                navState.showNavigationCard = true
                buildingVM.selectedBuilding = settingsManager.favorites[key]
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(name)
                            .font(.system(size: 15))
                        Text(key)
                            .font(.system(size: 10))
                        Divider()
                            .overlay(.offWhite)
                    }
                    Spacer()
                    FavoritesButton(building: settingsManager.favorites[key] ?? Building(abbr: key, name: "", photoURL: ""))
                        .environmentObject(settingsManager)
                        .font(.system(size: 18))
                }
                .foregroundStyle(.offWhite)
            }
            .foregroundStyle(.black.opacity(0.8))
            .padding()
            .opacity(show ? 1 : 0)
            .offset(y: show ? 0 : 20)
            .animation(.bouncy.delay(Double(index) * 0.05), value: show)
            .onAppear {
                show = true
            }
        }
    }
    
    struct SearchView: View {
        let collegePrimary: Color
        @FocusState var isSearchFieldFocused: Bool
        var exitHeader: () -> Void
        @EnvironmentObject var navState: NavigationUIState
        @EnvironmentObject var buildingVM: BuildingViewModel
        @EnvironmentObject var settingsManager: SettingsManager
        @State var displayBuildings: [Building] = []
        @Binding var searchText: String
        var favorites: [Building] { Array(settingsManager.favorites.values) }
        var nonFavoritePopular: [Building] { buildingVM.popularBuildings.filter { !settingsManager.favorites.keys.contains($0.abbr) } }
        var defaultList: [Building] { favorites + nonFavoritePopular }
        var body: some View {
            ZStack() {
                Color.offWhite.opacity(1.0)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        isSearchFieldFocused = false
                    }
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(
                            Array(displayBuildings.enumerated()), id: \.element.id) { index, building in
                                SearchItem(selected: building, collegePrimary: collegePrimary, index: index, exitHeader: exitHeader)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.top, 100)
                .onAppear {
                    displayBuildings = defaultList
                }
                .onChange(of: searchText) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if !searchText.isEmpty {
                            displayBuildings = buildingVM.searchBuilding(matching: searchText)
                        } else {
                            displayBuildings = defaultList
                        }
                    }
                }
            }
        }
    }

    struct SearchItem: View {
        let selected: Building
        let collegePrimary: Color
        @State var show: Bool = false
        var index: Int
        var exitHeader: () -> Void
        @EnvironmentObject var navState: NavigationUIState
        @EnvironmentObject var buildingVM: BuildingViewModel
        var body: some View {
            HStack {
                Button {
                    exitHeader()
                    navState.showNavigationCard = true
                    buildingVM.selectedBuilding = selected
                } label: {
                    Image(systemName: "location.circle.fill")
                    .font(.system(size: 22))
                    .padding(.trailing, 5)
                    VStack(alignment: .leading) {
                        Text(selected.name)
                            .font(.system(size: 20))
                        Text(selected.abbr)
                            .font(.system(size: 10))
                            .foregroundStyle(collegePrimary)
                        Divider()
                    }
                }
                .foregroundStyle(.black.opacity(0.8))
                .padding()
                .opacity(show ? 1 : 0)
                .offset(y: show ? 0 : 20)
                .animation(.bouncy.delay(min(Double(index), 10) * 0.05), value: show)
                .onAppear {
                    show = true
                }
            }
            .padding()
        }
    }
}

