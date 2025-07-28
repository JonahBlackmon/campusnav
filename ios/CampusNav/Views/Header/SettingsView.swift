//
//  SettingsView.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/27/25.
//
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var headerVM: HeaderViewModel
    @EnvironmentObject var navState: NavigationUIState
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var buildingVM: BuildingViewModel
    var collegePrimary: Color
    var collegeSecondary: Color
    @FocusState.Binding var searchFocused: Bool
    var body: some View {
        Color.black.opacity(0.8)
            .ignoresSafeArea()
            .transition(.opacity)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    headerVM.showSettings = false
                    headerVM.animateSettings = false
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

struct SettingsButton: View {
    @EnvironmentObject var headerVM: HeaderViewModel
    @EnvironmentObject var navState: NavigationUIState
    let collegePrimary: Color
    let collegeSecondary: Color
    @FocusState.Binding var searchFocused: Bool
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                navState.isSearching = false
                headerVM.animateFavorites = false
                headerVM.showFavorites = false
                searchFocused = false
                headerVM.animateSettings.toggle()
                headerVM.showSettings.toggle()
            }
        } label: {
            ZStack {
                collegePrimary
                Image(systemName: headerVM.animateSettings ? "gearshape.fill" : "gearshape")
                    .foregroundStyle(collegeSecondary)
                    .font(.system(size: 22))
            }
            .frame(width: 50, height: 50)
            .cornerRadius(24)
            .keyframeAnimator(initialValue: FavoritesProperties(), trigger: headerVM.animateSettings) {
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
        .sensoryFeedback(.impact(flexibility: .rigid, intensity: 1.0), trigger: headerVM.animateSettings)
    }
}
