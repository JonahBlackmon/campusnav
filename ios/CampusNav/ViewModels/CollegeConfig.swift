//
//  CollegeConfig.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 8/6/25.
//

// Struct to allow for easy expansion of colleges
struct CollegeConfig: Codable {
    let id: String
    let name: String
    let accentColorString: String
    let lighterAccentColorString: String
}
