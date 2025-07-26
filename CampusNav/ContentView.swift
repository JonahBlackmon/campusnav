//
//  ContentView.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/12/25.
//

import SwiftUI
import MapKit
import CoreLocation

class NavigationState: ObservableObject {
    @Published var currentView: String = "record"
}

struct ContentView: View {
    @State var coordinates: [CLLocationCoordinate2D] = []
    @StateObject var navigationState = NavigationState()
    @State var refreshTrigger: UUID = UUID()
    @State var isRefreshing: Bool = false
    @State private var showNavigationCard = false
    @State private var selectedBuildingAbbr: String = ""
    @State private var selectedDestinationName: String = ""
    @State var selectedPhotoURL: String = ""
    @State private var navigateToAbbr: Bool = false
    @State private var displayNav: Bool = false
    @State private var distance: Double = -1.0
    var collegePrimary: Color {
       return settingsManager.collegePrimary
    }
    var collegeSecondary: Color {
       return settingsManager.collegeSecondary
    }
    @State var isSearching: Bool = false
    @State var navigating: Bool = false
    @State var coordinate_nodes: [Node] = []
    @State var directions: [DirectionStep] = []
    @State var displayDistance: Double = -1.0
    @State var ReRouteTimer: Timer? = nil
    @State var navigatingBuilding: String = ""
    @State var navigatingName: String = ""
    @State var navigatingURL: String = ""
    @State var proximityTimer: Timer? = nil
    @State var toggleArrival: Bool = false
    @State var showArrival: Bool = false
    @EnvironmentObject var buildingManager: BuildingManager
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var directionManager: DirectionManager
    var body: some View {
        ZStack(alignment: .top) {
            mainContentView
            ZStack {
                if navigating {
                    TopSheetView(isShowing: $navigating, directions: $directions)
                        .transition(.move(edge: .top))
                    BottomSheetView(isShowing: $navigating, resetData: resetData, distance: $distance)
                        .transition(.move(edge: .bottom))
                }
            }
            .animation(.spring(duration: 0.3), value: navigating)
            if showArrival {
                ArrivalScreen(destAbbr: navigatingBuilding, destinationName: navigatingName, photoURL: navigatingURL, showArrival: $showArrival)
            }
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showNavigationCard) {
            ZStack {
                collegePrimary.edgesIgnoringSafeArea(.all)
                NavigationCard(building_abbr: selectedBuildingAbbr, destination_name: selectedDestinationName, selectedPhotoURL: selectedPhotoURL, navigate: $navigateToAbbr, displayNav: $displayNav, distance: $displayDistance)
                    .presentationDetents([.fraction(0.6)])
            }
        }
        .onChange(of: selectedBuildingAbbr) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if showNavigationCard {
                    updateCard()
                } else {
                    displayNav = false
                }
            }
        }
        .onChange(of: navigateToAbbr) {
            if navigateToAbbr {
                navigationLogic(destinationAbbr: selectedBuildingAbbr, destinationName: selectedDestinationName, destinationURL: selectedPhotoURL)
                withAnimation(.easeOut(duration: 0.3)) {
                    navigating = true
                }
            }
        }
        .onChange(of: showNavigationCard) {
            if !showNavigationCard {
                selectedBuildingAbbr = ""
                selectedPhotoURL = ""
                selectedDestinationName = ""
                displayDistance = distance
            }
        }
        .onChange(of: navigating) {
            if navigating {
                proximityTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
                    proximityCheck()
                }
            } else {
                proximityTimer?.invalidate()
                proximityTimer = nil
            }
        }
        .onChange(of: toggleArrival) {
            showArrival = true
        }
    }
    
    
    
//    private var changeLocation: some View {
//        VStack {
//            Button {
//                currentLocation = CLLocationCoordinate2D(latitude: 30.286, longitude: -97.737051)
//            } label: {
//                Text("Change Location?")
//            }
//        }
//    }
    
//    private var directionView: some View {
//        VStack {
//            Text("Current angle: \(directionManager.currentDirection ?? -1.0)")
//        }
//        .frame(width: 200, height: 200)
//        .background(.offWhite)
//        .cornerRadius(12)
//    }
    
