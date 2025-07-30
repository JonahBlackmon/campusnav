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
    
    var collegePrimary: Color
    var collegeSecondary: Color
    
    // Event parameters
    @State var clubName: String = ""
    @State var description: String = ""
    @State var eventName: String = ""
    @State var isRepeating: Bool = false
    @State var selectedBuilding: Building?
    @State var isEventSearching: Bool = false
    @State var eventSearchText: String = ""
    @State var date: Set<DateComponents> = []
    @State var time: Date = Date()
    
    // Focus vars
    @FocusState var clubFocus: Bool
    @FocusState var eventFocus: Bool
    @FocusState var descFocus: Bool
    @FocusState var locationSearchFocus: Bool
    
    
    
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
                }
            }
        ZStack {
            collegePrimary
                .onTapGesture {
                    clubFocus = false
                    eventFocus = false
                    descFocus = false
                }
            VStack {
                Text("Create an Event")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(collegeSecondary)
                    .padding()
                ScrollView {
                    if selectedBuilding == nil {
                        LocationSearchButton(locationSearchFocus: $locationSearchFocus, isEventSearching: $isEventSearching, eventSearchText: $eventSearchText, collegePrimary: collegePrimary, collegeSecondary: collegeSecondary)
                        if isEventSearching {
                            LocationSearch(eventSearchText: $eventSearchText, locationSearchFocus: $locationSearchFocus, collegePrimary: collegePrimary, selectedBuilding: $selectedBuilding)
                                .environmentObject(buildingVM)
                        }
                    } else {
                        // We have a building chosen
                        HStack {
                            Text("Location: \(selectedBuilding?.name ?? "")")
                                .frame(alignment: .leading)
                                .fontWeight(.bold)
                                .font(.system(size: 15))
                                .foregroundStyle(collegeSecondary)
                            Spacer()
                        }
                        .padding()
                    }
                    InputField(textField: $eventName, placeHolderText: "Event Name (Required)", collegeSecondary: collegeSecondary)
                        .focused($eventFocus)
                        .padding(.leading)
                        .padding(.trailing)
                    InputField(textField: $clubName, placeHolderText: "Club Name (Optional)", collegeSecondary: collegeSecondary)
                        .focused($clubFocus)
                        .padding(.leading)
                        .padding(.trailing)
                    InputField(textField: $description, placeHolderText: "Location Description (Optional)", collegeSecondary: collegeSecondary)
                        .focused($descFocus)
                        .padding(.leading)
                        .padding(.trailing)
                    Toggle(isOn: $isRepeating) {
                        Text("Is this event repeating?")
                            .fontWeight(.bold)
                            .font(.system(size: 15))
                            .foregroundStyle(collegeSecondary)
                    }
                    .tint(collegeSecondary)
                    .padding()
                    DateTimeSelector(collegeSecondary: collegeSecondary, date: $date, time: $time)
                    SaveEventButton(collegePrimary: collegePrimary, collegeSecondary: collegeSecondary, building: selectedBuilding, description: description, clubName: clubName, eventName: eventName, isRepeating: isRepeating, days: $date, time: $time)
                        .environmentObject(eventVM)
                        .environmentObject(firebaseManager)
                        .environmentObject(settingsManager)
                        .padding()
                }
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
    var collegePrimary: Color
    var collegeSecondary: Color
    let building: Building?
    let description: String?
    let clubName: String?
    let eventName: String?
    let isRepeating: Bool
    @Binding var days: Set<DateComponents>
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
            } else if days == [] {
                showDaysError = true
            } else {
                firebaseManager.publishEvent(abbr: building?.abbr ?? "", locationDescription: description, clubName: clubName, eventName: eventName, eventTimes: combinedDatesFormatted(days: days, time: time), isRepeating: isRepeating, settingsManager: settingsManager)
                eventVM.ExitEvent()
            }
        } label: {
            VStack {
                Text("Publish Event")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundStyle(collegePrimary)
            .background(collegeSecondary)
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

struct CreateEventIcon: View {
    @EnvironmentObject var eventVM: EventViewModel
    var collegePrimary: Color
    var collegeSecondary: Color
    var body: some View {
        Button {
            withAnimation(.none) {
                eventVM.animateEvent.toggle()
            }
            withAnimation(.easeInOut(duration: 0.3)) {
                eventVM.showCreateEvent.toggle()
                eventVM.animateMyEvents = false
                eventVM.showMyEvents = false
            }
        } label: {
            ZStack {
                collegePrimary
                Image(systemName: eventVM.animateEvent ? "minus" : "plus")
                    .foregroundStyle(collegeSecondary)
                    .font(.system(size: 20))
            }
            .frame(width: 50, height: 50)
            .cornerRadius(24)
            .keyframeAnimator(initialValue: FavoritesProperties(), trigger: eventVM.animateEvent) {
                content, value in
                content
                    .scaleEffect(value.verticalStretch)
                    .rotationEffect(Angle(degrees: value.rotation))
            } keyframes: { _ in
                KeyframeTrack(\.verticalStretch) {
                    SpringKeyframe(1.15, duration: animationDuration * 0.25)
                    CubicKeyframe(1, duration: animationDuration * 0.25)
                }
                KeyframeTrack(\.rotation) {
                    CubicKeyframe(30, duration: animationDuration * 0.15)
                    CubicKeyframe(-30, duration: animationDuration * 0.15)
                    CubicKeyframe(0, duration: animationDuration * 0.15)
                }
            }
        }
        .sensoryFeedback(.impact(flexibility: .rigid, intensity: 1.0), trigger: eventVM.animateEvent)
    }
}

struct GenericIcon: View {
    @Binding var animate: Bool
    @Binding var navStateVar: Bool
    var collegePrimary: Color
    var collegeSecondary: Color
    var closedIcon: String
    var openIcon: String
    let offset: CGFloat
    let onSelect: () -> Void
    var body: some View {
        ZStack {
            Button {
                onSelect()
            } label: {
                ZStack {
                    collegePrimary
                    Image(systemName: animate ? openIcon : closedIcon)
                        .foregroundStyle(collegeSecondary)
                        .font(.system(size: 20))
                }
                .frame(width: 50, height: 50)
                .cornerRadius(24)
                .keyframeAnimator(initialValue: IconProperties(), trigger: animate) {
                    content, value in
                    content
                        .scaleEffect(value.verticalStretch)
                        .rotationEffect(Angle(degrees: value.rotation))
                } keyframes: { _ in
                    KeyframeTrack(\.verticalStretch) {
                        SpringKeyframe(1.15, duration: animationDuration * 0.25)
                        CubicKeyframe(1, duration: animationDuration * 0.25)
                    }
                    KeyframeTrack(\.rotation) {
                        CubicKeyframe(30, duration: animationDuration * 0.15)
                        CubicKeyframe(-30, duration: animationDuration * 0.15)
                        CubicKeyframe(0, duration: animationDuration * 0.15)
                    }
                }
            }
            .sensoryFeedback(.impact(flexibility: .rigid, intensity: 1.0), trigger: animate)
        }
        .frame(maxHeight: .infinity, alignment: .topTrailing)
        .padding()
        .shadow(color: .black.opacity(0.5), radius: 5)
        .offset(x: navStateVar ? 0 : offset)
    }
}

struct IconProperties {
    var rotation: Double = 0.0
    var verticalStretch: Double = 1.0
}
