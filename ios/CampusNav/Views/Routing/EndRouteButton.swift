//
//  EndRouteButton.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/27/25.
//
import SwiftUI

struct EndRouteButton: View {
    @EnvironmentObject var settingsManager: SettingsManager
    var resetData: () -> Void
    var body: some View {
        VStack {
            Button {
                resetData()
            } label: {
                VStack {
                    Text("End Route")
                        .padding()
                        .font(.system(size: 25))
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(settingsManager.accentColor)
                .background(settingsManager.primaryColor)
                .cornerRadius(12)
                .padding(.top, 0)
            }
        }
        .padding([.leading, .trailing, .bottom], 16)
        .padding(.bottom, 10)
        .transition(.move(edge: .bottom))
        .shadow(color: settingsManager.textColor.opacity(0.3), radius: 3)
    }
}
