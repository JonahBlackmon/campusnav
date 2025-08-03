//
//  DateTimeView.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/30/25.
//
import SwiftUI

struct DateTimeSelector: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var date: Set<DateComponents>
    @Binding var time: Date
    var body: some View {
        VStack(alignment: .leading) {
            Text("Select which days of the week:")
                .fontWeight(.bold)
                .font(.system(size: 15))
                .foregroundStyle(settingsManager.accentColor)
                .padding(.leading)
                .padding(.trailing)
            DateSelector(date: $date)
                .tint(settingsManager.accentColor)
            HStack {
                Text("Select the time of day:")
                    .fontWeight(.bold)
                    .font(.system(size: 15))
                    .foregroundStyle(settingsManager.accentColor)
                    .padding(.leading)
                    .padding(.trailing)
                TimeSelector(time: $time)
            }
        }
    }
}

struct DateSelector: View {
    @Binding var date: Set<DateComponents>
    var body: some View {
        VStack {
            MultiDatePicker(
                "Pick a date",
                selection: $date)
            .colorScheme(.light)
            .padding(.leading)
            .padding(.trailing)
        }
    }
}

struct TimeSelector: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var time: Date
    var body: some View {
        DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
            .colorScheme(settingsManager.darkMode ? .dark : .light)
            .datePickerStyle(.compact)
            .labelsHidden()
            .tint(settingsManager.accentColor)
            .cornerRadius(8)
    }
}

struct DurationSelector: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var time: Date

    var body: some View {
        DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
            .colorScheme(settingsManager.darkMode ? .dark : .light)
            .datePickerStyle(.compact)
            .tint(settingsManager.accentColor)
            .cornerRadius(8)
            .environment(\.locale, Locale(identifier: "en_GB"))
    }
    func formatTime(date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        return String(format: "%02dh %02dm", hour, minute)
    }
}



struct CompactDateSelector: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var date: Date
    var body: some View {
        DatePicker("", selection: $date, displayedComponents: .date)
            .colorScheme(settingsManager.darkMode ? .dark : .light)
            .datePickerStyle(.compact)
            .labelsHidden()
            .tint(settingsManager.accentColor)
            .cornerRadius(8)
    }
}
