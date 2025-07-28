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
    var collegePrimary: Color
    var collegeSecondary: Color
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
                collegePrimary
                if !settingsManager.favorites.isEmpty {
                    ScrollView {
                        ForEach(Array(settingsManager.favorites.keys.enumerated()), id: \.element) { index, key in
                            FavoritesItem(key: key, index: index, collegePrimary: collegePrimary, collegeSecondary: collegeSecondary)
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
    let collegePrimary: Color
    let collegeSecondary: Color
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

struct FavoritesIconButton: View {
    @EnvironmentObject var headerVM: HeaderViewModel
    @EnvironmentObject var navState: NavigationUIState
    let collegePrimary: Color
    let collegeSecondary: Color
    @FocusState.Binding var searchFocused: Bool
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                navState.isSearching = false
                headerVM.showSettings = false
                headerVM.animateSettings = false
                searchFocused = false
                headerVM.animateFavorites.toggle()
                headerVM.showFavorites.toggle()
            }
        } label: {
            ZStack {
                collegePrimary
                Image(systemName: headerVM.animateFavorites ? "star.fill" : "star")
                    .foregroundStyle(collegeSecondary)
                    .font(.system(size: 20))
            }
            .frame(width: 50, height: 50)
            .cornerRadius(24)
            .keyframeAnimator(initialValue: FavoritesProperties(), trigger: headerVM.animateFavorites) {
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
        .sensoryFeedback(.impact(flexibility: .rigid, intensity: 1.0), trigger: headerVM.animateFavorites)
    }
}

struct FavoritesProperties {
    var rotation: Double = 0.0
    var verticalStretch: Double = 1.0
}
