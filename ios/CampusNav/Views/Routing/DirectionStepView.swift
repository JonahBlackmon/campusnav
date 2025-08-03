//
//  DirectionStepView.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/27/25.
//
import SwiftUI

struct DirectionStepView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    var directionIcon: String
    var directionDescription: String
    var distance: String
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: directionIcon)
                .font(.system(size: 60))
                .fontWeight(.bold)
                .foregroundStyle(settingsManager.accentColor)
            VStack(alignment: .leading) {
                Text(distance)
                    .fontWeight(.bold)
                Text(directionDescription)
            }
            .font(.system(size: 35))
        }
        .padding(.leading, 50)
        .foregroundStyle(settingsManager.textColor)
        .frame(maxWidth: .infinity, alignment: .leading)
        Divider()
            .overlay(settingsManager.textColor)
            .padding(.leading)
            .padding(.trailing)
    }
}
