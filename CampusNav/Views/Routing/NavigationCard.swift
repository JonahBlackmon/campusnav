//
//  NavigationCard.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/15/25.
//
import SwiftUI

struct FavoritesButton: View {
    @EnvironmentObject var settingsManager: SettingsManager
    let building: Building
    var favoritedBuilding: Bool {
        return settingsManager.favorites[building.abbr] != nil
    }
    var body: some View {
        Button {
            settingsManager.writeFavorites(building, abbr: building.abbr)
        } label: {
            Image(systemName: favoritedBuilding ? "star.fill" : "star")
        }
    }
}

struct BuildingImageView: View {
    @EnvironmentObject var buildingVM: BuildingViewModel
    
    var imageURL: URL? {
        URL(string: buildingVM.url())
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
    @EnvironmentObject var navState: NavigationUIState
    var body: some View {
        Button {
            navState.showNavigationCard = false
            navState.isNavigating = true
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
    let collegePrimary: Color = .burntOrange
    let collegeSecondary: Color = .offWhite
    @State var displayTime: String = ""
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var buildingVM: BuildingViewModel
    @EnvironmentObject var navigationVM: NavigationViewModel
    @EnvironmentObject var navState: NavigationUIState
    var favoritedBuilding: Bool {
        return settingsManager.favorites[buildingVM.url()] != nil
    }
    var body: some View {
        ScrollView {
            VStack {
                BuildingImageView()
                    .environmentObject(buildingVM)
                    .shadow(color: .black.opacity(0.3), radius: 20)
                    .frame(height: 305)
                VStack(alignment: .center) {
                    HStack {
                        Text(buildingVM.name())
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                        FavoritesButton(building: buildingVM.selectedBuilding ?? Building(abbr: "", name: "", photoURL: ""))
                            .environmentObject(settingsManager)
                    }
                    .zIndex(1)
                    HStack {
                        Image(systemName: "figure.walk")
                        Text(displayTime)
                        Spacer()
                    }
                    .frame(alignment: .leading)
                    NavigateButton(collegeSecondary: collegeSecondary, collegePrimary: collegePrimary)
                        .environmentObject(navState)
                }
                .frame(maxWidth: 300)
                .foregroundStyle(collegeSecondary)
                .padding()
                .onChange(of: distance) {
                    displayTime = meters_to_time(meters: navigationVM.distance)
                }
            }
        }
        .ignoresSafeArea()
    }
}
