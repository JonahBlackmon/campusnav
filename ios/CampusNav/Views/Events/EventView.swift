//
//  EventView.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/29/25.
//
import SwiftUI

struct EventView: View {
    @EnvironmentObject var buildingVM: BuildingViewModel
    @EnvironmentObject var eventVM: EventViewModel
    @EnvironmentObject var navState: NavigationUIState
    @EnvironmentObject var firebaseManager: FirebaseManager
    @EnvironmentObject var settingsManager: SettingsManager
    var body: some View {
        ZStack {
            settingsManager.primaryColor
                .ignoresSafeArea()
            VStack {
                HeaderText(text: "Events")
                    .environmentObject(settingsManager)
                EventsList()
                    .environmentObject(buildingVM)
                    .environmentObject(eventVM)
                    .environmentObject(navState)
                    .environmentObject(settingsManager)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            if eventVM.showMyEvents {
                MyEventsView()
                    .environmentObject(buildingVM)
                    .environmentObject(eventVM)
                    .environmentObject(navState)
                    .environmentObject(firebaseManager)
                    .environmentObject(settingsManager)
            }
            HStack {
                GenericIcon(animate: $eventVM.animateMyEvents, navStateVar: $navState.events, closedIcon: "bookmark", openIcon: "bookmark.fill", offset: -200, size: 20, onSelect: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        eventVM.animateMyEvents.toggle()
                        eventVM.showMyEvents.toggle()
                        eventVM.animateEvent = false
                        eventVM.showCreateEvent = false
                    }
                })
                .environmentObject(settingsManager)
                Spacer()
                GenericIcon(animate: $eventVM.animateEvent, navStateVar: $navState.events, closedIcon: "plus", openIcon: "plus", offset: 200, size: 20, onSelect: {
                    withAnimation(.none) {
                        eventVM.animateEvent.toggle()
                    }
                    withAnimation(.easeInOut(duration: 0.3)) {
                        eventVM.showCreateEvent.toggle()
                        eventVM.animateMyEvents = false
                        eventVM.showMyEvents = false
                    }
                })
                .environmentObject(settingsManager)
                    
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .sheet(isPresented: $eventVM.showCreateEvent) {
            CreateEventView()
                .environmentObject(eventVM)
                .environmentObject(buildingVM)
                .environmentObject(settingsManager)
        }
    }
}

struct HeaderText: View {
    @EnvironmentObject var settingsManager: SettingsManager
    var text: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
                .font(.system(size: 30))
                .foregroundStyle(settingsManager.textColor)
                .fontWeight(.bold)
            Divider()
                .overlay(settingsManager.textColor)
        }
        .padding()
        .padding(.top, 75)
    }
}

//#Preview {
//    CreateEventView(collegePrimary: .burntOrange, collegeSecondary: .offWhite)
//        .environmentObject(EventViewModel())
//        .environmentObject(NavigationUIState())
//}
