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
            settingsManager.primaryColor
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
