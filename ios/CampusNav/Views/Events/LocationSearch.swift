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
    var collegePrimary: Color
    @Binding var selectedBuilding: Building?
    @EnvironmentObject var buildingVM: BuildingViewModel
    var body: some View {
        ZStack() {
            Color.offWhite.opacity(0.001)
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
                                collegePrimary: collegePrimary,
                                index: index,
                                onSelect: {
                                    locationSearchFocus = false
                                    selectedBuilding = building
                                },
                                tintColor: .offWhite
                            )
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
    @FocusState.Binding var locationSearchFocus: Bool
    @Binding var isEventSearching: Bool
    @Binding var eventSearchText: String
    let collegePrimary: Color
    let collegeSecondary: Color
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.4)) {
                isEventSearching = true
                locationSearchFocus = true
            }
        } label: {
            HStack(spacing: 20) {
                ZStack {
                    collegePrimary
                    LocationSearchButtonLabel
                        .padding(.horizontal, 16)
                }
                .frame(height: 50)
                .cornerRadius(24)
                .foregroundColor(collegeSecondary)
            }
        }
    }
    
    private var LocationSearchButtonLabel: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
            TextField(
                "",
                text: $eventSearchText,
                prompt: Text("Search for a location")
                    .foregroundColor(.offWhite.opacity(0.8))
                    .italic()
            )
            .multilineTextAlignment(.leading)
            .focused($locationSearchFocus)
        }
    }
}

//#Preview {
//    LocationSearch()
//}
