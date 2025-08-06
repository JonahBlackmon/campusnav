//
//  EventDisplay.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/30/25.
//
import SwiftUI

struct EventsList: View {
    @EnvironmentObject var buildingVM: BuildingViewModel
    @EnvironmentObject var eventVM: EventViewModel
    @EnvironmentObject var navState: NavigationUIState
    @EnvironmentObject var settingsManager: SettingsManager
    var body: some View {
        
        if eventVM.activeEvents.count > 0 && eventVM.selectedFilters.isEmpty {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(
                        Array(eventVM.activeEvents.enumerated()), id: \.element.id) { index, event in
                            EventItem(event: event)
                                .environmentObject(buildingVM)
                                .environmentObject(eventVM)
                                .environmentObject(navState)
                                .environmentObject(settingsManager)
                        }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        } else if eventVM.filteredEvents.count > 0 {
            // We have filters
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(
                        Array(eventVM.filteredEvents.enumerated()), id: \.element.id) { index, event in
                            EventItem(event: event)
                                .environmentObject(buildingVM)
                                .environmentObject(eventVM)
                                .environmentObject(navState)
                                .environmentObject(settingsManager)
                        }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        } else {
            VStack {
                Text("No Events Yet!")
                    .font(.system(size: 17))
                    .foregroundStyle(settingsManager.accentColor)
                    .fontWeight(.bold)
                    .padding(5)
                Text("Check back later for updates or publish an event.")
                    .font(.system(size: 15))
                    .foregroundStyle(settingsManager.textColor.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: 300, alignment: .center)
        }
    }
}

struct EventItem: View {
    @EnvironmentObject var buildingVM: BuildingViewModel
    @EnvironmentObject var eventVM: EventViewModel
    @EnvironmentObject var navState: NavigationUIState
    @EnvironmentObject var settingsManager: SettingsManager
    let event: Event
    var building: Building? {
        return buildingVM.selectBuilding(abbr: event.abbr)
    }
    var tags: [EventTag] { event.tags.compactMap { EventTag(rawValue: $0) } }
    @State var showDesc: Bool = false
    var body: some View {
        VStack {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showDesc.toggle()
                }
            } label: {
                HStack(alignment: .top) {
                    VStack {
                        Image(systemName: "applescript.fill")
                            .foregroundStyle(settingsManager.textColor)
                            .font(.system(size: 30))
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding()
                    VStack(alignment: .leading) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(event.event_name ?? "")
                                    .foregroundStyle(settingsManager.textColor)
                                    .font(.system(size: 20))
                                HStack {
                                    // Meeting Location
                                    if ((event.club_name?.isEmpty) == nil) {
                                        Text("\(event.club_name ?? "Meeting") @ \(event.abbr)")
                                    } else {
                                        Text("Meeting @ \(event.abbr)")
                                    }
                                    // Meeting Times
                                    VStack(alignment: .leading) {
                                        Text(event.event_times_strings.first!)
                                            .foregroundStyle(settingsManager.textColor)
                                            .font(.system(size: 15))
                                        if event.duration != 0.0 {
                                            Text(timeIntervalToLabel(event.duration))
                                                .foregroundStyle(settingsManager.textColor)
                                                .font(.system(size: 15))
                                        }
                                    }
                                }
                                .foregroundStyle(settingsManager.accentColor)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(tags) { tag in
                                            TagIcon(tag: tag)
                                                .environmentObject(settingsManager)
                                        }
                                    }
                                }
                                .padding(.trailing)
                            }
                            Spacer()
                            Image(systemName: "chevron.down")
                                .rotationEffect(Angle(degrees: showDesc ? 180 : 0))
                                .foregroundStyle(settingsManager.textColor)
                                .padding()
                        }
                        if showDesc {
                            if event.location_description != nil {
                                Text("\(event.location_description!)")
                                    .foregroundStyle(settingsManager.textColor)
                            }
                            GoHereButton
                                .padding(.trailing)
                        }
                        Divider()
                            .overlay(settingsManager.textColor)
                            .padding(.trailing)
                    }
                }
            }
        }
    }
    
    private var GoHereButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                navState.currentView = "Map"
                buildingVM.selectedBuilding = building
                navState.showNavigationCard = true
            }
        } label: {
            VStack {
                Text("Directions")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundStyle(settingsManager.accentColor)
            .background(settingsManager.primaryColor)
            .cornerRadius(12)
            .shadow(color: settingsManager.textColor.opacity(0.3), radius: 3)
        }
    }
}
