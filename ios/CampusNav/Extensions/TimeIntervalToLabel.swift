//
//  TimeIntervalToText.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 8/3/25.
//
import SwiftUI

// Converts time interval to readable labels
func timeIntervalToLabel(_ interval: TimeInterval) -> String {
    let totalMinutes = Int(interval) / 60
    let h = totalMinutes / 60
    let m = totalMinutes % 60
    
    if h > 0 {
        return "\(h)h \(m)m"
    } else if m > 0 {
        return "\(m)m"
    } else {
        return ""
    }
}
