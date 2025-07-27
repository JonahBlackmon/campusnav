//
//  CampusNavApp.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/12/25.
//

import SwiftUI
import Turf
import CoreLocation

@main
struct CampusNavApp: App {
    
    @StateObject var settingsManager: SettingsManager = SettingsManager()
    @StateObject var bulidingVM: BuildingViewModel = BuildingViewModel()
    @StateObject var navigationVM: NavigationViewModel = NavigationViewModel(currentCoordinates: [], currentNodes: [])
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bulidingVM)
                .environmentObject(settingsManager)
                .environmentObject(navigationVM)
                .onAppear {
                    bulidingVM.loadBuildings(pathName: "buildings_simple")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(BuildingViewModel())
        .environmentObject(SettingsManager())
        .environmentObject(NavigationViewModel(currentCoordinates: [], currentNodes: []))
}

