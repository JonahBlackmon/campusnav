//
//  TabBar.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/27/25.
//
import SwiftUI

struct CustomTabBar: View {
    
    // [(Tab Name, System Icon)]
    var tabItems: [(String, String)]
    
    var collegePrimary: Color
    
    var collegeSecondary: Color
    
    @EnvironmentObject var navState: NavigationUIState
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                ForEach(tabItems, id: \.0) { tab in
                    tabButton(for: tab)
                }
            }
            .padding(.vertical, 10)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .fill(.offWhite.opacity(0.3))
                .frame(maxWidth: .infinity)
                .frame(height: 2),
            alignment: .top
        )
        .background(collegePrimary)
        .animation(.easeInOut(duration: 0.2), value: navState.currentView)
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
        Button(action: {
            handleTabTap(tab.0)
        }) {
            ZStack {
                tabButtonBackground(for: tab.0)
                tabButtonIcon(tab.1)
            }
            .frame(maxWidth: .infinity)
        }
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.5), trigger: navState.currentView)
    }

    private func tabButtonIcon(_ iconName: String) -> some View {
        Image(systemName: iconName)
            .font(.system(size: 20))
            .foregroundColor(collegeSecondary)
    }
    
    private func handleTabTap(_ tabName: String) {
        navState.currentView = tabName
    }
    
}
