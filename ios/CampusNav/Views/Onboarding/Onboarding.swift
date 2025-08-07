//
//  Onboarding.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 8/6/25.
//
import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var isOnboarded: Bool
    @State var accentColorString: String = ""
    @State var collegeSelected: Bool = false
    @State var collegeID: String = ""
    @State var tac: Bool = false
    @State var started: Bool = false
    let collegeIDs: [String] = ["UTAustin"]
    var body: some View {
        ZStack {
            Color.offWhite.ignoresSafeArea()
            if started {
                VStack {
                    if !collegeSelected {
                        Text("Select Your College")
                            .foregroundStyle(.charcoal)
                            .font(.system(size: 25))
                            .fontWeight(.bold)
                            .padding()
                        Divider()
                            .overlay(.charcoal)
                            .padding(.horizontal)
                    }
                    CollegeOption(id: collegeIDs[0], collegeSelected: $collegeSelected, collegeID: $collegeID, accentColorString: $accentColorString)
                        .environmentObject(settingsManager)
                    if !collegeSelected {
                        Text("More Coming Soon!")
                            .frame(alignment: .center)
                            .font(.callout)
                            .foregroundStyle(.black.secondary)
                            .padding(.top, 100)
                        Spacer()
                    }
                }
                VStack {
                    if collegeSelected {
                        SetupCarousel(tac: $tac, accentColorString: accentColorString, isOnboarded: $isOnboarded, id: collegeIDs[0])
                            .padding(.top, 150)
                            .environmentObject(settingsManager)
                    }
                }
            } else {
                StartScreen(started: $started)
            }
            
        }
    }
}
