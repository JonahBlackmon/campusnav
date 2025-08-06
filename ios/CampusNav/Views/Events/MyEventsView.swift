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
                VStack {
                    HeaderText(text: "My Events")
                    if !settingsManager.events.isEmpty {
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
                        Text("No Events Yet!")
                            .font(.system(size: 17))
                            .foregroundStyle(settingsManager.accentColor)
                            .fontWeight(.bold)
                            .padding(5)
                        Text("Published events will appear here.")
                            .font(.system(size: 15))
                            .foregroundStyle(settingsManager.textColor.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
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
                                    .foregroundStyle(settingsManager.textColor)
                                    .font(.system(size: 20))
                                HStack {
                                    if ((event?.club_name?.isEmpty) == nil) {
                                        Text("\(event?.club_name ?? "Meeting") @ \(event!.abbr)")
                                    } else {
                                        Text("Meeting @ \(event?.abbr ?? "")")
                                    }
                                    VStack(alignment: .leading) {
                                        Text(event?.event_times_strings.first! ?? "")
                                            .foregroundStyle(settingsManager.textColor)
                                            .font(.system(size: 15))
                                    }
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
                            .overlay(settingsManager.textColor.opacity(0.8))
                            .padding(.trailing)
                    }
                }
            }
            .foregroundStyle(settingsManager.textColor.opacity(0.8))
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
