//
//  TimeFormatter.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/18/25.
//

func meters_to_time(meters: Double) -> String {
    let seconds = Int(meters / 1.3)
    switch seconds {
    case 0..<60 :
        return seconds <= 1 ? "\(seconds) second" : "\(seconds) seconds"
    case 60..<3600:
        return seconds <= 60 ? "\(seconds / 60) minute" : "\(seconds / 60) minutes"
    case 3600..<86400:
        return seconds / 3600 <= 1 ? "\(seconds / 3600) hour" : "\(seconds / 3600) hours"
    case 86400..<604800:
        return seconds / 86400 <= 1 ? "\(seconds / 86400) day" : "\(seconds / 86400) days"
    case 604800:
        return "Too long bro"
    default:
        return "Where are you going?"
    }
}
