//
//  HeaderText.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 8/3/25.
//
import SwiftUI

struct HeaderText: View {
    @EnvironmentObject var settingsManager: SettingsManager
    var text: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
                .font(.system(size: 30))
                .foregroundStyle(settingsManager.textColor)
                .fontWeight(.bold)
            Divider()
                .overlay(settingsManager.textColor)
        }
        .padding()
    }
}
