//
//  ContentView.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/12/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @EnvironmentObject var buildingVM: BuildingViewModel
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var navigationVM: NavigationViewModel
    @EnvironmentObject var navState: NavigationUIState
    @EnvironmentObject var navCoord: NavigationCoordinator
    @EnvironmentObject var headerVM: HeaderViewModel
    
    let tabBar: [(String, String)] = [("record", "mic.fill"), ("home", "house.fill"), ("profile", "book.fill")]
    
    var collegePrimary: Color {
       return settingsManager.collegePrimary
    }
    var collegeSecondary: Color {
       return settingsManager.collegeSecondary
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            mainContentView
            navigationView
            arrivalView
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $navState.showNavigationCard) {
            cardView
        }
        .onChange(of: buildingVM.selectedBuilding) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if navState.showNavigationCard {
                    navCoord.updateCard()
                }
            }
        }
        .onChange(of: navState.isNavigating) {
            if navState.isNavigating {
                navCoord.navigationLogic()
                navigationVM.proximityTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
                    navCoord.proximityCheck()
                }
            } else {
                navigationVM.proximityTimer?.invalidate()
                navigationVM.proximityTimer = nil
            }
        }
    }
    
    private var cardView: some View {
        ZStack {
            collegePrimary.edgesIgnoringSafeArea(.all)
            NavigationCard()
                .environmentObject(navState)
                .environmentObject(navigationVM)
                .environmentObject(buildingVM)
                .presentationDetents([.fraction(0.6)])
        }
    }
    
    private var arrivalView: some View {
        ZStack {
            if navState.showArrival {
                ArrivalScreen()
                    .environmentObject(navState)
                    .environmentObject(buildingVM)
            }
        }
    }
    
    private var navigationView: some View {
        ZStack {
            if navState.isNavigating {
                RoutingTop()
                    .environmentObject(navigationVM)
                    .transition(.move(edge: .top))
                RoutingBottom(resetData: navCoord.resetData)
                    .environmentObject(navigationVM)
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.spring(duration: 0.3), value: navState.isNavigating)
    }
    
    private var contentArea: some View {
        currentViewContent
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private var currentViewContent: some View {
        switch navState.currentView {
        case "record", "explore":
            MapView()
                .environmentObject(buildingVM)
                .environmentObject(navigationVM)
                .environmentObject(navState)
                .ignoresSafeArea()
                .preferredColorScheme(.light)
        case "profile":
            Text("Hello World")
        default:
            MapView()
                .environmentObject(buildingVM)
                .environmentObject(navigationVM)
                .environmentObject(navState)
                .ignoresSafeArea()
                .preferredColorScheme(.light)
        }
    }
    
    private var mainContentView: some View {
        ZStack() {
            contentArea
            HeaderView(collegePrimary: collegePrimary, collegeSecondary: collegeSecondary)
                .environmentObject(headerVM)
                .environmentObject(navState)
                .environmentObject(buildingVM)
                .environmentObject(settingsManager)
            CustomTabBar(tabItems: tabBar, collegePrimary: settingsManager.collegePrimary, collegeSecondary: settingsManager.collegeSecondary)
                .environmentObject(navState)
        }
    }
    
}
