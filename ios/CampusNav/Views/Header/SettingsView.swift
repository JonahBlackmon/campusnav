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


struct SettingsView2: View {
    @EnvironmentObject var settingsManager: SettingsManager
    var body: some View {
        ZStack {
            settingsManager.primaryColor
                .ignoresSafeArea()
            VStack(alignment: .leading) {
                Text("Settings")
                    .font(.system(size: 30))
                    .foregroundStyle(settingsManager.textColor)
                    .fontWeight(.bold)
                    .padding()
                SettingsItem(toggleValue: $settingsManager.darkMode, action: settingsManager.toggleDarkMode, icon: settingsManager.darkMode ? "moon.fill" : "cloud.sun.fill", text: "Dark Mode")
                Spacer()
            }
        }
    }
}

struct SettingsItem: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var toggleValue: Bool
    var action: () -> Void
    var icon: String
    var text: String
    var body: some View {
        VStack {
            HStack {
                Toggle(isOn: $toggleValue) {
                    HStack {
                        Image(systemName: icon)
                            .foregroundStyle(settingsManager.accentColor)
                        Text(text)
                            .foregroundStyle(settingsManager.textColor)
                    }
                }
                .tint(settingsManager.accentColor)
            }
            Divider()
                .overlay(settingsManager.textColor)
        }
        .padding()
        .onChange(of: toggleValue) {
            action()
        }
    }
}
