//
//  SheetView.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/21/25.
//
import SwiftUI

let collapsedHeight: CGFloat = 165
let expandedHeight: CGFloat = UIScreen.main.bounds.height * 0.90

struct TopSheetView<Content: View>: View {
    @Binding var sheetHeight: CGFloat
    @State private var startHeight: CGFloat = collapsedHeight
    @Binding var expanded: Bool
    let content: Content
    var body: some View {
        ZStack(alignment: .top){
            content
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
}


struct BottomSheetView<Content: View>: View {
    @Binding var expanded: Bool
    let content: Content
    var body: some View {
        ZStack {
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea(edges: .bottom)
    }
}
