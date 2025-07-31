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
    @State var startTime: Date = Date()
    @State var endTime: Date = Date()
    
    // Focus vars
    @FocusState var clubFocus: Bool
    @FocusState var eventFocus: Bool
    @FocusState var descFocus: Bool
    @FocusState var locationSearchFocus: Bool
    @FocusState var descriptionFocus: Bool
    
    
    
    var body: some View {
        Color.black.opacity(0.8)
            .ignoresSafeArea()
            .transition(.opacity)
            .onTapGesture {
                withAnimation(.none) {
                    eventVM.animateEvent = false
                }
                withAnimation(.easeInOut(duration: 0.3)) {
                    eventVM.showCreateEvent = false
                    eventVM.animateMyEvents = false
                    eventVM.showMyEvents = false
                    descriptionFocus = false
                }
            }
        ZStack {
            settingsManager.primaryColor
                .onTapGesture {
                    clubFocus = false
                    eventFocus = false
                    descriptionFocus = false
                }
            VStack(alignment: .leading) {
                Text("Create Event")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(settingsManager.accentColor)
                    .padding()
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Event Name")
                            .font(.system(size: 18))
                            .foregroundStyle(settingsManager.accentColor)
                            .padding(.leading)
                            .frame(alignment: .leading)
                        InputFieldWithDescription(textField: $eventName, placeHolderText: "Enter event name", description: $description, showDescription: $eventVM.showDescription, descriptionFocus: $descriptionFocus)
                            .environmentObject(settingsManager)
                            .focused($eventFocus)
                            .padding()
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Date")
                                    .font(.system(size: 18))
                                    .foregroundStyle(settingsManager.accentColor)
                                CompactDateSelector(date: $date)
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("Start Time")
                                    .font(.system(size: 18))
                                    .foregroundStyle(settingsManager.accentColor)
                                TimeSelector(time: $startTime)
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("End Time")
                                    .font(.system(size: 18))
                                    .foregroundStyle(settingsManager.accentColor)
                                TimeSelector(time: $endTime)
                            }
                        }
                        .padding()
                        Text("Location")
                            .font(.system(size: 18))
                            .foregroundStyle(settingsManager.accentColor)
                            .padding(.leading)
                            .frame(alignment: .leading)
                        if selectedBuilding == nil {
                            LocationSearchButton(locationSearchFocus: $locationSearchFocus, isEventSearching: $isEventSearching, eventSearchText: $eventSearchText)
                                .padding(4)
                                .background(settingsManager.accentColor.opacity(0.1))
                                .cornerRadius(8)
                                .padding()
                            if isEventSearching {
                                LocationSearch(eventSearchText: $eventSearchText, locationSearchFocus: $locationSearchFocus, selectedBuilding: $selectedBuilding)
                                    .environmentObject(settingsManager)
                                    .environmentObject(buildingVM)
                            }
                        } else {
                            // We have a building chosen
                            HStack {
                                Text("Location: \(selectedBuilding?.name ?? "")")
                                    .frame(alignment: .leading)
                                    .fontWeight(.bold)
                                    .font(.system(size: 15))
                                    .foregroundStyle(settingsManager.accentColor)
                                Spacer()
                            }
                            .padding()
                        }
//                        InputField(textField: $clubName, placeHolderText: "Club Name (Optional)", collegeSecondary: collegeSecondary)
//                            .focused($clubFocus)
//                            .padding(.leading)
//                            .padding(.trailing)
//                        InputField(textField: $description, placeHolderText: "Location Description (Optional)", collegeSecondary: collegeSecondary)
//                            .focused($descFocus)
//                            .padding(.leading)
//                            .padding(.trailing)
//                        Toggle(isOn: $isRepeating) {
//                            Text("Is this event repeating?")
//                                .fontWeight(.bold)
//                                .font(.system(size: 15))
//                                .foregroundStyle(collegeSecondary)
//                        }
//                        .tint(collegeSecondary)
//                        .padding()
//                        DateTimeSelector(collegeSecondary: collegeSecondary, date: $date, time: $time)
                    }
                }
                SaveEventButton(building: selectedBuilding, description: description, clubName: clubName, eventName: eventName, isRepeating: isRepeating, days: $date, time: $startTime)
                    .environmentObject(eventVM)
                    .environmentObject(firebaseManager)
                    .environmentObject(settingsManager)
                    .padding()
            }
            if eventVM.showDescription {
                DescriptionView(description: $description, showDescription: $eventVM.showDescription, descriptionFocus: $descriptionFocus)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding(.top, 85)
        .padding(.bottom, 75)
        .padding(.leading, 10)
        .padding(.trailing, 10)
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
    let building: Building?
    let description: String?
    let clubName: String?
    let eventName: String?
    let isRepeating: Bool
    @Binding var days: Date
    @Binding var time: Date
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
                firebaseManager.publishEvent(abbr: building?.abbr ?? "", locationDescription: description, clubName: clubName, eventName: eventName, eventTimes: combinedDateTimeFormatted(day: days, time: time), isRepeating: isRepeating, settingsManager: settingsManager)
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
