//
//  TabBar.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/27/25.
//
import SwiftUI
import SDWebImageSwiftUI

struct CustomTabBar: View {
    
    // [(Tab Name, System Icon)]
    var tabItems: [(String, String)]
    
    var collegePrimary: Color
    
    var collegeSecondary: Color
    
    @EnvironmentObject var navState: NavigationUIState
    
    // Name: (toggle, animating)
    @State private var toggles: [String: (Bool, Bool)] = [:]
    
    var body: some View {
        VStack {
            HStack(spacing: 75) {
                ForEach(tabItems, id: \.0) { tab in
                    tabButton(for: tab)
                }
            }
            .padding(.vertical, 10)
        }
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .fill(.offWhite.opacity(0.3))
                .frame(maxWidth: .infinity)
                .frame(height: 2),
            alignment: .top
        )
        .background(collegePrimary)
        .animation(.easeInOut(duration: 0.1), value: navState.currentView)
        .frame(height: 30)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .offset(y: navState.isSearching || navState.isNavigating ? 200 : 0)
        .animation(.easeInOut(duration: 0.3), value: navState.isSearching)
    }
    
    @ViewBuilder
    private func tabButtonBackground(for tabName: String) -> some View {
        if navState.currentView == tabName {
            RoundedRectangle(cornerRadius: 20)
                .fill(collegeSecondary.opacity(0.3))
                .frame(width: 75, height: 40)
                .transition(.horizontalGrow)
        }
    }
    
    private func tabButton(for tab: (String, String)) -> some View {
        let (toggle, _) = toggles[tab.0, default: (false, false)]
        return (
            CustomButton(action: { handleTabTap(for: tab.0) }, content:
                        ZStack {
                            VStack {
                                tabButtonIcon(tabName: tab.0, iconName: tab.1, toggles: $toggles)
                                    .environmentObject(navState)
                                    .keyframeAnimator(initialValue: TabButtonProperties(), trigger: toggle) {
                                        content, value in
                                        content
                                            .scaleEffect(value.scale)
                                    } keyframes: { _ in
                                        KeyframeTrack(\.scale) {
                                            CubicKeyframe(0.5, duration: animationDuration * 0.15)
                                            CubicKeyframe(1, duration: animationDuration * 0.15)
                                        }
                                    }
                                tabButtonText(tab.0)
                                    .opacity(navState.currentView == tab.0 ? 1.0 : 0.6)
                            }
                        }
//                        .frame(maxWidth: .infinity)
                    )
            .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.5), trigger: navState.currentView)
        )
    }
    
    private func tabButtonText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10))
            .foregroundStyle(.offWhite)
    }

    
    struct tabButtonIcon: View {
        var tabName: String
        var iconName: String
        @Binding var toggles: [String: (Bool, Bool)]
        @EnvironmentObject var navState: NavigationUIState
        var name: String {
            if navState.currentView == tabName {
                return iconName + ".fill"
            }
            return iconName
        }
        var body: some View {
            ZStack {
                if toggles[tabName, default: (false, false)].1 {
                    AnimatedImage(name: "\(iconName).gif")
                        .resizable()
                        .scaledToFit()
                        .background(
                                Color.offWhite
                                    .padding(.top, 10)
                                    .padding(.bottom, 9)
                                    .padding(.leading, 7)
                                    .padding(.trailing, 7)
                            )
                        .scaleEffect(iconName == "map" ? 1.13 : 1.25)
                } else {
                    Image(name)
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(width: 40, height: 40)
        }
    }
    
    struct TabButtonProperties {
        var scale: Double = 1.0
    }
    
    private func handleTabTap(for tabName: String) {
        let oldName = navState.currentView
        navState.currentView = tabName
        if navState.currentView != oldName {
            toggles[tabName, default: (false, false)].0.toggle()
            toggles[tabName, default: (false, false)].1 = true
            DispatchQueue.main.asyncAfter(deadline: .now() + ((tabName == "Map") ? 2.75 : 3.0)) {
                toggles[tabName, default: (false, false)].1 = false
            }
        }
    }
    
}


struct CustomButton<Content: View>: View {
    let action: () -> Void
    let content: Content
    var body: some View {
        ZStack {
            content
        }
        .onTapGesture {
            action()
        }
    }
}
