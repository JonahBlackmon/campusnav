//
//  MapView.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/13/25.
//
import SwiftUI
import MapKit
import MapboxMaps
@_spi(Experimental) import MapboxMaps
import Turf

struct MapView: View {
    @EnvironmentObject var navState: NavigationUIState
    @EnvironmentObject var buildingVM: BuildingViewModel
    @EnvironmentObject var navigationVM: NavigationViewModel
    let starting_position: MapCameraPosition = .region(.init(center: .init(latitude: 30.2850, longitude: -97.7335), latitudinalMeters: 1300, longitudinalMeters: 1300))
    var body: some View {
        MapBoxMapView()
            .environmentObject(navState)
            .environmentObject(navigationVM)
            .environmentObject(buildingVM)
    }
}

var specialAbbrs: [String] = [
    "STD",
    "NEZ",
    "SEZ",
    "BEL",
    "MMS",
    "MAI",
    "BOT",
    "CSS",
    "CPB",
    "E24",
    "E11",
    "BSB",
    "BGH",
    "LS1",
    "SEA",
    "SJH"
]

enum GeoJSONLayer : String {
    case block = "block"
    case building = "building"
    case inverted = "inverted"
}

struct MapBoxMapView: View {
    @State private var invertedSourceData: GeoJSONSourceData? = nil
    @State private var blockSourceData: GeoJSONSourceData? = nil
    @State private var buildingSourceData: GeoJSONSourceData? = nil
    @State private var viewport = Viewport.camera(center: CLLocationCoordinate2D(latitude: 30.2850, longitude: -97.7335), zoom: 13.9, bearing: 0, pitch: 0)
    @State private var zoomAboveThreshold = false
    @State var selectedFeature: FeaturesetFeature?
    @State var currentZoom: Double = 13.9
    @State private var bobbingOffset: CGFloat = 0
    @State private var animatedUserCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 30.287265, longitude: -97.737051)
    @EnvironmentObject var navState: NavigationUIState
    @EnvironmentObject var navigationVM: NavigationViewModel
    @EnvironmentObject var buildingVM: BuildingViewModel
    var body: some View {
        MapReader { proxy in
            Map(viewport: $viewport) {
                // General route styling
                PolylineAnnotationGroup() {
                    PolylineAnnotation(lineCoordinates: navigationVM.currentCoordinates)
                        .lineColor(.lightOrange)
                        .lineBorderColor(.burntOrange)
                        .lineWidth(10)
                        .lineBorderWidth(2)
                }
                    .lineCap(.round)
                    .slot(.middle)
                
                // Only draw the route once we have the coordinates we're navigating
                if !navigationVM.currentCoordinates.isEmpty {
                    MapViewAnnotation(coordinate: navigationVM.currentCoordinates.last!) {
                        // Image that controls the bobbing icon at the destination
                        Image("dest-pin")
                            .offset(y: bobbingOffset)
                            .animation(
                                .easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true),
                                value: bobbingOffset
                            )
                            .onAppear {
                                bobbingOffset = -10
                            }
                            .onDisappear {
                                bobbingOffset = 0
                            }
                    }
                    .priority(1)
                }
                
                // Draw the user location
                MapViewAnnotation(coordinate: animatedUserCoordinate) {
                    LocationPuck()
                        .environmentObject(navigationVM)
                }
                
                // Styling for visual labels and hidden boundaries for clickability
                if let loadedGeoJSONData = invertedSourceData {
                    MapboxMaps.GeoJSONSource(id: "ut-campus-boundary")
                        .data(loadedGeoJSONData)
                    FillLayer(id: "ut-campus-boundary-layer", source: "ut-campus-boundary")
                        .fillColor(StyleColor(.black))
                        .fillOpacity(0.3)
                }
                if let loadedGeoJSONData = blockSourceData {
                    GeoJSONSource(id: "ut-campus-blocks")
                        .data(loadedGeoJSONData)

                    SymbolLayer(id: "boundary-labels", source: "ut-campus-blocks")
                        .textField(Exp(.get) { "label" })
                        .textColor(StyleColor(.offWhite))
                        .textHaloColor(StyleColor(.black))
                        .textHaloWidth(1.0)
                        .textSize(11)
                        .textFont(["Open Sans Bold"])
                        .textOpacity(currentZoom < 15 ? 1.0 : 0.0)
                        .textAllowOverlap(true)
                }
                if let loadedGeoJSONData = buildingSourceData {
                    GeoJSONSource(id: "ut-buildings")
                        .data(loadedGeoJSONData)
                    
                    FillLayer(id: "building-shapes", source: "ut-buildings")
                            .fillColor(StyleColor(.clear))
                            .fillOpacity(0.0)
                            .filter(Exp(.eq) {
                                Exp(.get) { "Site" }
                                "UTM"
                            })
                    
                    
                    SymbolLayer(id: "building-labels", source: "ut-buildings")
                        .textField(Exp(.get) { "Building_Abbr" })
                        .textColor(StyleColor(.darkGray))
                        .textSize(7)
                        .textFont(["Open Sans Bold"])
                        .textOpacity(currentZoom >= 15 ? 1.0 : 0.0)
                        .textAllowOverlap(true)
                        .filter(Exp(.eq) {
                            Exp(.get) { "Site" }
                            "UTM"
                        })
                }

                // Determins the current selected feature
                if let selectedFeature {
                    FeatureState(selectedFeature, ["select": true])
                }
                // If the building labels are visible, then allow the to be interactable
                if currentZoom >= 15 {
                    if !navState.isNavigating {
                        // Tap interaction for the area of each building via geojson polygons
                        TapInteraction(.layer("building-shapes")) { feature, context in
                            selectedFeature = feature // Currently selected
                            // Building exists in our navigation, it has an abbreviation
                            var selectedName = ""
                            var photoURL = ""
                            if case let .string(buildingAbbr)? = feature.properties["Building_Abbr"] {
                                if case let .string(destinationName)? = feature.properties["Description"] {
                                    selectedName = destinationName
                                } else {
                                    // If there is no name, abbreviate it
                                    selectedName = buildingAbbr
                                }
                                // Optional image from UT's data set
                                if case let .string(rawHTML)? = feature.properties["Photo_URL"] {
                                    photoURL = rawHTML.contains("src=")
                                    ? rawHTML.components(separatedBy: "src=").last?.trimmingCharacters(in: CharacterSet(charactersIn: ">\"")) ?? ""
                                    : rawHTML
                                }
                                // Can we navigate here?
                                let exists = nodes.contains { $0.abbr == buildingAbbr }
                                if exists {
                                    // Is it an actual building?
                                    guard let polygon = feature.geometry.polygon else {
                                        print("Non-polygon geometry")
                                        navState.showNavigationCard = true
                                        return false
                                    }
                                    buildingVM.selectedBuilding = Building(abbr: buildingAbbr, name: selectedName, photoURL: photoURL)
                                    withViewportAnimation(.easeInOut(duration: 0.5)) {
                                        viewport = Viewport.camera(center: polygon.center, zoom: 16.5)
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                        navState.showNavigationCard = true
                                    }
                                } else {
                                    resetSelected()
                                }
                            } else {
                                resetSelected()
                            }
                            return buildingVM.url().isEmpty || specialAbbrs.contains(buildingVM.abbr())
                        }
                    }
                } else {
                    // We are zoomed out enough, so we have custom general labels
                    TapInteraction(.layer("boundary-labels")) { feature, context in
                        selectedFeature = feature
                        // Zoom in enough to see building labels
                        withViewportAnimation(.easeInOut(duration: 0.5)) {
                            viewport = Viewport.camera(center: feature.geometry.polygon?.center, zoom: 15.5)
                        }
                        resetSelected()
                        return true
                    }
                }
                // MapBox building interaction to change color
                TapInteraction(.featureset("buildings", importId: "basemap")) { feature, context in
                    selectedFeature = feature
                    return true
                }
                // If we miss everything else, just reset values
                TapInteraction { context in
                    resetSelected()
                    return true
                }
            }
            // Hides MapBox compass and scale
            .ornamentOptions(OrnamentOptions(
                scaleBar: ScaleBarViewOptions(visibility: .hidden),
                compass: CompassViewOptions(visibility: .hidden)
            ))
            // Listener for camera that determines pitch of zoom, only activates when passing threshold
            .onCameraChanged { context in
                currentZoom = context.cameraState.zoom
                
                if currentZoom > 15 && !zoomAboveThreshold {
                    withViewportAnimation(.default(maxDuration: 1)) {
                        viewport = Viewport.camera(pitch: 20)
                    }
                    zoomAboveThreshold = true
                } else if currentZoom <= 15 && zoomAboveThreshold {
                    withViewportAnimation(.default(maxDuration: 1)) {
                        viewport = Viewport.camera(pitch: 0)
                    }
                    zoomAboveThreshold = false
                }
            }
            // Custom map style
            .mapStyle(MapStyle(uri: StyleURI(rawValue: "mapbox://styles/jonahblackmon/cmd3rt0a900gz01qnddu2cdpm")!))
            // Loads all necessary information on map load
            .onAppear {
                loadGeoJSON(url: "Inverted_UT_Campus_Boundary", layer: .inverted)
                loadGeoJSON(url: "UT_Campus_Block", layer: .block)
                loadGeoJSON(url: "buildings_simple", layer: .building)
                if let current = navigationVM.currentLocation {
                    animatedUserCoordinate = current
                }
            }
            .onChange(of: navState.isNavigating) {
                if navState.isNavigating {
                    withViewportAnimation(.default(maxDuration: 1)) {
                        viewport = Viewport.camera(center: centerOfRoute(bounds: routeBounds()), zoom: 14.75)
                    }
                    withAnimation(.easeOut(duration: 0.3)) {
                        navigationVM.directions = navigationVM.getDirections(destAbbr: navigationVM.currentNodes.last?.abbr ?? "")
                    }
                }
            }
            .onChange(of: navigationVM.currentLocation) {
                interpolate()
            }
        }
        .ignoresSafeArea()
    }
    
    private func interpolate() {
        let duration: TimeInterval = 1.0
        let steps = 60
        let interval = duration / Double(steps)

        let deltaLat = ((navigationVM.currentLocation?.latitude ?? 30.287265) - animatedUserCoordinate.latitude) / Double(steps)
        let deltaLon = ((navigationVM.currentLocation?.longitude ?? -97.737051) - animatedUserCoordinate.longitude) / Double(steps)

        for step in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(step)) {
                animatedUserCoordinate.latitude += deltaLat
                animatedUserCoordinate.longitude += deltaLon
            }
        }
    }
    
    func routeBounds() -> CoordinateBounds {
        var minLat = navigationVM.currentCoordinates[0].latitude
        var minLng = navigationVM.currentCoordinates[0].longitude
        var maxLat = navigationVM.currentCoordinates[0].latitude
        var maxLng = navigationVM.currentCoordinates[0].longitude
        
        for coord in navigationVM.currentCoordinates {
            if coord.latitude > maxLat {
                maxLat = coord.latitude
            } else if coord.latitude < minLat {
                minLat = coord.latitude
            }
            if coord.longitude > maxLng {
                maxLng = coord.longitude
            } else if coord.longitude < minLng {
                minLng = coord.longitude
            }
        }
        return CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: minLat, longitude: minLng), northeast: CLLocationCoordinate2D(latitude: maxLat, longitude: maxLng))
    }
    
    func centerOfRoute(bounds: CoordinateBounds) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: (bounds.southwest.latitude + bounds.northeast.latitude) / 2,
                                      longitude: (bounds.southwest.longitude + bounds.northeast.longitude) / 2)
    }
    
    // Loads all geojson data to enable tap interactions for the map
    private func loadGeoJSON(url: String, layer: GeoJSONLayer) {
        guard let url = Bundle.main.url(forResource: url, withExtension: "geojson") else {
            print("Error: GeoJSON file not found.")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let geoJSONObject = try JSONDecoder().decode(GeoJSONObject.self, from: data)
            let sourceData: GeoJSONSourceData?
            
            switch geoJSONObject {
                case .feature(let feature):
                    sourceData = .feature(feature)
                case .featureCollection(let featureCollection):
                    sourceData = .featureCollection(featureCollection)
                case .geometry(let geometry):
                    sourceData = .geometry(geometry)
                default:
                    sourceData = nil
            }
            switch layer {
                case .block:
                    self.blockSourceData = sourceData
                case .building:
                    self.buildingSourceData = sourceData
                case .inverted:
                    self.invertedSourceData = sourceData
            }
        } catch {
            print("Error loading or decoding GeoJSON: \(error)")
        }
    }
    
    // Resets all values to their null values
    private func resetSelected() {
        navState.showNavigationCard = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            buildingVM.selectedBuilding = nil
        }
    }
}
