//
//  NavigationCoordinator.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/27/25.
//

import SwiftUI

class NavigationCoordinator: ObservableObject {
    
    @Published var navigationVM: NavigationViewModel
    
    @Published var buildingVM: BuildingViewModel
    
    @Published var navState: NavigationUIState
    
    @Published var headerVM: HeaderViewModel
    
    @Published var settingsManager: SettingsManager
    
    @Published var firebaseManager: FirebaseManager
    
    init() {
        self.navigationVM = NavigationViewModel(currentCoordinates: [], currentNodes: [])
        self.buildingVM = BuildingViewModel()
        self.navState = NavigationUIState()
        self.headerVM = HeaderViewModel()
        self.settingsManager = SettingsManager()
        self.firebaseManager = FirebaseManager()
    }
    
    // Resets all accessed values to their default
    func resetData() {
        withAnimation(.easeOut(duration: 0.3)) {
            navigationVM.currentCoordinates = []
            navigationVM.directions = []
            navState.isNavigating = false
            buildingVM.selectedBuilding = nil
            navigationVM.distance = -1.0
        }
    }
    
    // Triggers update for navigation cards when viewing
    func updateCard() {
        if navigationVM.currentLocation?.longitude != nil && navigationVM.currentLocation?.latitude != nil {
            let (_, _, newDistance) = find_route(lat: navigationVM.currentLocation!.latitude, lng: navigationVM.currentLocation!.longitude, dest_abbr: buildingVM.abbr())
            navigationVM.distance = newDistance
            navState.showNavigationCard = true
        }
    }
    
    // Triggers the navigation logic, activating routing in the process
    func navigationLogic() {
        if navigationVM.currentLocation?.longitude != nil && navigationVM.currentLocation?.latitude != nil {
            (navigationVM.currentCoordinates, navigationVM.currentNodes, navigationVM.distance) = find_route(lat: navigationVM.currentLocation!.latitude, lng: navigationVM.currentLocation!.longitude, dest_abbr: buildingVM.abbr())
        }
    }
    
    // Check the proximity of current location to the destination node, re routing if necessary
    func proximityCheck() {
        if navigationVM.currentLocation?.longitude != nil && navigationVM.currentLocation?.latitude != nil {
            if navigationVM.currentCoordinates.count > 1 {
                let start = Coordinate(latitude: navigationVM.currentCoordinates[0].latitude, longitude: navigationVM.currentCoordinates[0].longitude)
                let end = Coordinate(latitude: navigationVM.currentCoordinates[1].latitude, longitude: navigationVM.currentCoordinates[1].longitude)
                let cL = Coordinate(latitude: navigationVM.currentLocation!.latitude, longitude: navigationVM.currentLocation!.longitude)
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
}
