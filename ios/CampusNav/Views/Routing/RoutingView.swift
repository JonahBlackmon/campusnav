//
//  RoutingView.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/27/25.
//
import SwiftUI

struct RoutingTop: View {
    @State var expanded: Bool = false
    @State var test: [Int] = Array(repeating: 1, count: 300)
    @State var sheetHeight: CGFloat = collapsedHeight
    @EnvironmentObject var navigationVM: NavigationViewModel
    @EnvironmentObject var settingsManager: SettingsManager
    var body: some View {
        TopSheetView(sheetHeight: $sheetHeight, expanded: $expanded, content:
            ZStack(alignment: .bottom) {
                directionsList
                if !expanded {
                    Capsule()
                        .fill(settingsManager.textColor)
                        .frame(width: 50, height: 5)
                        .padding(.bottom, 5)
                }
                
                settingsManager.primaryColor
                    .frame(height: sheetHeight / 2)
                    .mask(
                        LinearGradient(
                            colors: [.black, .clear],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .allowsHitTesting(false)
                    .opacity(sheetHeight > UIScreen.main.bounds.height * 0.4 ? 1 : 0)
                Image(systemName: "chevron.compact.up")
                .foregroundStyle(settingsManager.textColor)
                    .font(.system(size: 50))
                    .padding()
                    .opacity(sheetHeight > UIScreen.main.bounds.height * 0.4 ? 1 : 0)
            }
            .transition(.move(edge: .top))
        )
    }
    private var directionsList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(Array(navigationVM.directions.enumerated()), id: \.offset) { index, direction in
                        DirectionStepView(
                            directionIcon: direction.direction?.description ?? "",
                            directionDescription: direction.label,
                            distance: direction.distance
                        )
                    }
                }
                .onChange(of: expanded) {
                    if !expanded {
                        withAnimation(.easeIn(duration: 0.1)) {
                            proxy.scrollTo(0, anchor: .top)
                        }
                    }
                }
            }
            .scrollDisabled(!expanded)
            .padding(.top, 70)
            .frame(height: sheetHeight)
            .frame(maxWidth: .infinity)
            .background(settingsManager.primaryColor)
        }
    }
}

struct RoutingBottom: View {
    @EnvironmentObject var navigationVM: NavigationViewModel
    @EnvironmentObject var settingsManager: SettingsManager
    var resetData: () -> Void
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        return df
    }()
    var arrivalDate: Date { Date().addingTimeInterval(navigationVM.distance / 1.3) }
    @State var expanded: Bool = false
    var body: some View {
        BottomSheetView(expanded: $expanded, content:
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("\((10 * Int(distance / 10))) m")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(settingsManager.textColor)
                        HStack {
                            Image(systemName: "figure.walk")
                            Text(meters_to_time(meters: distance))
                        }
                        .font(.system(size: 20))
                        .foregroundStyle(settingsManager.textColor.opacity(0.7))
                    }
                    .padding()
                    
                    Spacer()
                    
                    VStack {
                        Text("\(dateFormatter.string(from: arrivalDate))")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(settingsManager.textColor)
                        Text("Arrival")
                            .font(.system(size: 20))
                            .foregroundStyle(settingsManager.accentColor.opacity(0.7))
                    }
                    
                    Spacer()
                    Button {
                        withAnimation(.easeOut(duration: 0.3)) {
                            expanded.toggle()
                        }
                    } label: {
                        Image(systemName: "chevron.up.circle.fill")
                            .font(.system(size: 25))
                            .foregroundStyle(settingsManager.textColor.opacity(0.7))
                            .rotationEffect(expanded ? Angle(degrees: 180) : Angle(degrees: 0))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, expanded ? 0 : 10)
                if expanded {
                    EndRouteButton(resetData: resetData)
                }
            }
            .background(settingsManager.primaryColor)
            .frame(maxWidth: .infinity)
            .animation(.easeOut(duration: 0.3), value: expanded)
            .transition(.move(edge: .bottom))
        )
    }
}
