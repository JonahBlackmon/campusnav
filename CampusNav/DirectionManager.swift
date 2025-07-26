//
//  DirectionManager.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/20/25.
//

import SwiftUI
import MapKit
import CoreLocation

enum WalkingDirection: Equatable {
    case forward, backward, left, right
    var description: String {
        switch self {
        case .forward: return "arrow.turn.right.up"
        case .backward: return "arrow.uturn.down"
        case .left: return "arrow.turn.up.left"
        case .right: return "arrow.turn.up.right"
        }
    }
}

struct DirectionStep: Equatable, Identifiable {
    var id = UUID()
    let label: String
    let distance: String
    let direction: WalkingDirection?
}


class DirectionManager: NSObject, ObservableObject {
    
    private var locationManager: CLLocationManager?
    @Published var log: String = ""
    
    @Published var currentDirection: CLLocationDirection?
    
    @Published var currentLocation: CLLocationCoordinate2D?
    
    var currentCoordinates: [CLLocationCoordinate2D]
    var currentNodes: [Node]
    
    init(currentCoordinates: [CLLocationCoordinate2D], currentNodes: [Node], locationManager: CLLocationManager = CLLocationManager()) {
        self.currentCoordinates = currentCoordinates
        self.currentNodes = currentNodes
        super.init()
        self.locationManager = locationManager
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
    }
    
    enum CardinalDirection: CaseIterable {
        case north, east, south, west
    }
    
    struct errorFound {
        static let error = "error"
    }
    
    let relativeDirection: [CardinalDirection: [CardinalDirection: WalkingDirection]] = [
        .north: [.north: .forward, .east: .right, .south: .backward, .west: .left],
        .east:  [.north: .left,    .east: .forward, .south: .right,   .west: .backward],
        .south: [.north: .backward, .east: .left,  .south: .forward, .west: .right],
        .west:  [.north: .right,   .east: .backward, .south: .left,  .west: .forward]
    ]
    
    private func currentCardinalDirection() -> CardinalDirection {
        switch currentDirection ?? 0.0 {
        case 0.0..<45.0:
            return CardinalDirection.north
        case 45.0..<135.0:
            return CardinalDirection.east
        case 135.0..<225.0:
            return CardinalDirection.south
        case 225.0..<315.0:
            return CardinalDirection.west
        case 315.0..<360.0:
            return CardinalDirection.north
        default:
            return CardinalDirection.north
            
        }
    }
    
    // Get walking direction from one location to another based on current direction
    private func routingDirection(currentDirection: CardinalDirection, a: CLLocationCoordinate2D, b: CLLocationCoordinate2D) -> (CardinalDirection, WalkingDirection?) {
        
        let latDif = b.latitude - a.latitude
        let lngDif = b.longitude - a.longitude
        var movingDirection: CardinalDirection
        if abs(latDif) > abs(lngDif) {
            // The most significant value is latitude so we are moving north or south
            movingDirection = latDif > 0 ? CardinalDirection.north : CardinalDirection.south
        } else {
            // The most signifcant value is longitude so we are moving east or west
            movingDirection = lngDif > 0 ? CardinalDirection.east : CardinalDirection.west
        }
        return (movingDirection, relativeDirection[currentDirection]?[movingDirection])
    }
    
    private func getDirectionsWithDistance() -> [(WalkingDirection?, Double, String?)] {
        var directionsWithDistance: [(WalkingDirection?, Double, String?)] = []
        var recentDistance: Double = 0.0
        // Adds the first turning direction to navigate to the first node
        var (currentCardinal, currentDirection) = routingDirection(currentDirection: currentCardinalDirection(), a: currentNodes[0].point.clLocationCoordinate, b: currentNodes[1].point.clLocationCoordinate)
        directionsWithDistance.append((currentDirection, 0.0, currentNodes[1].abbr))
        
        for i in 0..<currentNodes.count - 1 {
            recentDistance = haversine(a: currentNodes[i].point, b: currentNodes[i + 1].point)
            (currentCardinal, currentDirection) = routingDirection(currentDirection: currentCardinal, a: currentNodes[i].point.clLocationCoordinate, b: currentNodes[i + 1].point.clLocationCoordinate)
            directionsWithDistance.append((currentDirection, recentDistance, currentNodes[i + 1].abbr))
        }
        return directionsWithDistance
    }
    
    private func directionString(directionWithDistance: (WalkingDirection?, Double, String?), destination: String, distance: Double) -> (String, String) {
        let distanceValue: Int = distance != 0 ? (10 * Int(distance / 10)) :  (10 * Int(directionWithDistance.1 / 10))
        // Base case, we're at destination
        if directionWithDistance.2 == destination {
            
            return ("\(directionWithDistance.0 != WalkingDirection.forward ? "Turn \(walkingSwitch(direction: directionWithDistance.0)) and" : "Walk forward and") arrive at \(destination)", "\(distanceValue) m")
        }
        // Another base case, we are at the start so just turn
        if distanceValue == 0 {
            if directionWithDistance.0 != WalkingDirection.forward {
                return ("Turn \(walkingSwitch(direction: directionWithDistance.0))", "\(distanceValue) m")
            }
        }
        if directionWithDistance.0 != WalkingDirection.forward && distanceValue != 0 {
            // We're turning
            return ("Turn \(walkingSwitch(direction: directionWithDistance.0))", "\(distanceValue) m")
        } else if directionWithDistance.2 != nil {
            if distanceValue != 0 {
                return ("Walk to \(directionWithDistance.2 ?? "")", "\(distanceValue) m")
            }
        }
        return ("", "")
    }
    
    private func walkingSwitch(direction: WalkingDirection?) -> String {
        switch direction ?? WalkingDirection.forward {
        case WalkingDirection.forward:
            return "forward"
        case WalkingDirection.backward:
            return "around"
        case WalkingDirection.left:
            return "left"
        case WalkingDirection.right:
            return "right"
        }
    }
    
    func getDirections(destAbbr: String) -> [DirectionStep] {
        let directionsWithDistance: [(WalkingDirection?, Double, String?)] = getDirectionsWithDistance()
        var directions: [DirectionStep] = []
        var tempDistance = 0.0
        for direction in directionsWithDistance {
            if direction.0 == WalkingDirection.forward {
                tempDistance += direction.1
                if direction.2 == nil {
                    continue
                }
            }
            let (label, distance) = directionString(directionWithDistance: direction, destination: destAbbr, distance: tempDistance)
            tempDistance = 0.0
            if label != "" {
                directions.append(DirectionStep(label: label, distance: distance, direction: direction.0))
            }
        }
        return directions
    }
    
    
}


extension DirectionManager: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            log = "Location authorization not determined"
        case .restricted:
            log = "Location authorization restricted"
        case .denied:
            log = "Location authorization denied"
        case .authorizedAlways:
            manager.requestLocation()
            log = "Location authorization always granted"
        case .authorizedWhenInUse:
            manager.requestWhenInUseAuthorization()
            log = "Location authorization when in use granted"
        @unknown default:
            log = "Unkown authorization status"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.currentDirection = newHeading.magneticHeading
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.currentLocation = location.coordinate
    }

}
