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
    
    init() {
        do {
            if var savedData = self.defaults.object(forKey: Keys.Favorites) as? Data {
                do {
                    favorites = try JSONDecoder().decode([String : Building].self, from: savedData)
                } catch {
                    print("Error loading favorites: \(error)")
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
