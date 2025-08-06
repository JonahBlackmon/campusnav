//
//  Event.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/28/25.
//
import FirebaseFirestore

struct Event: Identifiable, Codable {
    @DocumentID var id: String?
    var abbr: String // What building is it in?
    var location_description: String? // Ex. 4th floor GDC
    var club_name: String? // If this is a club meeting, what's the name?
    var event_name: String? // If this is an event what's the name? i.e. "General Meeting" or "Calc Study Session"
    var event_times_strings: [String] // When does this event occur?
    var event_dates: [Date]
    var duration: TimeInterval
    var isRepeating: Bool // Is this a repeating event?
    var tags: [String] // What type of event is this?
}

extension Event {
    func toLocal() -> LocalEvent {
        LocalEvent(
            id: self.id,
            abbr: self.abbr,
            location_description: self.location_description,
            club_name: self.club_name,
            event_name: self.event_name,
            event_times_strings: self.event_times_strings,
            event_dates: self.event_dates,
            duration: self.duration,
            isRepeating: self.isRepeating,
            tags: self.tags
        )
    }
}


struct LocalEvent: Identifiable, Codable {
    var id: String?
    var abbr: String
    var location_description: String?
    var club_name: String?
    var event_name: String?
    var event_times_strings: [String]
    var event_dates: [Date]
    var duration: TimeInterval
    var isRepeating: Bool
    var tags: [String]
}

extension LocalEvent {
    func toEvent() -> Event {
        Event(
            id: self.id,
            abbr: self.abbr,
            location_description: self.location_description,
            club_name: self.club_name,
            event_name: self.event_name,
            event_times_strings: self.event_times_strings,
            event_dates: self.event_dates,
            duration: self.duration,
            isRepeating: self.isRepeating,
            tags: self.tags
        )
    }
}
