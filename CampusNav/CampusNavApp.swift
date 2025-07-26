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
    @StateObject var buildingManager: BuildingManager = BuildingManager()
    @StateObject var directionManager: DirectionManager = DirectionManager(currentCoordinates: [], currentNodes: [])
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(buildingManager)
                .environmentObject(settingsManager)
                .environmentObject(directionManager)
                .onAppear {
                    buildingManager.loadBuildings(pathName: "buildings_simple")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(BuildingManager())
        .environmentObject(SettingsManager())
        .environmentObject(DirectionManager(currentCoordinates: [], currentNodes: []))
}

