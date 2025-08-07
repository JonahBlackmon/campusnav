//
//  FiltersView.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 8/1/25.
//
import SwiftUI

/*
    Filter and tag are used interchangebly, filters are used in the filter view,
    tags are used during event creation
 */

struct AddTags: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var selectedTags: Set<EventTag>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(EventTag.allCases) { tag in
                    Tag(tag: tag, isSelected: selectedTags.contains(tag)) {
                        if selectedTags.contains(tag) {
                            selectedTags.remove(tag)
                        } else {
                            selectedTags.insert(tag)
                        }
                    }
                    .environmentObject(settingsManager)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
        }
    }
}


struct Tag: View {
    let tag: EventTag
    let isSelected: Bool
    let onTap: () -> Void

    @State private var animate: Bool = false
    @EnvironmentObject var settingsManager: SettingsManager

    var body: some View {
        Button {
            onTap()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                animate = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.bouncy()) {
                    animate = false
                }
            }
        } label: {
            VStack {
                Text(tag.rawValue)
                    .font(.caption)
                    .font(.system(size: 15))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
            }
            
            .foregroundColor(settingsManager.textColor.opacity(0.7))
            .background(isSelected ? settingsManager.darkMode ? tag.color.opacity(0.8) : tag.color.opacity(0.2) : settingsManager.textColor.opacity(0.1))
            .clipShape(Capsule())
            .scaleEffect(animate ? 1.15 : 1.0)
        }
    }
}

struct FilterIcon: View {
    let tag: EventTag
    let isSelected: Bool
    let onTap: () -> Void

    @State private var animate: Bool = false
    @EnvironmentObject var settingsManager: SettingsManager

    var body: some View {
        Button {
            onTap()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                animate = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.bouncy()) {
                    animate = false
                }
            }
        } label: {
            VStack {
                Text(tag.rawValue)
                    .font(.caption)
                    .font(.system(size: 15))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
            }
            .frame(width: 80)
            .foregroundColor(settingsManager.textColor.opacity(0.7))
            .background(isSelected ? settingsManager.darkMode ? tag.color.opacity(0.8) : tag.color.opacity(0.2) : settingsManager.textColor.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .scaleEffect(animate ? 1.15 : 1.0)
        }
    }
}

struct TagIcon: View {
    @EnvironmentObject var settingsManager: SettingsManager
    let tag: EventTag
    
    var body: some View {
        VStack {
            Text(tag.rawValue)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
        }
        
        .foregroundColor(settingsManager.textColor.opacity(0.7))
        .background(settingsManager.darkMode ? tag.color.opacity(0.8) : tag.color.opacity(0.2))
        .clipShape(Capsule())
    }
}

struct FilterButton: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var showFilters: Bool
    var body: some View {
        Button {
            showFilters = true
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 30))
                .foregroundStyle(settingsManager.accentColor)
        }
    }
}

struct FilterView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var eventVM: EventViewModel
    let columns = [
        GridItem(.adaptive(minimum: 80), spacing: 4)
        ]
    var body: some View {
        VStack(alignment: .leading) {
            HeaderText(text: "Select Filters")
                .environmentObject(settingsManager)
            LazyVGrid(columns: columns) {
                ForEach(EventTag.allCases) { tag in
                    FilterIcon(tag: tag, isSelected: eventVM.selectedFilters.contains(tag)) {
                        if eventVM.selectedFilters.contains(tag) {
                            eventVM.selectedFilters.remove(tag)
                        } else {
                            eventVM.selectedFilters.insert(tag)
                        }
                    }
                    .environmentObject(settingsManager)
                }
            }
            .padding()
            Spacer()
        }
    }
}
