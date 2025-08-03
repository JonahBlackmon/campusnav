//
//  LocationSearch.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/29/25.
//
import SwiftUI

struct LocationSearch: View {
    @Binding var eventSearchText: String
    @State var displayBuildings: [Building] = []
    @FocusState.Binding var locationSearchFocus: Bool
    @Binding var selectedBuilding: Building?
    @EnvironmentObject var buildingVM: BuildingViewModel
    @EnvironmentObject var settingsManager: SettingsManager
    var body: some View {
        ZStack() {
            settingsManager.primaryColor.opacity(0.001)
                .ignoresSafeArea()
                .transition(.opacity)
                .onTapGesture {
                    locationSearchFocus = false
                }
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(
                        Array(displayBuildings.enumerated()), id: \.element.id) { index, building in
                            SearchItem(
                                building: building,
                                index: index,
                                onSelect: {
                                    locationSearchFocus = false
                                    selectedBuilding = building
                                }
                            )
                            .environmentObject(settingsManager)
                        }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .onChange(of: eventSearchText) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if !eventSearchText.isEmpty {
                        displayBuildings = buildingVM.searchBuilding(matching: eventSearchText)
                    } else {
                        displayBuildings = []
                    }
                }
            }
        }
    }
}

struct LocationSearchButton: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @FocusState.Binding var locationSearchFocus: Bool
    @Binding var isEventSearching: Bool
    @Binding var eventSearchText: String
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.4)) {
                isEventSearching = true
                locationSearchFocus = true
            }
        } label: {
            HStack(spacing: 20) {
                ZStack {
                    LocationSearchButtonLabel
                        .padding(.horizontal, 16)
                }
                .frame(height: 50)
                .foregroundColor(settingsManager.accentColor)
            }
        }
    }
    
    private var LocationSearchButtonLabel: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
            TextField(
                "",
                text: $eventSearchText,
                prompt: Text("Choose a location")
                    .font(.system(size: 14))
                    .foregroundColor(settingsManager.accentColor.opacity(0.8))
            )
            .multilineTextAlignment(.leading)
            .focused($locationSearchFocus)
        }
    }
}
