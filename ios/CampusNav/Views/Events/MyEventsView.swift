//
//  MyEventsView.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/30/25.
//
import SwiftUI

struct MyEventsView: View {
    @EnvironmentObject var buildingVM: BuildingViewModel
    @EnvironmentObject var eventVM: EventViewModel
    @EnvironmentObject var navState: NavigationUIState
    @EnvironmentObject var firebaseManager: FirebaseManager
    @EnvironmentObject var settingsManager: SettingsManager
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .transition(.opacity)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        eventVM.animateMyEvents = false
                        eventVM.showMyEvents = false
                        eventVM.animateEvent = false
                        eventVM.showCreateEvent = false
                    }
                }
            ZStack {
                settingsManager.primaryColor
                if !eventVM.eventBuildings.isEmpty {
                    ScrollView {
                        ForEach(Array(settingsManager.events.keys.enumerated()), id: \.element) { index, key in
                            MyEventItem(event: settingsManager.events[key] ?? nil, index: index)
                                .environmentObject(buildingVM)
                                .environmentObject(eventVM)
                                .environmentObject(navState)
                                .environmentObject(firebaseManager)
                                .environmentObject(settingsManager)
                        }
                    }
                } else {
                    Text("Try making some Events!")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .cornerRadius(12)
            .shadow(radius: 5)
            .padding(.top, 85)
            .padding(.bottom, 75)
            .padding(.leading, 10)
            .padding(.trailing, 10)
        }
    }
}
