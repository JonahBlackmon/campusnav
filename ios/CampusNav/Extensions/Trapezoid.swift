//
//  Trapezoid.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/28/25.
//
import SwiftUI

// Trapezoid used as the directional cone
struct Trapezoid: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        let topWidthRatio: CGFloat = 0.85
        let bottomWidthRatio: CGFloat = 1.2

        let topWidth = width * topWidthRatio
        let bottomWidth = width * bottomWidthRatio
        let xOffset = (width - topWidth) / 2
        let bottomOffset = (width - bottomWidth) / 2

        path.move(to: CGPoint(x: xOffset, y: 0))                          // Top left
        path.addLine(to: CGPoint(x: width - xOffset, y: 0))              // Top right
        path.addLine(to: CGPoint(x: width - bottomOffset, y: height))    // Bottom right
        path.addLine(to: CGPoint(x: bottomOffset, y: height))            // Bottom left
        path.closeSubpath()

        return path
    }
}
