//
//  CombinedDatesFormatted.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/30/25.
//
import SwiftUI

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
