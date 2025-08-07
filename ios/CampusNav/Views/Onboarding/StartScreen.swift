//
//  StartScreen.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 8/7/25.
//
import SwiftUI

struct StartScreen: View {
    @Binding var started: Bool
    @State private var activeImageIndex = 0
    let images: [BGImage] = [
        .init(image: "BGImage1"),
        .init(image: "BGImage2"),
        .init(image: "BGImage3"),
    ]
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            ambientBackground()
                .mask(
                    Image("LocationPin.fill")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                    )
                .frame(width: 200, height: 200)
                .padding(.bottom, 50)
            Text("Welcome to")
                .fontWeight(.semibold)
                .foregroundStyle(.black.secondary)
            Text("CampusNav")
                .font(.largeTitle.bold())
                .foregroundStyle(.charcoal)
                .padding(.bottom, 12)
            Text("A better way to get to know your college campus and classmates")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(.black.secondary)
                .padding(.horizontal)
            Button {
                started = true
            } label: {
                Text("Choose College")
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 12)
                    .background(.charcoal, in: .capsule)
            }
            .padding(.vertical)
        }
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 1.0)) {
                activeImageIndex = (activeImageIndex + 1) % images.count
            }
        }
        .safeAreaPadding(15)
    }
    
    @ViewBuilder private func ambientBackground() -> some View {
        GeometryReader { geo in
            ZStack {
                ForEach(Array(images.enumerated()), id: \.element.id) { index, image in
                    Image(image.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .opacity(activeImageIndex == index ? 1 : 0)
                        .animation(.easeInOut(duration: 1.0), value: activeImageIndex)
                        .ignoresSafeArea()
                }
                Rectangle()
                    .fill(Color.black.opacity(0.45))
                    .ignoresSafeArea()
            }
            .compositingGroup()
            .blur(radius: 90, opaque: true)
        }
    }
}
