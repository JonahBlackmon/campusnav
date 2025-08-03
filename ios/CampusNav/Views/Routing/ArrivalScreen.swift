//
//  ArrivalScreen.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/26/25.
//
import SwiftUI

struct ArrivalScreen: View {
    @State private var isVisible: Bool = false
    @EnvironmentObject var navState: NavigationUIState
    @EnvironmentObject var buildingVM: BuildingViewModel
    @EnvironmentObject var settingsManager: SettingsManager
    var body: some View {
        ZStack {
            settingsManager.primaryColor
            ArrivalScreenBanner()
                .environmentObject(buildingVM)
                .environmentObject(settingsManager)
        }
        .frame(maxWidth: 325, maxHeight: 75)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.3), radius: 5)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .offset(y: isVisible ? 0 : -150)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                isVisible = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                dismissView()
            }
        }
    }
    
    private func dismissView() {
        withAnimation(.easeInOut(duration: 0.5)) {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            navState.showArrival = false
        }
    }
}

struct ArrivalScreenBanner: View {
    @EnvironmentObject var buildingVM: BuildingViewModel
    @EnvironmentObject var settingsManager: SettingsManager
    var body: some View {
        HStack(spacing: 5) {
            BuildingImageView()
                .environmentObject(buildingVM)
                .shadow(color: settingsManager.textColor.opacity(0.3), radius: 20)
                .frame(width: 30, height: 30)
                .cornerRadius(4)
            VStack(alignment: .center) {
                HStack {
                    Text("You have arrived at \(buildingVM.name())!")
                        .font(.system(size: 18, weight: .bold))
                }
                .zIndex(1)
            }
            .foregroundStyle(settingsManager.accentColor)
        }
    }
}
