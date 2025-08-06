//
//  HeaderViewModel.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/27/25.
//
import SwiftUI

class HeaderViewModel: ObservableObject {
    @Published var animateFavorites: Bool = false
    @Published var animateLocation: Bool = false
    @Published var showFavorites: Bool = false
    @Published var searchText: String = ""
    
    func ExitHeader(navState: NavigationUIState) -> Bool {
        withAnimation(.easeInOut(duration: 0.3)) {
            navState.isSearching = false
            animateLocation = false
            animateFavorites = false
            showFavorites = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.searchText = ""
        }
        return false
    }
}
