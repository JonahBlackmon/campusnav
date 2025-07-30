//
//  EventView.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/29/25.
//
import SwiftUI

struct EventView: View {
    var collegePrimary: Color
    var collegeSecondary: Color
    @EnvironmentObject var buildingVM: BuildingViewModel
    @EnvironmentObject var eventVM: EventViewModel
    @EnvironmentObject var navState: NavigationUIState
    @EnvironmentObject var firebaseManager: FirebaseManager
    @EnvironmentObject var settingsManager: SettingsManager
    var body: some View {
        ZStack {
            Color.offWhite
                .ignoresSafeArea()
            EventsList(collegePrimary: collegePrimary)
                .environmentObject(buildingVM)
                .environmentObject(eventVM)
                .environmentObject(navState)
            if eventVM.showCreateEvent {
                CreateEventView(collegePrimary: collegePrimary, collegeSecondary: collegeSecondary)
                    .environmentObject(eventVM)
                    .environmentObject(buildingVM)
            }
            if eventVM.showMyEvents {
                MyEventsView(collegePrimary: collegePrimary, collegeSecondary: collegeSecondary)
                    .environmentObject(buildingVM)
                    .environmentObject(eventVM)
                    .environmentObject(navState)
                    .environmentObject(firebaseManager)
                    .environmentObject(settingsManager)
            }
            HStack {
                GenericIcon(animate: $eventVM.animateMyEvents, navStateVar: $navState.events, collegePrimary: collegePrimary, collegeSecondary: collegeSecondary, closedIcon: "bookmark", openIcon: "bookmark.fill", offset: -200, onSelect: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        eventVM.animateMyEvents.toggle()
                        eventVM.showMyEvents.toggle()
                        eventVM.animateEvent = false
                        eventVM.showCreateEvent = false
                    }
                })
                Spacer()
                GenericIcon(animate: $eventVM.animateEvent, navStateVar: $navState.events, collegePrimary: collegePrimary, collegeSecondary: collegeSecondary, closedIcon: "plus", openIcon: "minus", offset: 200, onSelect: {
                    withAnimation(.none) {
                        eventVM.animateEvent.toggle()
                    }
                    withAnimation(.easeInOut(duration: 0.3)) {
                        eventVM.showCreateEvent.toggle()
                        eventVM.animateMyEvents = false
                        eventVM.showMyEvents = false
                    }
                })
                    
            }
        }
    }
}

struct MyEventsIcon: View {
    @EnvironmentObject var eventVM: EventViewModel
    var collegePrimary: Color
    var collegeSecondary: Color
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                eventVM.animateMyEvents.toggle()
                eventVM.showMyEvents.toggle()
                eventVM.animateEvent = false
                eventVM.showCreateEvent = false
            }
        } label: {
            ZStack {
                collegePrimary
                Image(systemName: eventVM.animateMyEvents ? "bookmark.fill" : "bookmark")
                    .foregroundStyle(collegeSecondary)
                    .font(.system(size: 20))
            }
            .frame(width: 50, height: 50)
            .cornerRadius(24)
            .keyframeAnimator(initialValue: FavoritesProperties(), trigger: eventVM.animateMyEvents) {
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
        .sensoryFeedback(.impact(flexibility: .rigid, intensity: 1.0), trigger: eventVM.animateMyEvents)
    }
}

struct MyEventsView: View {
    @EnvironmentObject var buildingVM: BuildingViewModel
    @EnvironmentObject var eventVM: EventViewModel
    @EnvironmentObject var navState: NavigationUIState
    @EnvironmentObject var firebaseManager: FirebaseManager
    @EnvironmentObject var settingsManager: SettingsManager
    var collegePrimary: Color
    var collegeSecondary: Color
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
                collegePrimary
                if !eventVM.eventBuildings.isEmpty {
                    ScrollView {
                        ForEach(Array(settingsManager.events.keys.enumerated()), id: \.element) { index, key in
                            MyEventItem(event: settingsManager.events[key] ?? nil, collegePrimary: collegePrimary, collegeSecondary: collegeSecondary, index: index)
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

//#Preview {
//    CreateEventView(collegePrimary: .burntOrange, collegeSecondary: .offWhite)
//        .environmentObject(EventViewModel())
//        .environmentObject(NavigationUIState())
//}
