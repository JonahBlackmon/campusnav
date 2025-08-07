//
//  CollegeOption.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 8/7/25.
//
import SwiftUI

struct CollegeOption: View {
    @EnvironmentObject var settingsManager: SettingsManager
    let id: String
    @State var url: URL? = nil
    @State var data: Data? = nil
    @State var config: CollegeConfig? = nil
    @State var tapped: Bool = false
    @Binding var collegeSelected: Bool
    @Binding var collegeID: String
    @Binding var accentColorString: String
    var body: some View {
        ZStack {
            if tapped {
                if settingsManager.darkMode {
                    Color.charcoal.ignoresSafeArea()
                } else {
                    Color.offWhite.ignoresSafeArea()
                }
            }
            if config != nil {
                Button {
                    withAnimation(.snappy(duration: 0.3)) {
                        tapped.toggle()
                        collegeSelected.toggle()
                        collegeID = tapped ? config?.name ?? "" : ""
                        accentColorString = tapped ? config?.accentColorString ?? "" : ""
                    }
                } label: {
                    HStack {
                        if tapped {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24))
                                .foregroundStyle(settingsManager.textColor)
                                .padding(.top, 75)
                        }
                        Text(config?.name ?? "")
                            .font(.system(size: tapped ? 24 : 16))
                            .fontWeight(.bold)
                            .foregroundStyle(tapped ? settingsManager.textColor : .offWhite)
                            .padding()
                            .padding(.top, tapped ? 75 : 0)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: tapped ? .infinity : 50, alignment: .top)
                .background(tapped ? colorFromString(colorString: config?.accentColorString ?? "").opacity(0.4) : colorFromString(colorString: config?.accentColorString ?? ""))
                .cornerRadius(25)
                .padding(tapped ? 0 : 30)
                .padding(.horizontal, tapped ? 0 : 30)
                .ignoresSafeArea()
            }
        }
        .onAppear {
            guard let url = Bundle.main.url(forResource: "\(id)Config", withExtension: "json") else {
                    print("File not found: \(id)Config.json")
                    return
                }
                
                do {
                    let data = try Data(contentsOf: url)
                    let decoded = try JSONDecoder().decode(CollegeConfig.self, from: data)
                    self.config = decoded
                    print("Loaded config: \(decoded)")
                } catch {
                    print("Failed to load or decode config: \(error)")
                }
        }
    }
}

