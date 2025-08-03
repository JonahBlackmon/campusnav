//
//  FirebaseManager.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/28/25.
//
import FirebaseFirestore

class FirebaseManager: ObservableObject {
    
    private let db = Firestore.firestore()
    private let eventCollection = Firestore.firestore().collection("events")
    
    // Save published events to users UserDefaults and use that for storing what user made what
    func publishEvent(abbr: String, locationDescription: String?, clubName: String?,
                      eventName: String?, eventTimes: [String], isRepeating: Bool, tags: [String], settingsManager: SettingsManager) {
        let event = Event(
            abbr: abbr,
            location_description: locationDescription,
            club_name: clubName,
            event_name: eventName,
            event_times: eventTimes,
            isRepeating: isRepeating,
            tags: tags
        )
        
        do {
            let ref = try eventCollection.addDocument(from: event)
            print("Document added with new reference: \(ref)")
            var localEvent: LocalEvent = event.toLocal()
            localEvent.id = ref.documentID
            settingsManager.writeEvent(localEvent, ref: ref.documentID)
        } catch {
            print("Error adding document: \(error)")
        }
    }
    
    func deleteEvent(ref: String, settingsManager: SettingsManager) {
        eventCollection.document(ref).delete()
        settingsManager.removeEvent(ref: ref)
    }
    
    func getEvents() async -> [Event] {
        var events: [Event] = []
        do {
            try await events = eventCollection
                .getDocuments()
                .documents.compactMap() { document in
                    try? document.data(as: Event.self)
                }
        } catch {
            print("Error getting events: \(error)")
        }
        return events
    }
    
}
