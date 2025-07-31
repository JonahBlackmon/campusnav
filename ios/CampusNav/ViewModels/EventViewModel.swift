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
    
    private func filterEventsOccurringLaterToday(events: [Event]) -> [Event] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let calendar = Calendar.current
        let now = Date()
        let todayWeekday = calendar.component(.weekday, from: now)
        
        return events.filter { event in
            for timeString in event.event_times {
                guard let parsedTime = formatter.date(from: timeString) else { continue }
                
                let parsedWeekday = calendar.component(.weekday, from: parsedTime)
                if parsedWeekday == todayWeekday {
                    let timeComponents = calendar.dateComponents([.hour, .minute], from: parsedTime)
                    var components = calendar.dateComponents([.year, .month, .day], from: now)
                    components.hour = timeComponents.hour
                    components.minute = timeComponents.minute
                    
                    if let eventDateToday = calendar.date(from: components), eventDateToday > now {
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
