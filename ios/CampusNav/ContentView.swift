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
    
    let tabBar: [(String, String)] = [("Map", "map"), ("Events", "events")]
    
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
        .onChange(of: navState.currentView) {
            let events: Bool = navState.currentView == "Events"
            withAnimation(.easeInOut(duration: 0.3)) {
                navState.events = events
            }
            if !events {
                eventVM.ExitEvent()
            } else {
                headerVM.ExitHeader(navState: navState)
            }
        }
    }
    
//    private var addEvent: some View {
//        VStack {
//            Button {
//                firebaseManager.publishEvent(abbr: "KIN", locationDescription: "", clubName: "", eventName: "", eventTimes: [Date.now], isRepeating: false, settingsManager: settingsManager)
//            } label: {
//                Text("Add Event")
//            }
//            myEvents
//        }
//        .background(Color.white)
//    }
    
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
        case "Map":
            MapView()
                .environmentObject(buildingVM)
                .environmentObject(navigationVM)
                .environmentObject(navState)
                .environmentObject(eventVM)
                .ignoresSafeArea()
                .preferredColorScheme(.light)
        case "Events":
            EventView(collegePrimary: collegePrimary, collegeSecondary: collegeSecondary)
                .environmentObject(buildingVM)
                .environmentObject(eventVM)
                .environmentObject(navState)
                .environmentObject(firebaseManager)
                .environmentObject(settingsManager)
        default:
            MapView()
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
