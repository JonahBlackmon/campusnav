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
    var event_times: [String] // When does this event occur?
    var isRepeating: Bool // Is this a repeating event?
}

extension Event {
    func toLocal() -> LocalEvent {
        LocalEvent(
            id: self.id,
            abbr: self.abbr,
            location_description: self.location_description,
            club_name: self.club_name,
            event_name: self.event_name,
            event_times: self.event_times,
            isRepeating: self.isRepeating
        )
    }
}


struct LocalEvent: Identifiable, Codable {
    var id: String?
    var abbr: String
    var location_description: String?
    var club_name: String?
    var event_name: String?
    var event_times: [String]
    var isRepeating: Bool
}

extension LocalEvent {
    func toEvent() -> Event {
        Event(
            id: self.id,
            abbr: self.abbr,
            location_description: self.location_description,
            club_name: self.club_name,
            event_name: self.event_name,
            event_times: self.event_times,
            isRepeating: self.isRepeating
        )
    }
}
