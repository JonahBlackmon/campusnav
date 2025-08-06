//
//  DateTimeView.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/30/25.
//
import SwiftUI

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
    @Binding var duration: TimeInterval

    private let durationOptions: [(label: String, seconds: TimeInterval)] = {
        var options: [(String, TimeInterval)] = []
        for h in 0..<24 {
            for m in stride(from: 0, to: 60, by: 30) {
                let seconds = TimeInterval(h * 3600 + m * 60)
                let label = h > 0 ? "\(h)h \(m)m" : "\(m)m"
                options.append((label, seconds))
            }
        }
        return options
    }()

    var body: some View {
        Picker("", selection: $duration) {
            ForEach(durationOptions, id: \.seconds) { option in
                Text(option.label)
            }
        }
        .pickerStyle(.menu)
        .labelsHidden()
        .font(.system(size: 15))
        .frame(height: 36)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .tint(settingsManager.accentColor)
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
