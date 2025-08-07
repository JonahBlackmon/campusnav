//
//  ButtonAnimation.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/27/25.
//
import SwiftUI

// Unused in apps curren state
struct HorizontalGrow: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(x: isActive ? 1 : 0.6, y: 1, anchor: .center)
            .opacity(isActive ? 1 : 0)
    }
}

extension AnyTransition {
    static var horizontalGrow: AnyTransition {
        .modifier(
            active: HorizontalGrow(isActive: false),
            identity: HorizontalGrow(isActive: true)
        )
    }
}
