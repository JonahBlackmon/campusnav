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
        if eventVM.activeEvents.count > 0 {
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
            .padding(.top, 100)
        } else {
            Text("Hmm no events seem to be found.. Try making one!")
                .font(.system(size: 15))
                .foregroundStyle(.charcoal)
                .fontWeight(.bold)
                .padding()
                .frame(alignment: .center)
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
    @State var showDesc: Bool = false
    var body: some View {
        VStack {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    navState.currentView = "Map"
                    buildingVM.selectedBuilding = building
                    navState.showNavigationCard = true
                }
            } label: {
                HStack {
                    Image(systemName: "applescript.fill")
                        .foregroundStyle(.charcoal)
                        .font(.system(size: 30))
                        .padding()
                    VStack(alignment: .leading) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(event.event_name ?? "")
                                    .foregroundStyle(.charcoal)
                                    .font(.system(size: 20))
                                HStack {
                                    Text("\(event.club_name ?? "Meeting") @ \(event.abbr)")
                                }
                                .foregroundStyle(settingsManager.primaryColor)
                            }
                            Spacer()
                            if event.location_description != nil {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        showDesc.toggle()
                                    }
                                } label: {
                                    Image(systemName: "chevron.down")
                                        .rotationEffect(Angle(degrees: showDesc ? 180 : 0))
                                        .foregroundStyle(.charcoal)
                                        .padding()
                                }
                            }
                        }
                        if showDesc {
                            Text("\(event.location_description!)")
                                .foregroundStyle(.charcoal)
                        }
                        Divider()
                            .overlay(.charcoal)
                            .padding(.trailing)
                    }
                }
            }
        }
    }
}

struct MyEventItem: View {
    @EnvironmentObject var buildingVM: BuildingViewModel
    @EnvironmentObject var eventVM: EventViewModel
    @EnvironmentObject var navState: NavigationUIState
    @EnvironmentObject var firebaseManager: FirebaseManager
    @EnvironmentObject var settingsManager: SettingsManager
    let event: LocalEvent?
    var index: Int
    var building: Building? {
        return buildingVM.selectBuilding(abbr: event?.abbr ?? "")
    }
    @State var show: Bool = false
    @State var showDesc: Bool = false
    var body: some View {
        VStack {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    navState.currentView = "Map"
                    buildingVM.selectedBuilding = building
                    navState.showNavigationCard = true
                }
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(event?.event_name ?? "")
                                    .foregroundStyle(settingsManager.accentColor)
                                    .font(.system(size: 20))
                                HStack {
                                    Text("\(event?.club_name ?? "Meeting") @ \(event?.abbr ?? "")")
                                }
                                .foregroundStyle(settingsManager.accentColor)
                            }
                            Spacer()
                            if event?.location_description != nil {
                                Button {
                                    firebaseManager.deleteEvent(ref: event?.id ?? "", settingsManager: settingsManager)
                                } label: {
                                    Image(systemName: "trash")
                                        .rotationEffect(Angle(degrees: showDesc ? 180 : 0))
                                        .foregroundStyle(settingsManager.accentColor)
                                        .padding()
                                }
                            }
                        }
                        Divider()
                            .overlay(settingsManager.accentColor)
                            .padding(.trailing)
                    }
                }
            }
            .foregroundStyle(.black.opacity(0.8))
            .padding()
            .opacity(show ? 1 : 0)
            .offset(y: show ? 0 : 20)
            .animation(.bouncy.delay(Double(index) * 0.05), value: show)
            .onAppear {
                show = true
            }
        }
    }
}
