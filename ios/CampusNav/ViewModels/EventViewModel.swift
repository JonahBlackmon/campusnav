//
//  EventViewModel.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/29/25.
//

import SwiftUI

class EventViewModel: ObservableObject {
    @Published var allEvents: [Event] = []
    @Published var showCreateEvent: Bool = false
    @Published var animateEvent: Bool = false
    @Published var showMyEvents: Bool = false
    @Published var animateMyEvents: Bool = false
    @Published var activeEvents: [Event] = []
    @Published var eventBuildings: [Building?] = []
    @Published var eventBuildingAbbr: [String] = []
    @Published var showDescription: Bool = false
    @Published var showFilters: Bool = false
    @Published var selectedFilters: Set<EventTag> = []
    @Published var filteredEvents: [Event] = []
    
    @MainActor
    func loadCurrentEvents(firebaseManager: FirebaseManager, buildingVM: BuildingViewModel) async {
        // Gets all events that occur today at a later time
        allEvents = await firebaseManager.getEvents()
        activeEvents = filterEventsOccurringLaterToday(events: allEvents)
        for event in activeEvents {
            let building = buildingVM.selectBuilding(abbr: event.abbr) ?? nil
            if !eventBuildingAbbr.contains(building?.abbr ?? "") {
                eventBuildings.append(building)
                eventBuildingAbbr.append(building?.abbr ?? "")
            }
        }
    }
    
    func loadFilteredEvents() {
        if !selectedFilters.isEmpty {
            let selectedTagStrings = selectedFilters.map { $0.rawValue }
            filteredEvents = activeEvents.filter { event in
                !Set(event.tags).isDisjoint(with: selectedTagStrings)
            }
        }
    }
    
    private func filterEventsOccurringLaterToday(events: [Event]) -> [Event] {
        let calendar = Calendar.current
        let now = Date()
        let todayWeekday = calendar.component(.weekday, from: now)
        
        return events.filter { event in
            for date in event.event_dates {
                let parsedWeekday = calendar.component(.weekday, from: date)
                if parsedWeekday == todayWeekday {
                    if date > (now - 3600) {
                        return true
                    }
                }
            }
            return false
        }
    }
    
    func ExitEvent() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showCreateEvent = false
            animateEvent = false
            showMyEvents = false
            animateMyEvents = false
            showDescription = false
        }
    }
}
