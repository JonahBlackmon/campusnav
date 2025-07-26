//
//  NavigationCard.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/15/25.
//
import SwiftUI

//struct NavigationCard: View {
//    let building_abbr: String
//    let destination_name: String
//    let selectedPhotoURL: String
//    let collegePrimary: Color = .burntOrange
//    let collegeSecondary: Color = .offWhite
//    @State var displayTime: String = ""
//    @EnvironmentObject var settingsManager: SettingsManager
//    @Binding var navigate: Bool
//    @Binding var displayNav: Bool
//    @Binding var distance: Double
//    var favoritedBuilding: Bool {
//        return settingsManager.favorites[building_abbr] != nil
//    }
//    var body: some View {
//        ScrollView {
//            VStack {
//                BuildingImageView(buildingAbbr: building_abbr, selectedPhotoURL: selectedPhotoURL)
//            }
//            .frame(height: 500)
//            .ignoresSafeArea()
//            VStack(alignment: .center) {
//                HStack {
//                    Text(destination_name)
//                        .font(.system(size: 18, weight: .bold))
//                    Spacer()
//                    FavoritesButton(building_abbr: building_abbr, destination_name: destination_name, selectedPhotoURL: selectedPhotoURL)
//                        .environmentObject(settingsManager)
//                }
//                .zIndex(1)
//                HStack {
//                    Image(systemName: "figure.walk")
//                    Text(displayTime)
//                    Spacer()
//                }
//                .frame(alignment: .leading)
//                NavigateButton(collegeSecondary: collegeSecondary, collegePrimary: collegePrimary, navigate: $navigate)
//            }
//            .frame(maxWidth: 300)
//            .foregroundStyle(collegeSecondary)
//            .padding()
//            .onChange(of: distance) {
//                displayTime = meters_to_time(meters: distance)
//                displayNav = true
//            }
//        }
//    }
//    
//}

struct FavoritesButton: View {
    @EnvironmentObject var settingsManager: SettingsManager
    let building_abbr: String
    let destination_name: String
    let selectedPhotoURL: String
    var favoritedBuilding: Bool {
        return settingsManager.favorites[building_abbr] != nil
    }
    var body: some View {
        Button {
            print("Button tapped for \(building_abbr)")
            let building = Building(abbr: building_abbr, name: destination_name, photoURL: selectedPhotoURL)
            settingsManager.writeFavorites(building, abbr: building_abbr)
        } label: {
            Image(systemName: favoritedBuilding ? "star.fill" : "star")
        }
    }
}

struct BuildingImageView: View {
    let buildingAbbr: String
    let selectedPhotoURL: String

    var imageURL: URL? {
        URL(string: selectedPhotoURL)
    }

    var body: some View {
        if let url = imageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(height: 305)
                        .frame(maxWidth: .infinity)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 305)
                        .frame(maxWidth: .infinity)
                        .clipped()
                case .failure:
                    Image("longhornImage")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 305)
                        .frame(maxWidth: .infinity)
                        .clipped()
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            Image("longhornImage")
                .resizable()
                .scaledToFill()
                .frame(height: 305)
                .frame(maxWidth: .infinity)
                .clipped()
        }
    }
}


struct NavigateButton: View {
    let collegeSecondary: Color
    let collegePrimary: Color
    @Binding var navigate: Bool
    var body: some View {
        Button {
            navigate = true
        } label: {
            VStack {
                Text("Directions")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundStyle(collegePrimary)
            .background(collegeSecondary)
            .cornerRadius(12)
        }
        
    }
}


struct NavigationCard: View {
    let building_abbr: String
    let destination_name: String
    let selectedPhotoURL: String
    let collegePrimary: Color = .burntOrange
    let collegeSecondary: Color = .offWhite
    @State var displayTime: String = ""
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var navigate: Bool
    @Binding var displayNav: Bool
    @Binding var distance: Double
    var favoritedBuilding: Bool {
        return settingsManager.favorites[building_abbr] != nil
    }
    var body: some View {
        ScrollView {
            VStack {
                BuildingImageView(buildingAbbr: building_abbr, selectedPhotoURL: selectedPhotoURL)
                    .shadow(color: .black.opacity(0.3), radius: 20)
                    .frame(height: 305)
                VStack(alignment: .center) {
                    HStack {
                        Text(destination_name)
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                        FavoritesButton(building_abbr: building_abbr, destination_name: destination_name, selectedPhotoURL: selectedPhotoURL)
                            .environmentObject(settingsManager)
                    }
                    .zIndex(1)
                    HStack {
                        Image(systemName: "figure.walk")
                        Text(displayTime)
                        Spacer()
                    }
                    .frame(alignment: .leading)
                    NavigateButton(collegeSecondary: collegeSecondary, collegePrimary: collegePrimary, navigate: $navigate)
                }
                .frame(maxWidth: 300)
                .foregroundStyle(collegeSecondary)
                .padding()
                .onChange(of: distance) {
                    displayTime = meters_to_time(meters: distance)
                    displayNav = true
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview() {
    NavigationCard(building_abbr: "KIN", destination_name: "Kinsolving", selectedPhotoURL: "https://utdirect.utexas.edu/apps/campus/buildings/static/information/nlogon/imgs/utbuildings/main/GDC/100541705_400.jpg", navigate: .constant(false), displayNav: .constant(false), distance: .constant(500))
        .environmentObject(SettingsManager())
}
