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
    @StateObject var navCoord: NavigationCoordinator = NavigationCoordinator()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navCoord.buildingVM)
                .environmentObject(navCoord.headerVM)
                .environmentObject(navCoord.navState)
                .environmentObject(navCoord.navigationVM)
                .environmentObject(navCoord.settingsManager)
                .environmentObject(navCoord)
                .onAppear {
                    navCoord.buildingVM.loadBuildings(pathName: "buildings_simple")
                }
        }
    }
}

