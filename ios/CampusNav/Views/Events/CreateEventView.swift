//
//  CreateEventView.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/30/25.
//
import SwiftUI

struct CreateEventView: View {
    @EnvironmentObject var eventVM: EventViewModel
    @EnvironmentObject var buildingVM: BuildingViewModel
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    // Event parameters
    @State var clubName: String = ""
    @State var description: String = ""
    @State var eventName: String = ""
    @State var isRepeating: Bool = false
    @State var selectedBuilding: Building?
    @State var isEventSearching: Bool = false
    @State var eventSearchText: String = ""
    @State var date: Date = Date()
    @State var time: Date = Date()
    @State var duration: Date = Calendar.current.date(from: DateComponents(hour: 0, minute: 0)) ?? Date()
    
    // Focus vars
    @FocusState var clubFocus: Bool
    @FocusState var eventFocus: Bool
    @FocusState var descFocus: Bool
    @FocusState var locationSearchFocus: Bool
    @FocusState var descriptionFocus: Bool
    
    @State var selectedTags: Set<EventTag> = []
    
    var body: some View {
        ZStack {
            settingsManager.primaryColor
            VStack(alignment: .leading) {
                Text("Create Event")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(settingsManager.textColor)
                    .padding()
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Event Name")
                            .font(.system(size: 18))
                            .foregroundStyle(settingsManager.textColor.opacity(0.6))
                            .padding(.leading)
                            .frame(alignment: .leading)
                        InputFieldWithDescription(textField: $eventName, placeHolderText: "Enter event name", description: $description, showDescription: $eventVM.showDescription, descriptionFocus: $descriptionFocus)
                            .environmentObject(settingsManager)
                            .focused($eventFocus)
                            .padding(.horizontal)
                        HStack(alignment: .top, spacing: 20) {
                            VStack(alignment: .leading) {
                                Text("Date")
                                    .font(.system(size: 18))
                                    .foregroundStyle(settingsManager.textColor.opacity(0.6))
                                CompactDateSelector(date: $date)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            VStack(alignment: .leading) {
                                Text("Time")
                                    .font(.system(size: 18))
                                    .foregroundStyle(settingsManager.textColor.opacity(0.6))
                                TimeSelector(time: $time)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            VStack(alignment: .leading) {
                                Text("Duration")
                                    .font(.system(size: 18))
                                    .foregroundStyle(settingsManager.textColor.opacity(0.6))
                                DurationSelector(time: $duration)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .offset(x: -35)
                            }
                        }
                        .padding()
                        Text("Tags")
                            .font(.system(size: 18))
                            .foregroundStyle(settingsManager.textColor.opacity(0.6))
                            .padding(.leading)
                            .frame(alignment: .leading)
                        AddTags(selectedTags: $selectedTags)
                            .environmentObject(settingsManager)
                        
                        Text("Location")
                            .font(.system(size: 18))
                            .foregroundStyle(settingsManager.textColor.opacity(0.6))
                            .padding(.leading)
                            .frame(alignment: .leading)
                        if selectedBuilding == nil {
                            LocationSearchButton(locationSearchFocus: $locationSearchFocus, isEventSearching: $isEventSearching, eventSearchText: $eventSearchText)
                                .padding(4)
                                .background(settingsManager.accentColor.opacity(0.1))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            if isEventSearching {
                                LocationSearch(eventSearchText: $eventSearchText, locationSearchFocus: $locationSearchFocus, selectedBuilding: $selectedBuilding)
                                    .environmentObject(settingsManager)
                                    .environmentObject(buildingVM)
                            }
                        } else {
                            // We have a building chosen
                            HStack {
                                Text("\(selectedBuilding?.name ?? "")")
                                    .frame(alignment: .leading)
                                    .font(.system(size: 15))
                                    .foregroundStyle(settingsManager.accentColor)
                                Spacer()
                            }
                            .padding()
                        }
                    }
                }
                SaveEventButton(building: selectedBuilding, description: description, clubName: clubName, eventName: eventName, isRepeating: isRepeating, days: $date, time: $time, tags: selectedTags)
                    .environmentObject(eventVM)
                    .environmentObject(firebaseManager)
                    .environmentObject(settingsManager)
                    .environmentObject(buildingVM)
                    .padding()
            }
            .padding(.vertical)
            if eventVM.showDescription {
                DescriptionView(description: $description, showDescription: $eventVM.showDescription, descriptionFocus: $descriptionFocus)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .onChange(of: locationSearchFocus) {
            if locationSearchFocus {
                isEventSearching = true
            }
        }
    }
}

struct SaveEventButton: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var eventVM: EventViewModel
    @EnvironmentObject var firebaseManager: FirebaseManager
    @EnvironmentObject var buildingVM: BuildingViewModel
    let building: Building?
    let description: String?
    let clubName: String?
    let eventName: String?
    let isRepeating: Bool
    @Binding var days: Date
    @Binding var time: Date
    let tags: Set<EventTag>
    var tagStrings: [String] { tags.map { $0.rawValue } }
    @State var showEventError: Bool = false
    @State var showDaysError: Bool = false
    @State var showBuildingError: Bool = false
    var body: some View {
        Button {
            if building == nil {
                showBuildingError = true
            } else if eventName == "" {
                showEventError = true
            } else {
                firebaseManager.publishEvent(abbr: building?.abbr ?? "", locationDescription: description, clubName: clubName, eventName: eventName, eventTimes: combinedDateTimeFormatted(day: days, time: time), isRepeating: isRepeating, tags: tagStrings, settingsManager: settingsManager)
                Task {
                    await eventVM.loadCurrentEvents(firebaseManager: firebaseManager, buildingVM: buildingVM)
                }
                eventVM.ExitEvent()
            }
        } label: {
            VStack {
                Text("Publish Event")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundStyle(settingsManager.accentColor)
            .background(settingsManager.primaryColor)
            .cornerRadius(12)
            .shadow(color: settingsManager.textColor.opacity(0.3), radius: 3)
        }
        .alert("Error", isPresented: $showEventError) {
            Button("OK") { }
        } message: {
            Text("Must add event name to proceed.")
        }
        .alert("Error", isPresented: $showDaysError) {
            Button("OK") { }
        } message: {
            Text("Must select at least one day for event.")
        }
        .alert("Error", isPresented: $showBuildingError) {
            Button("OK") { }
        } message: {
            Text("Must select a building location for the event.")
        }
    }
}
