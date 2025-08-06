//
//  SearchView.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/27/25.
//
import SwiftUI

struct SearchView: View {
    @EnvironmentObject var navState: NavigationUIState
    @EnvironmentObject var buildingVM: BuildingViewModel
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var headerVM: HeaderViewModel
    @FocusState.Binding var searchFocused: Bool
    @State var displayBuildings: [Building] = []
    var favorites: [Building] { Array(settingsManager.favorites.values) }
    var nonFavoritePopular: [Building] { buildingVM.popularBuildings.filter { !settingsManager.favorites.keys.contains($0.abbr) } }
    var defaultList: [Building] { favorites + nonFavoritePopular }
    
    var body: some View {
        ZStack() {
            settingsManager.primaryColor.opacity(1.0)
                .ignoresSafeArea()
                .transition(.opacity)
                .onTapGesture {
                   searchFocused = false
                }
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(
                        Array(displayBuildings.enumerated()), id: \.element.id) { index, building in
                            SearchItem(
                                    building: building,
                                    index: index,
                                    onSelect: {
                                        searchFocused = headerVM.ExitHeader(navState: navState)
                                        navState.showNavigationCard = true
                                        buildingVM.selectedBuilding = building
                                    }
                                )
                            .environmentObject(settingsManager)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(.top, 100)
            .onAppear {
                displayBuildings = defaultList
            }
            .onChange(of: headerVM.searchText) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if !headerVM.searchText.isEmpty {
                        displayBuildings = buildingVM.searchBuilding(matching: headerVM.searchText)
                    } else {
                        displayBuildings = defaultList
                    }
                }
            }
        }
    }
}

struct SearchItem: View {
    @EnvironmentObject var settingsManager: SettingsManager
    let building: Building
    let index: Int
    let onSelect: () -> Void
    @State var show: Bool = false
    
    var body: some View {
        HStack {
            Button {
                onSelect()
            } label: {
                Image(systemName: "location.circle.fill")
                .font(.system(size: 22))
                .padding(.trailing, 5)
                .foregroundStyle(settingsManager.textColor)
                VStack(alignment: .leading) {
                    Text(building.name)
                        .font(.system(size: 20))
                        .foregroundStyle(settingsManager.textColor)
                    Text(building.abbr)
                        .font(.system(size: 10))
                        .foregroundStyle(settingsManager.accentColor)
                    Divider()
                        .overlay(settingsManager.textColor)
                }
            }
            .foregroundStyle(settingsManager.textColor.opacity(0.8))
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


struct SearchButton: View {
    @EnvironmentObject var headerVM: HeaderViewModel
    @EnvironmentObject var navState: NavigationUIState
    @EnvironmentObject var settingsManager: SettingsManager
    @FocusState.Binding var searchFocused: Bool
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.4)) {
                headerVM.animateFavorites = false
                headerVM.showFavorites = false
                navState.isSearching = true
                navState.isSearching = true
                searchFocused = true
            }
        } label: {
            HStack(spacing: 20) {
                if navState.isSearching {
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
                    settingsManager.primaryColor
                    SearchButtonLabel
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, alignment: navState.isSearching ? .leading : .center)
                        .animation(.easeInOut(duration: 0.4), value: navState.isSearching)
                }
                .frame(height: 50)
                .frame(maxWidth: navState.isSearching ? .infinity : 175)
                .cornerRadius(24)
                .animation(.spring(duration: 0.4), value: navState.isSearching)
                .foregroundColor(settingsManager.accentColor)
            }
        }
    }
    
    private var SearchButtonLabel: some View {
        HStack(spacing: 8) {
            if !navState.isSearching {
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
            if navState.isSearching {
                TextField(
                    "",
                    text: $headerVM.searchText,
                    prompt: Text("E.g. PCL...")
                        .foregroundColor(settingsManager.textColor.opacity(0.8))
                        .italic()
                )
                .multilineTextAlignment(.leading)
                .focused($searchFocused)
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
    }
    
    private var BackButton: some View {
        Button {
            searchFocused = headerVM.ExitHeader(navState: navState)
        } label: {
            Image(systemName: "chevron.backward")
                .foregroundStyle(settingsManager.textColor.opacity(0.3))
        }
    }
}
