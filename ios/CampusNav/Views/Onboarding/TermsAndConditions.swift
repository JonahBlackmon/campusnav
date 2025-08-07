//
//  TermsAndConditions.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 8/7/25.
//
import SwiftUI

struct TermsAndConditions: View {
    @Environment(\.openURL) var openURL
    @State private var markdownText: AttributedString = ""
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var tac: Bool
    var accentColor: Color
    var body: some View {
        VStack {
            Spacer()
            Text("Accept Terms and Conditions?")
                .font(.title2.bold())
                .foregroundStyle(settingsManager.textColor)
                .padding()
            Button {
                tac.toggle()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(tac ? Color.green : settingsManager.darkMode ? .charcoal : .offWhite)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                    Image(systemName: "checkmark")
                        .font(.system(size: 25))
                        .foregroundStyle(accentColor)
                }
                .keyframeAnimator(initialValue: SelectProperties(), trigger: tac) {
                    content, value in
                    content
                        .scaleEffect(value.scale)
                } keyframes: { _ in
                    KeyframeTrack(\.scale) {
                        CubicKeyframe(0.8, duration: animationDuration * 0.15)
                        CubicKeyframe(1.1, duration: animationDuration * 0.15)
                        CubicKeyframe(0.9, duration: animationDuration * 0.15)
                        CubicKeyframe(1, duration: animationDuration * 0.15)
                    }
                }
                .padding()
            }
            .padding(.horizontal)
            .offset(y: -5)
            Button {
                if let url = URL(string: "https://jonahblackmon.github.io/campusnav/terms-and-conditions.html") {
                    openURL(url)
                }
            } label: {
                Text("View Terms and Conditions")
                    .font(.footnote)
                    .foregroundStyle(settingsManager.darkMode ? Color.white.secondary : Color.black.secondary)
                    .padding()
            }
            Spacer()
            Spacer()
        }
    }
}

struct SelectProperties {
    var scale: Double = 1.0
}
