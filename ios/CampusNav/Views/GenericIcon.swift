//
//  GenericIcon.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/30/25.
//
import SwiftUI

struct GenericIcon: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var animate: Bool
    var closedIcon: String
    var openIcon: String
    let size: CGFloat
    let onSelect: () -> Void
    var body: some View {
            Button {
                onSelect()
            } label: {
                ZStack {
                    settingsManager.primaryColor
                    Image(systemName: animate ? openIcon : closedIcon)
                        .foregroundStyle(settingsManager.accentColor)
                        .font(.system(size: size))
                }
                .frame(width: 50, height: 50)
                .cornerRadius(24)
                .keyframeAnimator(initialValue: IconProperties(), trigger: animate) {
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
            .sensoryFeedback(.impact(flexibility: .rigid, intensity: 1.0), trigger: animate)
            .padding()
            .shadow(color: settingsManager.textColor.opacity(0.3), radius: 3)
    }
}

struct GenericIconFromImage: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var animate: Bool
    var closedIcon: String
    var openIcon: String
    let size: CGFloat
    let onSelect: () -> Void
    var body: some View {
            Button {
                onSelect()
            } label: {
                ZStack {
                    settingsManager.primaryColor
                    Image(animate ? openIcon : closedIcon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size, height: size)
                        .foregroundStyle(settingsManager.accentColor)
                }
                .frame(width: 50, height: 50)
                .cornerRadius(24)
                .keyframeAnimator(initialValue: IconProperties(), trigger: animate) {
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
            .sensoryFeedback(.impact(flexibility: .rigid, intensity: 1.0), trigger: animate)
            .padding()
            .shadow(color: settingsManager.textColor.opacity(0.3), radius: 3)
    }
}

struct IconProperties {
    var rotation: Double = 0.0
    var verticalStretch: Double = 1.0
}
