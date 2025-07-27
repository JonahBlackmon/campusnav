//
//  Building.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/26/25.
//

import Foundation

struct Building: Identifiable, Codable, Equatable {
    var id = UUID()
    let abbr: String
    let name: String
    let photoURL: String
}
