//
//  Coordinate.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/26/25.
//

import Foundation
import MapKit

struct Coordinate {
    var latitude: Double
    var longitude: Double
    var clLocationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension Coordinate {
    func distance(to other: Coordinate) -> Double {
        return haversine(a: self, b: other)
    }
}
