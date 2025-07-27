//
//  DirectionView.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/21/25.
//
import SwiftUI

struct DirectionView: View {
    @Binding var directions: [DirectionStep]
    @Binding var showDirections: Bool
    var body: some View {
        VStack {
            VStack {
                HStack(spacing: 20) {
                    Image(systemName: directions[0].direction?.description ?? "")
                    Text(directions[0].label)
                }
                .padding()
                .font(.title2)
                .fontWeight(.black)
                .foregroundStyle(.offWhite)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                Divider()
                    .frame(width: 50, height: 2)
                    .overlay(.offWhite)
                    .padding(.bottom, 5)
                    .cornerRadius(1)
            }
            .padding(.top, 75)
            .background(.burntOrange)
            .shadow(color: .black.opacity(1), radius: 5)
            .ignoresSafeArea()
            Spacer()
        }
    }
}


struct DirectionItem: View {
    let step: DirectionStep
    var body: some View {
        Text("Hello World!")
    }
}
