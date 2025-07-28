//
//  HeaderViewModel.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/27/25.
//
import SwiftUI

class HeaderViewModel: ObservableObject {
    @Published var animateFavorites: Bool = false
    @Published var animateSettings: Bool = false
    @Published var showSettings: Bool = false
    @Published var showFavorites: Bool = false
    @Published var searchText: String = ""
//    @FocusState var searchFocused: Bool
    
    func ExitHeader(navState: NavigationUIState, searchFocused: FocusState<Bool>.Binding) {
        withAnimation(.easeInOut(duration: 0.3)) {
            navState.isSearching = false
            showSettings = false
            animateSettings = false
            animateFavorites = false
            showFavorites = false
//            searchFocused = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.searchText = ""
        }
    }
}
