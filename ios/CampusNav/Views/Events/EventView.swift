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
                HStack {
                    EventHeader(text: "Events", showFilters: $eventVM.showFilters)
                        .environmentObject(settingsManager)
                }
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
                GenericIcon(animate: $eventVM.animateMyEvents, closedIcon: "bookmark", openIcon: "bookmark.fill", size: 20, onSelect: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        eventVM.animateMyEvents.toggle()
                        eventVM.showMyEvents.toggle()
                        eventVM.animateEvent = false
                        eventVM.showCreateEvent = false
                    }
                })
                .offset(x: !navState.events ? -200 : 0)
                .animation(.easeInOut(duration: 0.3), value: navState.events)
                .environmentObject(settingsManager)
                Spacer()
                GenericIcon(animate: $eventVM.animateEvent, closedIcon: "plus", openIcon: "plus", size: 20, onSelect: {
                    withAnimation(.none) {
                        eventVM.animateEvent.toggle()
                    }
                    withAnimation(.easeInOut(duration: 0.3)) {
                        eventVM.showCreateEvent.toggle()
                        eventVM.animateMyEvents = false
                        eventVM.showMyEvents = false
                    }
                })
                .offset(x: !navState.events ? 200 : 0)
                .animation(.easeInOut(duration: 0.3), value: navState.events)
                .environmentObject(settingsManager)
                
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .sheet(isPresented: $eventVM.showFilters) {
            FilterView()
                .environmentObject(eventVM)
                .environmentObject(settingsManager)
                .presentationDetents([.fraction(0.4)])
        }
        .sheet(isPresented: $eventVM.showCreateEvent) {
            CreateEventView()
                .environmentObject(eventVM)
                .environmentObject(buildingVM)
                .environmentObject(settingsManager)
        }
        .onChange(of: eventVM.selectedFilters) {
            eventVM.loadFilteredEvents()
        }
    }
}

struct EventHeader: View {
    @EnvironmentObject var settingsManager: SettingsManager
    var text: String
    @Binding var showFilters: Bool
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(text)
                    .font(.system(size: 30))
                    .foregroundStyle(settingsManager.textColor)
                    .fontWeight(.bold)
                Spacer()
                FilterButton(showFilters: $showFilters)
                    .environmentObject(settingsManager)
            }
            Divider()
                .overlay(settingsManager.textColor)
        }
        .padding()
        .padding(.top, 75)
    }
}
