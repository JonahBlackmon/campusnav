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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navCoord.buildingVM)
                .environmentObject(navCoord.headerVM)
                .environmentObject(navCoord.navState)
                .environmentObject(navCoord.navigationVM)
                .environmentObject(navCoord.settingsManager)
                .environmentObject(navCoord.firebaseManager)
                .environmentObject(navCoord)
                .onAppear {
                    navCoord.buildingVM.loadBuildings(pathName: "buildings_simple")
                }
        }
    }
}

