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
    @StateObject var navState = NavigationUIState()
    @State var refreshTrigger: UUID = UUID()
    @State var isRefreshing: Bool = false
    
    var collegePrimary: Color {
       return settingsManager.collegePrimary
    }
    var collegeSecondary: Color {
       return settingsManager.collegeSecondary
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            mainContentView
            ZStack {
                if navState.isNavigating {
                    TopSheetView()
                        .environmentObject(navigationVM)
                        .transition(.move(edge: .top))
                    BottomSheetView(resetData: resetData)
                        .environmentObject(navigationVM)
                        .transition(.move(edge: .bottom))
                }
            }
            .animation(.spring(duration: 0.3), value: navState.isNavigating)
            if navState.showArrival {
                ArrivalScreen()
                    .environmentObject(navState)
                    .environmentObject(buildingVM)
            }
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $navState.showNavigationCard) {
            ZStack {
                collegePrimary.edgesIgnoringSafeArea(.all)
                NavigationCard()
                    .environmentObject(navState)
                    .environmentObject(navigationVM)
                    .environmentObject(buildingVM)
                    .presentationDetents([.fraction(0.6)])
            }
        }
        .onChange(of: buildingVM.selectedBuilding) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if navState.showNavigationCard {
                    updateCard()
                }
            }
        }
        .onChange(of: navState.isNavigating) {
            if navState.isNavigating {
                navigationLogic()
            }
        }
        .onChange(of: navState.isNavigating) {
            if navState.isNavigating {
                navigationVM.proximityTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
                    proximityCheck()
                }
            } else {
                navigationVM.proximityTimer?.invalidate()
                navigationVM.proximityTimer = nil
            }
        }
    }
    
    func resetData() {
        withAnimation(.easeOut(duration: 0.3)) {
            navigationVM.currentCoordinates = []
            navigationVM.currentCoordinates = []
            navigationVM.directions = []
            navState.isNavigating = false
            buildingVM.selectedBuilding = nil
            navigationVM.distance = -1.0
        }
    }
    
    private func updateCard() {
        if navigationVM.currentLocation?.longitude != nil && navigationVM.currentLocation?.latitude != nil {
            let (_, _, newDistance) = find_route(lat: navigationVM.currentLocation!.latitude, lng: navigationVM.currentLocation!.longitude, dest_abbr: buildingVM.abbr())
            navigationVM.distance = newDistance
            navState.showNavigationCard = true
        }
    }
    
    private func navigationLogic() {
        if navigationVM.currentLocation?.longitude != nil && navigationVM.currentLocation?.latitude != nil {
            (navigationVM.currentCoordinates, navigationVM.currentNodes, navigationVM.distance) = find_route(lat: navigationVM.currentLocation!.latitude, lng: navigationVM.currentLocation!.longitude, dest_abbr: buildingVM.abbr())
        }
    }
    
    // Check the proximity of current location to the destination node, re routing if necessary
    private func proximityCheck() {
        if navigationVM.currentLocation?.longitude != nil && navigationVM.currentLocation?.latitude != nil {
            if navigationVM.currentCoordinates.count > 1 {
                let start = Coordinate(latitude: navigationVM.currentCoordinates[0].latitude, longitude: navigationVM.currentCoordinates[0].longitude)
                let end = Coordinate(latitude: navigationVM.currentCoordinates[1].latitude, longitude: navigationVM.currentCoordinates[1].longitude)
                let cL = Coordinate(latitude: navigationVM.currentLocation!.latitude, longitude: navigationVM.currentLocation!.longitude)
                print("Current distance from next coord \(end.distance(to: cL))")
                print("Current distance from path \(distance_to_path(pos: cL, start: start, end: end))")
                if end.distance(to: cL) < 5 {
                    if navigationVM.currentCoordinates[1] == navigationVM.currentCoordinates.last {
                        // We are at the final destination, stop routing
                        navState.showArrival = true
                        resetData()
                    }
                    // We are at the destination
                    (navigationVM.currentCoordinates, navigationVM.currentNodes, navigationVM.distance) = find_route(lat: cL.latitude, lng: cL.longitude, dest_abbr: buildingVM.abbr())
                } else if distance_to_path(pos: cL, start: start, end: end) > 10 {
                    // Strayed to far from path, need to re route
                    (navigationVM.currentCoordinates, navigationVM.currentNodes, navigationVM.distance) = find_route(lat: cL.latitude, lng: cL.longitude, dest_abbr: buildingVM.abbr())
                }
            }
        }
    }
    
    private var customTabBar: some View {
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

    private var tabItems: [(String, String)] {
        [
            ("record", "mic.fill"),
            ("explore", "house.fill"),
            ("profile", "book.fill")
        ]
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

    @ViewBuilder
    private func tabButtonBackground(for tabName: String) -> some View {
        if navState.currentView == tabName {
            RoundedRectangle(cornerRadius: 20)
                .fill(collegeSecondary.opacity(0.3))
                .frame(width: 75, height: 40)
                .transition(.horizontalGrow)
        }
    }

    private func tabButtonIcon(_ iconName: String) -> some View {
        Image(systemName: iconName)
            .font(.system(size: 20))
            .foregroundColor(collegeSecondary)
    }
    
    private func handleTabTap(_ tabName: String) {
        if navState.currentView == tabName {
            withAnimation(.easeInOut(duration: 0.1)) {
                isRefreshing = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                refreshTrigger = UUID()
                withAnimation(.easeInOut(duration: 0.1)) {
                    isRefreshing = false
                }
            }
        } else {
            withAnimation(.easeInOut(duration: 0.1)) {
                navState.currentView = tabName
            }
        }
    }
    
    private var contentArea: some View {
        currentViewContent
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .id(refreshTrigger)
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
                .environmentObject(navState)
                .environmentObject(buildingVM)
                .environmentObject(settingsManager)
            customTabBar
        }
    }
    
}

struct HorizontalGrow: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(x: isActive ? 1 : 0.6, y: 1, anchor: .center)
            .opacity(isActive ? 1 : 0)
    }
}

extension AnyTransition {
    static var horizontalGrow: AnyTransition {
        .modifier(
            active: HorizontalGrow(isActive: false),
            identity: HorizontalGrow(isActive: true)
        )
    }
}
