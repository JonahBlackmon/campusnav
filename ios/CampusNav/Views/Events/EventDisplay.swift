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
    var collegePrimary: Color
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(
                    Array(eventVM.activeEvents.enumerated()), id: \.element.id) { index, event in
                        EventItem(event: event, collegePrimary: collegePrimary)
                            .environmentObject(buildingVM)
                            .environmentObject(eventVM)
                            .environmentObject(navState)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.top, 100)
    }
}

struct EventItem: View {
    @EnvironmentObject var buildingVM: BuildingViewModel
    @EnvironmentObject var eventVM: EventViewModel
    @EnvironmentObject var navState: NavigationUIState
    let event: Event
    var collegePrimary: Color
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
                                .foregroundStyle(collegePrimary)
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
    var collegePrimary: Color
    var collegeSecondary: Color
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
                                    .foregroundStyle(collegeSecondary)
                                    .font(.system(size: 20))
                                HStack {
                                    Text("\(event?.club_name ?? "Meeting") @ \(event?.abbr ?? "")")
                                }
                                .foregroundStyle(collegeSecondary)
                            }
                            Spacer()
                            if event?.location_description != nil {
                                Button {
                                    firebaseManager.deleteEvent(ref: event?.id ?? "", settingsManager: settingsManager)
                                } label: {
                                    Image(systemName: "trash")
                                        .rotationEffect(Angle(degrees: showDesc ? 180 : 0))
                                        .foregroundStyle(collegeSecondary)
                                        .padding()
                                }
                            }
                        }
                        Divider()
                            .overlay(collegeSecondary)
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

#Preview {
    EventItem(event: Event(abbr: "GDC", location_description: "GDC 4th Floor", club_name: "ACM", event_name: "Weekly Meeting", event_times: ["Tuesday 6:00 PM", "Thursday 6:00 PM"], isRepeating: true), collegePrimary: .burntOrange)
        .environmentObject(BuildingViewModel())
        .environmentObject(EventViewModel())
        .environmentObject(NavigationUIState())
}
