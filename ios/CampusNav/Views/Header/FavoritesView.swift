//
//  FavoritesView.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/27/25.
//
import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var buildingVM: BuildingViewModel
    @EnvironmentObject var navState: NavigationUIState
    @EnvironmentObject var headerVM: HeaderViewModel
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .transition(.opacity)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        headerVM.showFavorites = false
                        headerVM.animateFavorites = false
                    }
                }
            ZStack {
                settingsManager.primaryColor
                if !settingsManager.favorites.isEmpty {
                    ScrollView {
                        ForEach(Array(settingsManager.favorites.keys.enumerated()), id: \.element) { index, key in
                            FavoritesItem(key: key, index: index)
                                .environmentObject(settingsManager)
                                .environmentObject(buildingVM)
                                .environmentObject(navState)
                                .environmentObject(headerVM)
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
    @EnvironmentObject var headerVM: HeaderViewModel
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
            headerVM.showFavorites = false
            headerVM.animateFavorites = false
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
                        .overlay(settingsManager.textColor)
                }
                Spacer()
                FavoritesButton(building: settingsManager.favorites[key] ?? Building(abbr: key, name: "", photoURL: ""))
                    .environmentObject(settingsManager)
                    .font(.system(size: 18))
            }
            .foregroundStyle(settingsManager.textColor)
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
