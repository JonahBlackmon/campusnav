//
//  SettingsManager.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/19/25.
//

import SwiftUI

struct Keys {
    static let PrimaryColor = "PrimaryColor"
    static let AccentColor = "AccentColor"
    static let TextColor = "TextColor"
    static let LighterAccent = "LighterAccent"
    static let Favorites = "Favorites"
    static let Events = "Events"
    static let DarkMode = "DarkMode"
}

let Colors: [String: Color] = ["burntOrange" : Color.burntOrange, "offWhite" : Color.offWhite,
                               "tcuPurple" : Color.tcuPurple, "charcoal" : Color.charcoal, "lightOrange" : Color.lightOrange, "softBlack" : Color.softBlack]

func colorFromString(colorString: String) -> Color {
    return Colors[colorString]!
}


// Manager in charge of data related to UserDefaults, establishes College Config as well
class SettingsManager: ObservableObject {
    let defaults = UserDefaults.standard
    
    @Published var primaryColorString: String = "offWhite"
    @Published var accentColorString: String = "burntOrange"
    @Published var textColorString: String = "softBlack"
    @Published  var lighterAccentString: String = "lightOrange"
    
    @Published var darkMode: Bool
    
    @Published var favorites: [String : Building] = [:]
    
    @Published var events: [String : LocalEvent] = [:]
    
    @Published var config: CollegeConfig?
    
    
    init() {
        self.darkMode = defaults.object(forKey: Keys.DarkMode) != nil
            ? defaults.bool(forKey: Keys.DarkMode)
            : false

        if let favoritesData = self.defaults.object(forKey: Keys.Favorites) as? Data {
            do {
                favorites = try JSONDecoder().decode([String : Building].self, from: favoritesData)
            } catch {
                print("Error loading favorites: \(error)")
            }
        }

        if let eventsData = self.defaults.object(forKey: Keys.Events) as? Data {
            do {
                events = try JSONDecoder().decode([String : LocalEvent].self, from: eventsData)
            } catch {
                print("Error loading events: \(error)")
            }
        }
    }
    
    // College specific data to be loaded once a user selects a college
    func initializeAfterOnboarding() {
        loadCurrentCollegeConfig()
        applyCollegeThemeColors()
        setThemeColors()
    }
    
    private func loadCurrentCollegeConfig() {
        let collegeID = UserDefaults.standard.string(forKey: "collegeID")
        print("Attempting to load config for collegeID: \(collegeID ?? "nil")")
        guard let collegeID = UserDefaults.standard.string(forKey: "collegeID"),
              let url = Bundle.main.url(forResource: "\(collegeID)Config", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let config = try? JSONDecoder().decode(CollegeConfig.self, from: data) else {
            print("Failed to load college config")
            return
        }

        self.config = config
    }
    
    func applyCollegeThemeColors() {
        guard let config = config else { return }

        accentColorString = "burntOrange"// config.accentColorString
        lighterAccentString = "lightOrange"// config.lighterAccentColorString
    }
    
    func setThemeColors() {
        primaryColorString = darkMode ? "softBlack" : "offWhite"
        textColorString = darkMode ? "offWhite" : "softBlack"
    }
    
    func favoritesList() -> [Building] {
        return Array(favorites.values)
    }
    
    var primaryColor: Color {
        return colorFromString(colorString: primaryColorString)
    }
    var accentColor: Color {
        return colorFromString(colorString: accentColorString)
    }
    
    var textColor: Color {
        return colorFromString(colorString: textColorString)
    }
    var lighterAccent: Color {
        return colorFromString(colorString: lighterAccentString)
    }
    
    func toggleDarkMode() {
        defaults.set(darkMode, forKey: Keys.DarkMode)
        setThemeColors()
    }
    
    // Updates user theme colors i.e. dark mode vs light mode
    func updateThemeColors(primaryColor: String, textColor: String) {
        defaults.set(primaryColor, forKey: Keys.PrimaryColor)
        defaults.set(textColor, forKey: Keys.TextColor)
    }
    
    // Changes User college colors
    func updateCollegeColors(accentColor: String, lighterAccentColor: String) {
        defaults.set(lighterAccentColor, forKey: Keys.PrimaryColor)
        defaults.set(accentColor, forKey: Keys.AccentColor)
    }
    
    // Adds event from UserDefaults
    func writeEvent(_ event: LocalEvent, ref: String) {
        events[ref] = event
        do {
            try defaults.set(JSONEncoder().encode(events), forKey: Keys.Events)
        } catch {
            print("Error setting events: \(error)")
        }
    }
    
    // Removes event from UserDefaults
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
    
    // Adds or removes a favorited building from UserDefaults depending on if it already exists
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