//    private var colorButton: some View {
//        Button {
//            settingsManager.updateCollegeColors(collegePrimary: "burntOrange", collegeSecondary: "offWhite")
//        } label: {
//            Text("Change Color")
//                .frame(width: 300, height: 300)
//                .background(Color.white)
//        }
//    }
    
//    private var favoritesCard: some View {
//        VStack {
//            List {
//                ForEach(Array(settingsManager.favorites.keys), id: \.self) { key in
//                    Text(key)
//                }
//            }
//            Button {
//                let building = Building(abbr: "KIN", name: "Kinsolving Residence Hall", photoURL: "")
//                settingsManager.writeFavorites(building, abbr: "KIN")
//            } label: {
//                Text("Add KIN to list")
//            }
//        }
//        .frame(width: 200, height: 200)
//        .background(Color.white)
//    }
    
//    private var current_coord: some View {
//        ZStack {
//            Text("\(directionManager.currentLocation?.latitude), \(directionManager.currentLocation?.longitude)")
//        }
//        .background(.black)
//        .cornerRadius(12)
//        .foregroundStyle(.offWhite)
//    }
    
//    private var toggle_arrival: some View {
//        ZStack {
//            Button {
//                toggleArrival.toggle()
//                resetData()
//            } label: {
//                Text("Toggle Arrival?")
//            }
//        }
//    }
    
    func resetData() {
        withAnimation(.easeOut(duration: 0.3)) {
            coordinates = []
            directions = []
            navigating = false
            selectedBuildingAbbr = ""
            selectedDestinationName = ""
            selectedPhotoURL = ""
            displayNav = false
            distance = -1.0
        }
    }
    
    private func updateCard() {
        if directionManager.currentLocation?.longitude != nil && directionManager.currentLocation?.latitude != nil {
            let (tempCoords, tempNodes, newDistance) = find_route(lat: directionManager.currentLocation!.latitude, lng: directionManager.currentLocation!.longitude, dest_abbr: selectedBuildingAbbr)
            self.displayDistance = newDistance
            showNavigationCard = true
            displayNav = true
        }
    }
    
    private func navigationLogic(destinationAbbr: String, destinationName: String, destinationURL: String) {
        if directionManager.currentLocation?.longitude != nil && directionManager.currentLocation?.latitude != nil {
            navigatingBuilding = destinationAbbr
            navigatingName = destinationName
            navigatingURL = destinationURL
            (coordinates, coordinate_nodes, distance) = find_route(lat: directionManager.currentLocation!.latitude, lng: directionManager.currentLocation!.longitude, dest_abbr: destinationAbbr)
            showNavigationCard = false
            selectedBuildingAbbr = ""
            selectedDestinationName = ""
            selectedPhotoURL = ""
            navigateToAbbr = false
        }
    }
    
    // Check the proximity of current location to the destination node, re routing if necessary
    private func proximityCheck() {
        if directionManager.currentLocation?.longitude != nil && directionManager.currentLocation?.latitude != nil {
            if coordinates.count > 1 {
                let start = Coordinate(latitude: coordinates[0].latitude, longitude: coordinates[0].longitude)
                let end = Coordinate(latitude: coordinates[1].latitude, longitude: coordinates[1].longitude)
                let cL = Coordinate(latitude: directionManager.currentLocation!.latitude, longitude: directionManager.currentLocation!.longitude)
                print("Current distance from next coord \(haversine(a: end, b: cL))")
                print("Current distance from path \(distance_to_path(pos: cL, start: start, end: end))")
                if haversine(a: end, b: cL) < 5 {
                    if coordinates[1] == coordinates.last {
                        // We are at the final destination, stop routing
                        toggleArrival.toggle()
                        resetData()
                    }
                    // We are at the destination
                    (coordinates, coordinate_nodes, distance) = find_route(lat: cL.latitude, lng: cL.longitude, dest_abbr: navigatingBuilding)
                } else if distance_to_path(pos: cL, start: start, end: end) > 10 {
                    // Strayed to far from path, need to re route
                    (coordinates, coordinate_nodes, distance) = find_route(lat: cL.latitude, lng: cL.longitude, dest_abbr: navigatingBuilding)
                }
            }
        }
    }
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(tabItems, id: \.0) { tab in
                tabButton(for: tab)
            }
        }
        .background(collegePrimary)
        .animation(.easeInOut(duration: 0.2), value: navigationState.currentView)
        .ignoresSafeArea(edges: .bottom)
        .frame(height: 30)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .offset(y: isSearching || navigating ? 200 : 0)
        .animation(.easeInOut(duration: 0.3), value: isSearching)
    }

    private var tabItems: [(String, String)] {
        [
            ("record", "mic.fill"),
            ("explore", "house.fill"),
            ("profile", "book.fill")
        ]
    }

    private func tabButton(for tab: (String, String)) -> some View {
        Button(action: {
            handleTabTap(tab.0)
        }) {
            ZStack {
                tabButtonBackground(for: tab.0)
                tabButtonIcon(tab.1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.5), trigger: navigationState.currentView)
    }

    @ViewBuilder
    private func tabButtonBackground(for tabName: String) -> some View {
        if navigationState.currentView == tabName {
            RoundedRectangle(cornerRadius: 20)
                .fill(collegeSecondary.opacity(0.3))
                .frame(width: 75, height: 40)
                .transition(.horizontalGrow)
        }
    }

    private func tabButtonIcon(_ iconName: String) -> some View {
        Image(systemName: iconName)
            .font(.system(size: 20))
            .foregroundColor(collegeSecondary)
    }
    
    private func handleTabTap(_ tabName: String) {
        if navigationState.currentView == tabName {
            withAnimation(.easeInOut(duration: 0.1)) {
                isRefreshing = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                refreshTrigger = UUID()
                withAnimation(.easeInOut(duration: 0.1)) {
                    isRefreshing = false
                }
            }
        } else {
            withAnimation(.easeInOut(duration: 0.1)) {
                navigationState.currentView = tabName
            }
        }
    }
    
    private var contentArea: some View {
        currentViewContent
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .id(refreshTrigger)
    }
    
    @ViewBuilder
    private var currentViewContent: some View {
        switch navigationState.currentView {
        case "record", "explore":
            MapView(coordinates: $coordinates, showNavigationCard: $showNavigationCard, selectedBuildingAbbr: $selectedBuildingAbbr, selectedDestinationName: $selectedDestinationName, selectedPhotoURL: $selectedPhotoURL, navigating: $navigating, coordinate_nodes: $coordinate_nodes, directions: $directions)
                .ignoresSafeArea()
                .preferredColorScheme(.light)
                .environmentObject(directionManager)
        case "profile":
            Text("Hello World")
        default:
            MapView(coordinates: $coordinates, showNavigationCard: $showNavigationCard, selectedBuildingAbbr: $selectedBuildingAbbr, selectedDestinationName: $selectedDestinationName, selectedPhotoURL: $selectedPhotoURL, navigating: $navigating, coordinate_nodes: $coordinate_nodes, directions: $directions)
                .ignoresSafeArea()
                .preferredColorScheme(.light)
                .environmentObject(directionManager)
        }
    }
    
    private var mainContentView: some View {
        ZStack() {
            contentArea
            if !directions.isEmpty {
                
            }
            HeaderView(searchingView: $isSearching, routing: $navigating, collegePrimary: collegePrimary, collegeSecondary: collegeSecondary, showNavigationCard: $showNavigationCard, selectedBuildingAbbr: $selectedBuildingAbbr, selectedDestinationName: $selectedDestinationName, selectedPhotoURL: $selectedPhotoURL)
                .environmentObject(buildingManager)
                .environmentObject(settingsManager)
            customTabBar
        }
    }
    
}

struct HorizontalGrow: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(x: isActive ? 1 : 0.6, y: 1, anchor: .center)
            .opacity(isActive ? 1 : 0)
    }
}

extension AnyTransition {
    static var horizontalGrow: AnyTransition {
        .modifier(
            active: HorizontalGrow(isActive: false),
            identity: HorizontalGrow(isActive: true)
        )
    }
}


//#Preview {
//    ContentView()
//}
