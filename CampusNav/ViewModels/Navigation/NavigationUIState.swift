//
//  NavigationUIState.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/27/25.
//
import SwiftUI

class NavigationUIState: ObservableObject {
    @Published var currentView: String = "record"
    @Published var showNavigationCard = false
    @Published var showArrival = false
    @Published var isNavigating = false
    @Published var isSearching = false
}
