//
//  DarkModeSelect.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 8/7/25.
//
import SwiftUI

struct DarkModeSelect: View {
    @EnvironmentObject var settingsManager: SettingsManager
    let accentColor: Color
    var body: some View {
        VStack {
            Spacer()
            Text("Select Dark Mode?")
                .font(.largeTitle.bold())
                .foregroundStyle(settingsManager.textColor)
                .padding(.bottom, 12)
            Text("Can be changed later in settings")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(settingsManager.darkMode ? Color.offWhite.secondary : Color.charcoal.secondary)
            HStack(spacing: 50) {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        settingsManager.darkMode = false
                        settingsManager.toggleDarkMode()
                    }
                } label: {
                    Image(systemName: "cloud.sun.fill")
                        .font(.system(size: 80))
                        .frame(width: 120, height: 120)
                        .background(.offWhite.opacity(settingsManager.darkMode ? 0 : 1))
                        .foregroundStyle(settingsManager.darkMode ? .offWhite : accentColor)
                        .cornerRadius(24)
                }
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        settingsManager.darkMode = true
                        settingsManager.toggleDarkMode()
                    }
                } label: {
                    Image(systemName: "moon.fill")
                        .font(.system(size: 80))
                        .frame(width: 120, height: 120)
                        .background(.charcoal.opacity(settingsManager.darkMode ? 1 : 0))
                        .cornerRadius(24)
                        .foregroundStyle(settingsManager.darkMode ? accentColor : .charcoal)
                }
            }
            .padding()
            Spacer()
            Spacer()
        }
    }
}
