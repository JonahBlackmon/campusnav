//
//  ArrivalScreen.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/26/25.
//
import SwiftUI

struct ArrivalScreen: View {
    var destAbbr: String
    var destinationName: String
    var photoURL: String
    let collegePrimary: Color = .burntOrange
    let collegeSecondary: Color = .offWhite
    @Binding var showArrival: Bool
    @State private var isVisible: Bool = false
    
    var body: some View {
        ZStack {
            collegePrimary
            HStack(spacing: 5) {
                BuildingImageView(buildingAbbr: destAbbr, selectedPhotoURL: photoURL)
                    .shadow(color: .black.opacity(0.3), radius: 20)
                    .frame(width: 30, height: 30)
                    .cornerRadius(4)
                VStack(alignment: .center) {
                    HStack {
                        Text("You have arrived at \(destinationName)!")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .zIndex(1)
                }
                .foregroundStyle(collegeSecondary)
            }
        }
        .frame(maxWidth: 325, maxHeight: 75)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.3), radius: 5)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .offset(y: isVisible ? 0 : -150)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                isVisible = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                dismissView()
            }
        }
    }
    
    private func dismissView() {
        withAnimation(.easeInOut(duration: 0.5)) {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            showArrival = false
        }
    }
}

//struct tempNotifView: View {
//    @State var showing: Bool = false
//    var body: some View {
//        ZStack {
//            Button {
//                withAnimation(.easeInOut(duration: 0.7)) {
//                    showing.toggle()
//                }
//            } label: {
//                Text("Toggle Notification")
//            }
//            if showing {
//                ArrivalScreen(destAbbr: "KIN", destinationName: "Kinsolving", photoURL: "https://utdirect.utexas.edu/apps/campus/buildings/static/information/nlogon/imgs/utbuildings/main/GDC/100541705_400.jpg", showArrival: .constant(true))
//            }
//        }
//    }
//}
//
//#Preview {
//    tempNotifView()
//}
