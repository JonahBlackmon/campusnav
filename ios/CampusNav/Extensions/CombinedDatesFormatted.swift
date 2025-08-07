//
//  CombinedDatesFormatted.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/30/25.
//
import SwiftUI

// Used in event creator. Formats date to day of week & time
func combinedDatesFormatted(days: Set<DateComponents>, time: Date) -> [String] {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone.current

    let timeComponents = calendar.dateComponents([.hour, .minute], from: time)

    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE h:mm a"
    formatter.locale = Locale(identifier: "en_US")

    let formattedDates = days.compactMap { dayComponents in
        var combined = dayComponents
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute

        if let finalDate = calendar.date(from: combined) {
            return formatter.string(from: finalDate)
        } else {
            return nil
        }
    }
    return Array(Set(formattedDates)).sorted()
}

// Combines the date and the time it takes place on
func combinedDateTimeFormatted(day: Date, time: Date) -> ([String], [Date]) {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone.current

    let dateComponents = calendar.dateComponents([.year, .month, .day], from: day)
    let timeComponents = calendar.dateComponents([.hour, .minute], from: time)

    var combinedComponents = DateComponents()
    combinedComponents.year = dateComponents.year
    combinedComponents.month = dateComponents.month
    combinedComponents.day = dateComponents.day
    combinedComponents.hour = timeComponents.hour
    combinedComponents.minute = timeComponents.minute

    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE h:mm a"
    formatter.locale = Locale(identifier: "en_US")

    if let finalDate = calendar.date(from: combinedComponents) {
        return ([formatter.string(from: finalDate)], [finalDate])
    } else {
        return ([], [])
    }
}
