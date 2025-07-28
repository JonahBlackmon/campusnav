//
//  Node.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/26/25.
//

import Foundation
import MapKit

struct Node {
    var id: Int
    var abbr: String?
    var point: Coordinate
}

final class NodeAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?

    init(node: Node) {
        self.coordinate = node.point.clLocationCoordinate
        self.title = node.abbr
    }
}
