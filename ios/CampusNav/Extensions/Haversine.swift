//
//  haversine.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/26/25.
//
import SwiftUI

func haversine(a: Coordinate, b: Coordinate) -> Double {
    let radius = 6371.0088
    let dLat = deg2rad(degree: b.latitude - a.latitude)
    let dLon = deg2rad(degree: b.longitude - a.longitude)
    let lat1 = deg2rad(degree: a.latitude)
    let lat2 = deg2rad(degree: b.latitude)
    let x = sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2)
    let y = 2 * atan2(sqrt(x), sqrt(1 - x))
    return radius * y * 1000
}
