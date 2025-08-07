//
//  GetStarted.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 8/7/25.
//
import SwiftUI

struct GetStarted: View {
    @EnvironmentObject var settingsManager: SettingsManager
    var accentColor: Color
    @Binding var tac: Bool
    @Binding var isOnboarded: Bool
    @State var showEventError: Bool = false
    var id: String
    var body: some View {
        VStack {
            Button {
                if tac {
                    print("CollegeID: \(id)")
                    UserDefaults.standard.set(id, forKey: "collegeID")
                    isOnboarded = true
                } else {
                    showEventError = true
                }
            } label: {
                VStack {
                    Text("Get Started")
                        .font(.system(size: 25))
                        .fontWeight(.bold)
                        .padding()
                        .foregroundStyle(accentColor)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(settingsManager.darkMode ? .charcoal : .offWhite)
                .cornerRadius(12)
                .padding()
            }
            .padding()
        }
        .alert("Error", isPresented: $showEventError) {
            Button("OK") { }
        } message: {
            Text("Must accept Terms and Conditions to proceed.")
        }
    }
}
