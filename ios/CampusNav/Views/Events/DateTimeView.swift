//
//  DateTimeView.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/30/25.
//
import SwiftUI

struct DateTimeSelector: View {
    var collegeSecondary: Color
    @Binding var date: Set<DateComponents>
    @Binding var time: Date
    var body: some View {
        VStack(alignment: .leading) {
            Text("Select which days of the week:")
                .fontWeight(.bold)
                .font(.system(size: 15))
                .foregroundStyle(collegeSecondary)
                .padding(.leading)
                .padding(.trailing)
            DateSelector(date: $date)
                .tint(collegeSecondary)
            HStack {
                Text("Select the time of day:")
                    .fontWeight(.bold)
                    .font(.system(size: 15))
                    .foregroundStyle(collegeSecondary)
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
    @Binding var time: Date
    var body: some View {
        DatePicker("Select Time", selection: $time, displayedComponents: .hourAndMinute)
            .datePickerStyle(.compact)
            .labelsHidden()
            .tint(.burntOrange)
            .background(Color.brightOrange.opacity(0.5))
            .cornerRadius(8)
            .padding(.leading)
            .padding(.trailing)
    }
}
