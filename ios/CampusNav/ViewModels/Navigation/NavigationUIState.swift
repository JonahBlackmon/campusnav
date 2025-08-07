//
//  NavigationUIState.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/27/25.
//
import SwiftUI

// UI State vars to keep track of
class NavigationUIState: ObservableObject {
    @Published var currentView: String = "Map"
    @Published var showNavigationCard = false
    @Published var showArrival = false
    @Published var isNavigating = false
    @Published var isSearching = false
    @Published var events = false
    @Published var settings = false
    @Published var centerLocation = false
}
