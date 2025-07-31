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
            .padding(.leading)
            .padding(.trailing)
        }
    }
}

struct TimeSelector: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var time: Date
    var body: some View {
        DatePicker("Select Time", selection: $time, displayedComponents: .hourAndMinute)
            .datePickerStyle(.compact)
            .labelsHidden()
            .tint(settingsManager.accentColor)
            .background(Color.brightOrange.opacity(0.5))
            .cornerRadius(8)
    }
}



struct CompactDateSelector: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var date: Date
    var body: some View {
        DatePicker("", selection: $date, displayedComponents: .date)
            .datePickerStyle(.compact)
            .labelsHidden()
            .tint(settingsManager.accentColor)
            .background(Color.brightOrange.opacity(0.5))
            .cornerRadius(8)
    }
}
