//
//  Direction.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/26/25.
//
import Foundation

// Used for display purposes to correlate distance with images
enum WalkingDirection: Equatable {
    case forward, backward, left, right
    var description: String {
        switch self {
        case .forward: return "arrow.turn.right.up"
        case .backward: return "arrow.uturn.down"
        case .left: return "arrow.turn.up.left"
        case .right: return "arrow.turn.up.right"
        }
    }
}

struct DirectionStep: Equatable, Identifiable {
    var id = UUID()
    let label: String
    let distance: String
    let direction: WalkingDirection?
}
