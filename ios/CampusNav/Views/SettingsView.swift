//
//  SettingsView.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/27/25.
//
import SwiftUI
import CoreLocation


struct SettingsView: View {
    @EnvironmentObject var navigationVM: NavigationViewModel
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
                SubHeading(text: "DISPLAY")
                    .environmentObject(settingsManager)
                SettingsItem(toggleValue: $settingsManager.darkMode, action: settingsManager.toggleDarkMode, icon: settingsManager.darkMode ? "moon.fill" : "cloud.sun.fill", text: "Dark Mode")
                SubHeading(text: "PERMISSIONS")
                    .environmentObject(settingsManager)
                EnableLocationButton()
                    .environmentObject(settingsManager)
                    .environmentObject(navigationVM)
                SubHeading(text: "RESOURCES")
                    .environmentObject(settingsManager)
                InformationView()
                    .environmentObject(settingsManager)
                Spacer()
            }
        }
    }
}

struct InformationView: View {
    @Environment(\.openURL) var openURL
    @EnvironmentObject var settingsManager: SettingsManager
    var body: some View {
        VStack(alignment: .leading) {
            InformationButton(text: "Contact Us", icon: "message") {
                let recipient = "campusnavcontact@gmail.com"
                if let url = URL(string: "mailto:\(recipient)") {
                    openURL(url)
                }
            }
            .padding(.bottom)
            .environmentObject(settingsManager)
            InformationButton(text: "Source Code", icon: "chevron.left.slash.chevron.right") {
                if let url = URL(string: "https://github.com/JonahBlackmon/campusnav") {
                    openURL(url)
                }
            }
            .padding(.bottom)
            .environmentObject(settingsManager)
            InformationButton(text: "Terms & Conditions", icon: "book") {
                if let url = URL(string: "https://jonahblackmon.github.io/campusnav/terms-and-conditions.html") {
                    openURL(url)
                }
            }
            .environmentObject(settingsManager)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(settingsManager.textColor.opacity(0.1))
        .cornerRadius(12)
        .padding()
    }
}

struct InformationButton: View {
    @EnvironmentObject var settingsManager: SettingsManager
    let text: String
    let icon: String
    let action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Image(systemName: icon)
                Text(text)
            }
            .foregroundStyle(settingsManager.accentColor)
        }
    }
}

struct SubHeading: View {
    @EnvironmentObject var settingsManager: SettingsManager
    var text: String
    var body: some View {
        Text(text)
            .font(.system(size: 14))
            .fontWeight(.bold)
            .foregroundStyle(settingsManager.textColor.opacity(0.6))
            .frame(alignment: .leading)
            .padding(.horizontal)
    }
}

struct EnableLocationButton: View {
    @EnvironmentObject var navigationVM: NavigationViewModel
    @EnvironmentObject var settingsManager: SettingsManager
    var body: some View {
        if navigationVM.locationManager?.authorizationStatus == .denied {
            Button {
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettings)
                }
            } label: {
                VStack(alignment: .leading) {
                    HStack {
                        Image("LocationPin")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundStyle(settingsManager.accentColor)
                        VStack(alignment: .leading) {
                            Text("Location Disabled")
                                .font(.system(size: 15))
                                .foregroundStyle(settingsManager.textColor)
                            Text("Tap to open settings to enable")
                                .font(.system(size: 12))
                                .foregroundStyle(settingsManager.textColor.opacity(0.8))
                        }
                    }
                    .tint(settingsManager.accentColor)
                    Divider()
                        .overlay(settingsManager.textColor)
                }
                .padding()
            }
        } else {
            VStack(alignment: .leading) {
                HStack {
                    Image("LocationPin")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundStyle(settingsManager.accentColor)
                    VStack(alignment: .leading) {
                        Text("Location Enabled")
                            .font(.system(size: 15))
                            .foregroundStyle(settingsManager.textColor)
                        Text("Used to display location and route")
                            .font(.system(size: 12))
                            .foregroundStyle(settingsManager.textColor.opacity(0.8))
                    }
                }
                .tint(settingsManager.accentColor)
                Divider()
                    .overlay(settingsManager.textColor)
            }
            .padding()
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
                            .font(.system(size: 18))
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


