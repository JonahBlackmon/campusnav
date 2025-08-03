//
//  CampusNavApp.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/12/25.
//

import SwiftUI
import Turf
import CoreLocation
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct CampusNavApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var navCoord: NavigationCoordinator = NavigationCoordinator()
    @StateObject var settingsManager: SettingsManager = SettingsManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(settingsManager.darkMode ? .dark : .light)
                .environmentObject(settingsManager)
                .environmentObject(navCoord.buildingVM)
                .environmentObject(navCoord.headerVM)
                .environmentObject(navCoord.navState)
                .environmentObject(navCoord.navigationVM)
                .environmentObject(navCoord.firebaseManager)
                .environmentObject(navCoord.eventVM)
                .environmentObject(navCoord)
                .onAppear {
                    navCoord.buildingVM.loadBuildings(pathName: "buildings_simple")
                    Task {
                        await navCoord.eventVM.loadCurrentEvents(firebaseManager: navCoord.firebaseManager, buildingVM: navCoord.buildingVM)
                    }
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(BuildingViewModel())
        .environmentObject(HeaderViewModel())
        .environmentObject(NavigationUIState())
        .environmentObject(NavigationViewModel(currentCoordinates: [], currentNodes: []))
        .environmentObject(SettingsManager())
        .environmentObject(FirebaseManager())
        .environmentObject(EventViewModel())
        .environmentObject(NavigationCoordinator())
}
