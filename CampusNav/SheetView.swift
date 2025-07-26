//
//  SheetView.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/21/25.
//
import SwiftUI

let collapsedHeight: CGFloat = 165
let expandedHeight: CGFloat = UIScreen.main.bounds.height * 0.90

struct TopSheetView: View {
    @Binding var isShowing: Bool
    @State var sheetHeight: CGFloat = collapsedHeight
    @State var expanded: Bool = false
    @State var test: [Int] = Array(repeating: 1, count: 300)
    @State private var startHeight: CGFloat = collapsedHeight
    @Binding var directions: [DirectionStep]
    var body: some View {
        ZStack(alignment: .top){
            if isShowing {
                ZStack(alignment: .bottom) {
                    directionsList
                    if !expanded {
                        Capsule()
                            .fill(.offWhite)
                            .frame(width: 50, height: 5)
                            .padding(.bottom, 5)
                    }
                    
                    Color.burntOrange
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
                        .foregroundStyle(.offWhite)
                        .font(.system(size: 50))
                        .padding()
                        .opacity(sheetHeight > UIScreen.main.bounds.height * 0.4 ? 1 : 0)
                }
                .transition(.move(edge: .top))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea()
        .gesture(DragGesture()
            .onChanged({value in
                let newHeight = startHeight + value.translation.height
                sheetHeight = min(max(newHeight, collapsedHeight), expandedHeight)
            })
            .onEnded { value in
                let velocity = value.velocity.height
                let midPoint = (collapsedHeight + expandedHeight) / 2
                withAnimation(.easeOut(duration: 0.3)) {
                    if sheetHeight > midPoint || velocity > 0.2 {
                        sheetHeight = expandedHeight
                        expanded = true
                    } else {
                        sheetHeight = collapsedHeight
                        expanded = false
                    }
                }
            }
        )
        .onChange(of: expanded) {
            if expanded {
                withAnimation(.easeOut(duration: 0.3)) {
                    sheetHeight = expanded ? expandedHeight : collapsedHeight
                }
            } else {
                withAnimation(.bouncy(duration: 0.3)) {
                    sheetHeight = expanded ? expandedHeight : collapsedHeight
                }
            }
        }
        .onTapGesture() {
            expanded.toggle()
        }
    }
    
    private var directionsList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(Array(directions.enumerated()), id: \.offset) { index, direction in
                        directionView(
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
            .background(.burntOrange)
        }
    }
}

struct BottomSheetView: View {
    @Binding var isShowing: Bool
    var resetData: () -> Void
    @Binding var distance: Double
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        return df
    }()
    var arrivalDate: Date { Date().addingTimeInterval(distance / 1.3) }
    @State var expanded: Bool = false
    var body: some View {
        ZStack {
            if isShowing {
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\((10 * Int(distance / 10))) m")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundStyle(.offWhite)
                            HStack {
                                Image(systemName: "figure.walk")
                                Text(meters_to_time(meters: distance))
                            }
                            .font(.system(size: 20))
                            .foregroundStyle(.offWhite.opacity(0.7))
                        }
                        .padding()
                        
                        Spacer()
                        
                        VStack {
                            Text("\(dateFormatter.string(from: arrivalDate))")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundStyle(.offWhite)
                            Text("Arrival")
                                .font(.system(size: 20))
                                .foregroundStyle(.offWhite.opacity(0.7))
                        }
                        
                        Spacer()
                        Button {
                            withAnimation(.easeOut(duration: 0.3)) {
                                expanded.toggle()
                            }
                        } label: {
                            Image(systemName: "chevron.up.circle.fill")
                                .font(.system(size: 25))
                                .foregroundStyle(.offWhite.opacity(0.7))
                                .rotationEffect(expanded ? Angle(degrees: 180) : Angle(degrees: 0))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, expanded ? 0 : 10)
                    if expanded {
                        EndRouteButton(resetData: resetData)
                    }
                }
                .background(.burntOrange)
                .frame(maxWidth: .infinity)
                .animation(.easeOut(duration: 0.3), value: expanded)
                .transition(.move(edge: .bottom))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea(edges: .bottom)
        .onChange(of: distance) {
            print("Distance changed! \(distance)")
        }
    }
}

struct EndRouteButton: View {
    var resetData: () -> Void
    var body: some View {
        VStack {
            Button {
                resetData()
            } label: {
                VStack {
                    Text("End Route")
                        .padding()
                        .font(.system(size: 25))
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.burntOrange)
                .background(.offWhite)
                .cornerRadius(12)
                .padding(.top, 0)
            }
        }
        .padding([.leading, .trailing, .bottom], 16)
        .padding(.bottom, 10)
        .transition(.move(edge: .bottom))
    }
}

struct directionView: View {
    var directionIcon: String
    var directionDescription: String
    var distance: String
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: directionIcon)
                .font(.system(size: 60))
                .fontWeight(.bold)
            VStack(alignment: .leading) {
                Text(distance)
                    .fontWeight(.bold)
                Text(directionDescription)
            }
            .font(.system(size: 35))
        }
        .padding(.leading, 50)
        .foregroundStyle(.offWhite)
        .frame(maxWidth: .infinity, alignment: .leading)
        Divider()
            .overlay(.offWhite)
            .padding(.leading)
            .padding(.trailing)
    }
}

//#Preview {
//    EndRouteButton()
//}
