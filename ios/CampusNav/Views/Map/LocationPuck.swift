//
//  LocationPuck.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/28/25.
//
import SwiftUI

let puckAnimationDuration = 2.0

struct LocationPuck: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State var value: CGFloat = 6
    var gradientStart: Color { settingsManager.accentColor.opacity(0.7) }
    static let gradientEnd = Color.clear
    @EnvironmentObject var navigationVM: NavigationViewModel
    
    var body: some View {
        ZStack {
            Trapezoid()
                .fill(
                    LinearGradient(colors: [gradientStart, Self.gradientEnd], startPoint: .top, endPoint: .bottom)
                )
                .offset(y: 30)
                .rotationEffect(Angle(degrees: (navigationVM.currentDirection ?? 0) + 180.0))
                .frame(width: 55, height: 75)

            ZStack {
                Image("longhorn")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 15, height: 15)
            }
            .padding()
            .background(settingsManager.primaryColor)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(settingsManager.accentColor, lineWidth: value)
                    .animation(
                        .easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                        value: value
                    )
            )
        }
        .frame(width: 60, height: 80)
        .onAppear {
            value = 3
        }
        .onDisappear {
            value = 6
        }
    }
}
