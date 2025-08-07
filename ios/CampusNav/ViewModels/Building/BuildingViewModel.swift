//
//  BuildingManager.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/18/25.
//

import SwiftUI
import MapboxMaps
import Turf

// Building VM in charge of the currently selected building, and which buildings get displayed in search features
class BuildingViewModel: ObservableObject {
    
    @Published var buildingList: [Building] = []
    
    @Published var popularBuildings: [Building] = []
    
    @Published var selectedBuilding: Building? = nil
    
    private var popularAbbrs: [String] = ["PCL", "JES", "KIN", "WEL", "D21", "UNB", "FAC", "GRE", "WAG"]
    
    func name() -> String {
        return selectedBuilding?.name ?? selectedBuilding?.abbr ?? ""
    }
    
    func abbr() -> String {
        return selectedBuilding?.abbr ?? ""
    }
    
    func url() -> String {
        return selectedBuilding?.photoURL ?? ""
    }
    
    // Loads buildings
    func loadBuildings(pathName: String) {
        guard let url = Bundle.main.url(forResource: pathName, withExtension: "geojson") else {
            return
        }
        var result: GeoJSONObject?
        do {
            let jsonData = try Data(contentsOf: url)
            result = try JSONDecoder().decode(GeoJSONObject.self, from: jsonData)
            
            if case let .featureCollection(fc) = result {
                let buildings = fc.features.compactMap { feature -> Building? in
                    // Immediate guard against buildings that don't have an abbreviation
                    guard
                        case let .string(abbr)? = feature.properties?["Building_Abbr"]
                    else {
                        return nil
                    }
                    if !nodes.contains(where: {$0.abbr == abbr}) {
                        return nil
                    }
                    let name = feature.properties?["Description"]??.string
                    var photo_url = feature.properties?["Photo_URL"]??.string
                    photo_url = ((photo_url?.contains("src=")) != nil)
                    ? photo_url?.components(separatedBy: "src=").last?.trimmingCharacters(in: CharacterSet(charactersIn: ">\"")) ?? ""
                    : photo_url
                    
                    let returnBuilding = Building(abbr: abbr, name: name ?? abbr, photoURL: photo_url ?? "")
                    if popularAbbrs.contains(abbr) {
                        popularBuildings.append(returnBuilding)
                    }
                    return returnBuilding
                }
                DispatchQueue.main.async {
                    self.buildingList = buildings
                }
            }
        } catch {
            print("Erorr: \(error)")
        }
        
    }
    
    // Returns all buildings whose name or abbr matches some part of the matching search
    func searchBuilding(matching search: String) -> [Building] {
        guard !search.isEmpty else {
            return []
        }
        let uppercasedSearch = search.uppercased()
        return buildingList.filter {
            $0.abbr.contains(uppercasedSearch) || $0.name.uppercased().contains(uppercasedSearch)
        }
    }
    
    // Should only be called on verified abbr's
    func selectBuilding(abbr: String) -> Building? {
        return buildingList.filter{ $0.abbr == abbr }.first
    }
    
}
