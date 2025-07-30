//
//  SettingsManager.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/19/25.
//

import SwiftUI

struct Keys {
    static let CollegePrimary = "CollegePrimary"
    static let CollegeSecondary = "CollegeSecondary"
    static let Favorites = "Favorites"
    static let Events = "Events"
}

let Colors: [String: Color] = ["burntOrange" : Color.burntOrange, "offWhite" : Color.offWhite,
                                      "tcuPurple" : Color.tcuPurple]

func colorFromString(colorString: String) -> Color {
    return Colors[colorString]!
}



class SettingsManager: ObservableObject {
    let defaults = UserDefaults.standard
    
    @AppStorage(Keys.CollegePrimary) var collegePrimaryString: String = "burntOrange"
    @AppStorage(Keys.CollegeSecondary) var collegeSecondaryString: String = "offWhite"
    
    @Published var favorites: [String : Building] = [:]
    
    @Published var events: [String : LocalEvent] = [:]
    
    init() {
        do {
            if var favoritesData = self.defaults.object(forKey: Keys.Favorites) as? Data {
                do {
                    favorites = try JSONDecoder().decode([String : Building].self, from: favoritesData)
                } catch {
                    print("Error loading favorites: \(error)")
                }
            }
            if var eventsData = self.defaults.object(forKey: Keys.Events) as? Data {
                do {
                    events = try JSONDecoder().decode([String : LocalEvent].self, from: eventsData)
                } catch {
                    print("Error loading events: \(error)")
                }
            }
        }
    }
    
    func favoritesList() -> [Building] {
        return Array(favorites.values)
    }
    
    var collegePrimary: Color {
        return colorFromString(colorString: collegePrimaryString)
    }
    var collegeSecondary: Color {
        return colorFromString(colorString: collegeSecondaryString)
    }
    
    func updateCollegeColors(collegePrimary: String, collegeSecondary: String) {
        defaults.set(collegePrimary, forKey: Keys.CollegePrimary)
        defaults.set(collegeSecondary, forKey: Keys.CollegeSecondary)
    }
    
    func writeEvent(_ event: LocalEvent, ref: String) {
        events[ref] = event
        do {
            try defaults.set(JSONEncoder().encode(events), forKey: Keys.Events)
        } catch {
            print("Error setting events: \(error)")
        }
    }
    
    func removeEvent(ref: String) {
        if events.removeValue(forKey: ref) != nil {
            do {
                let data = try JSONEncoder().encode(events)
                defaults.set(data, forKey: Keys.Events)
            } catch {
                print("Error saving events after removal: \(error)")
            }
        }
    }
    
    func writeFavorites(_ favorite: Building, abbr: String) {
        if favorites[abbr] != nil {
            favorites.removeValue(forKey: abbr)
        } else {
            favorites[abbr] = favorite
        }
        
        do {
            try defaults.set(JSONEncoder().encode(favorites), forKey: Keys.Favorites)
        } catch {
            print("Error setting favorites: \(error)")
        }
    }
}
