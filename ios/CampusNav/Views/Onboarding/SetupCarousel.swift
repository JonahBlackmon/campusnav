//
//  SetupCarousel.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 8/7/25.
//
import SwiftUI

struct SetupCarousel: View {
    let items: [Color] = [.red, .blue, .green]
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var currentIndex: Int = 0
    @Binding var tac: Bool
    let accentColorString: String
    var accentColor: Color {
        colorFromString(colorString: accentColorString)
    }
    @Binding var isOnboarded: Bool
    var id: String
    var body: some View {
        VStack {
            DarkModeSelect(accentColor: accentColor)
                .environmentObject(settingsManager)
            TermsAndConditions(tac: $tac, accentColor: accentColor)
                .environmentObject(settingsManager)
            GetStarted(accentColor: accentColor, tac: $tac, isOnboarded: $isOnboarded, id: id)
                .environmentObject(settingsManager)
        }
    }
}
