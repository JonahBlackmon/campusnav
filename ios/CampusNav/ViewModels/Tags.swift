//
//  Filters.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 8/1/25.
//
import SwiftUI

import SwiftUI

enum EventTag: String, CaseIterable, Identifiable, Codable, Equatable {
    case social = "Social"
    case study = "Study"
    case club = "Club"
    case workshop = "Workshop"
    case career = "Career"
    case speaker = "Speaker"
    case volunteer = "Volunteer"
    case sports = "Sports"
    case arts = "Arts"
    case cs = "CS"
    case eng = "ENG"
    case bio = "BIO"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .social: return .pink
        case .study: return .blue
        case .club: return .purple
        case .workshop: return .orange
        case .career: return .teal
        case .speaker: return .green
        case .volunteer: return .yellow
        case .sports: return .red
        case .arts: return .indigo
        case .cs: return .mint
        case .eng: return .cyan
        case .bio: return .mint
        }
    }
}

