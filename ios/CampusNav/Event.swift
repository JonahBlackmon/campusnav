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
    var event_times: [Date?] // When does this event occur?
    var isRepeating: Bool // Is this a repeating event?
}
