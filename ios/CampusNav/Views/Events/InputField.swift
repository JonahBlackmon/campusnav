//
//  InputField.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/30/25.
//
import SwiftUI

struct InputField: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var textField: String
    var placeHolderText: String
    var body: some View {
        VStack {
            TextField(
                "",
                text: $textField,
                prompt: Text(placeHolderText)
                    .foregroundColor(settingsManager.primaryColor.opacity(0.8))
            )
            .padding()
            .background(settingsManager.accentColor.opacity(0.1))
            .cornerRadius(8)
        }
    }
}


struct InputFieldWithDescription: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var textField: String
    var placeHolderText: String
    @Binding var description: String
    @Binding var showDescription: Bool
    @FocusState.Binding var descriptionFocus: Bool
    var body: some View {
        HStack {
            TextField(
                "",
                text: $textField,
                prompt: Text(placeHolderText)
                    .font(.system(size: 14))
                    .foregroundColor(settingsManager.primaryColor.opacity(0.8))
            )
            .padding(.leading)
            AddDescriptionButton(description: $description, showDescription: $showDescription, descriptionFocus: $descriptionFocus)
                .environmentObject(settingsManager)
                .font(.system(size: 12))
        }
        .padding(4)
        .background(settingsManager.accentColor.opacity(0.1))
        .cornerRadius(8)
    }
}

struct AddDescriptionButton: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var description: String
    @Binding var showDescription: Bool
    @FocusState.Binding var descriptionFocus: Bool
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                showDescription.toggle()
                descriptionFocus.toggle()
            }
        } label: {
            Text(description == "" ? "Add description" : "Edit Description")
                .foregroundStyle(settingsManager.accentColor)
                .padding()
                .background(settingsManager.primaryColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.charcoal.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct DescriptionView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var description: String
    @Binding var showDescription: Bool
    @FocusState.Binding var descriptionFocus: Bool
    var body: some View {
        ZStack {
            Color.black.opacity(0.0001)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showDescription = false
                        descriptionFocus = false
                    }
                }
            VStack {
                TextField(
                    "",
                    text: $description
                )
                .focused($descriptionFocus)
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showDescription = false
                        descriptionFocus = false
                    }
                } label: {
                    Text("Save")
                        .foregroundStyle(settingsManager.primaryColor)
                }
            }
            .frame(width: 300, height: 250)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
    }
}
