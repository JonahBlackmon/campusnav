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
    @EnvironmentObject var firebaseManager: FirebaseManager
    @EnvironmentObject var eventVM: EventViewModel
    
    let tabBar: [(String, String)] = [("Map", "map"), ("Events", "calendar"), ("Settings", "gearshape")]
    
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
                if navState.showNavigationCard && buildingVM.selectedBuilding?.abbr != "" {
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
        .onChange(of: navState.currentView) {
            let events: Bool = navState.currentView == "Events"
            let settings: Bool = navState.currentView == "Settings"
            withAnimation(.easeInOut(duration: 0.3)) {
                navState.events = events
                navState.settings = settings
            }
            if !events {
                eventVM.ExitEvent()
            } else {
                Task {
                    await eventVM.loadCurrentEvents(firebaseManager: firebaseManager, buildingVM: buildingVM)
                }
                headerVM.ExitHeader(navState: navState)
            }
        }
    }
    
    private var cardView: some View {
        ZStack {
            settingsManager.primaryColor.edgesIgnoringSafeArea(.all)
            NavigationCard()
                .environmentObject(settingsManager)
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
                    .environmentObject(settingsManager)
                    .environmentObject(navState)
                    .environmentObject(buildingVM)
            }
        }
    }
    
    private var navigationView: some View {
        ZStack {
            if navState.isNavigating {
                RoutingTop()
                    .environmentObject(settingsManager)
                    .environmentObject(navigationVM)
                    .transition(.move(edge: .top))
                RoutingBottom(resetData: navCoord.resetData)
                    .environmentObject(settingsManager)
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
        case "Map":
            MapView()
                .environmentObject(buildingVM)
                .environmentObject(navigationVM)
                .environmentObject(navState)
                .environmentObject(eventVM)
                .environmentObject(settingsManager)
                .ignoresSafeArea()
                .preferredColorScheme(.light)
        case "Events":
            EventView()
                .environmentObject(buildingVM)
                .environmentObject(eventVM)
                .environmentObject(navState)
                .environmentObject(firebaseManager)
                .environmentObject(settingsManager)
        case "Settings":
            SettingsView()
                .environmentObject(navigationVM)
                .environmentObject(settingsManager)
        default:
            MapView()
                .environmentObject(settingsManager)
                .environmentObject(buildingVM)
                .environmentObject(navigationVM)
                .environmentObject(navState)
                .environmentObject(eventVM)
                .ignoresSafeArea()
                .preferredColorScheme(.light)
        }
    }
    
    private var mainContentView: some View {
        ZStack() {
            contentArea
            HeaderView()
                .environmentObject(headerVM)
                .environmentObject(navState)
                .environmentObject(buildingVM)
                .environmentObject(settingsManager)
            CustomTabBar(tabItems: tabBar)
                .environmentObject(navState)
        }
    }
    
}
