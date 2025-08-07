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
    @AppStorage("isOnboarded") var isOnboarded: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if isOnboarded {
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
                    .onChange(of: isOnboarded) {
                        settingsManager.initializeAfterOnboarding()
                    }
                    .onAppear {
                        if isOnboarded {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                settingsManager.initializeAfterOnboarding()
                            }
                        }
                    }
            } else {
                OnboardingView(isOnboarded: $isOnboarded)
                    .environmentObject(settingsManager)
            }
        }
    }
}
