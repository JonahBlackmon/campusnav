//
//  InputField.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/30/25.
//
import SwiftUI

struct InputField: View {
    @Binding var textField: String
    var placeHolderText: String
    var collegeSecondary: Color
    var body: some View {
        VStack {
            TextField(
                "",
                text: $textField,
                prompt: Text(placeHolderText)
                    .foregroundColor(.offWhite.opacity(0.8))
                    .italic()
            )
            .padding()
            .background(collegeSecondary.opacity(0.3))
            .cornerRadius(12)
        }
    }
}
