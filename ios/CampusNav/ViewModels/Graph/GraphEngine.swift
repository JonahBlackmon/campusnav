//
//  MapManager.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/12/25.
//

import MapKit
import SwiftUI

var distance: Double = -1.0

func find_closest_goal(graph: Graph, abbr: String?, pos: Coordinate) -> Int {
    var closest_node = -1
    var shortestDistance = Double.infinity
    for i in 0..<graph.num_nodes {
        if let nodeAbbr = graph.nodes[i].abbr, nodeAbbr == abbr {
            let temp_distance = pos.distance(to: graph.nodes[i].point)
            if temp_distance < shortestDistance {
                shortestDistance = temp_distance
                closest_node = i
            }
        }
    }
    return closest_node
}

func find_closest_coordinate(pos: Coordinate, graph: inout Graph) -> Node {
    var closest = graph.nodes[0].point
    var distance = pos.distance(to: closest)
    
    var nearest_path_id: Int = -1
    var new_point = false
    var node_id = -1
    for i in 0..<graph.num_paths {
        var temp_new = false
        var temp_id = -1
        let closest_on_path = find_closest_point_on_path(pos: pos, path: graph.pathways[i], graph: graph, new_point: &temp_new, node_id: &temp_id)
        let path_dis = pos.distance(to: closest_on_path)
        if path_dis < distance {
            distance = path_dis;
            closest = closest_on_path;
            nearest_path_id = i;
            new_point = temp_new;
            node_id = temp_id;
        }
    }
    var abbr: String?
    for i in 0..<graph.num_nodes {
        let node = graph.nodes[i]
        if node.abbr == nil {
            let node_dis = pos.distance(to: node.point)
            if node_dis < distance {
                distance = node_dis;
                closest = node.point;
                abbr = nil
            }
        }
    }
    
    var new_node = Node(
        id: -1,
        point: closest
    )
    
    if new_point {
        new_node = Node(
            id: graph.num_nodes,
            point: closest
        )
        graph.nodes.append(new_node)
        graph.num_nodes += 1
    }
    
    if abbr == nil && new_point {
        split_path(path_index: nearest_path_id, new_node: new_node, graph: &graph)
    }
    
    let current_pos = Node(id: graph.num_nodes, abbr: "POS", point: pos)
    graph.nodes.append(current_pos)
    graph.num_nodes += 1
    let current_path = Pathway(
        from: current_pos.id,
        to: new_point ? new_node.id : node_id,
        distance: current_pos.point.distance(to: new_point ? new_node.point : graph.nodes[node_id].point)
    )
    graph.num_paths += 1
    graph.pathways.append(current_path)
    return current_pos
}

func split_path(path_index: Int, new_node: Node, graph: inout Graph) {
    var oldPath = graph.pathways[path_index]
    var newPath = Pathway(
        from: new_node.id,
        to: oldPath.to,
        distance: -1.0
    )
    oldPath.to = new_node.id
    oldPath.distance = graph.nodes[oldPath.from].point.distance(to: graph.nodes[oldPath.to].point)
    newPath.distance = graph.nodes[newPath.from].point.distance(to: graph.nodes[newPath.to].point)
    graph.num_paths += 1
    graph.pathways[path_index] = oldPath
    graph.pathways.append(newPath)
}

func distance_to_path(pos: Coordinate, start: Coordinate, end: Coordinate) -> Double {
    let posX = pos.longitude
    let posY = pos.latitude
    let pathStartX = start.longitude
    let pathStartY = start.latitude
    let pathEndX = end.longitude
    let pathEndY = end.latitude
    
    let pathX = pathEndX - pathStartX
    let pathY = pathEndY - pathStartY
    
    let pathPosX = posX - pathStartX
    let pathPosY = posY - pathStartY
    
    let path_sq = pathX * pathX + pathY * pathY
    let path_dot_pos = pathPosX * pathX + pathPosY * pathY
    var point = path_sq != 0 ? path_dot_pos / path_sq : path_dot_pos
    
    if point < 0.0 {
        point = 0.0
    } else if point > 1.0 {
        point = 1.0
    }
    
    let closest = Coordinate(
        latitude: pathStartY + point * pathY,
        longitude: pathStartX + point * pathX
    )
    
    return pos.distance(to: closest)
}

func find_closest_point_on_path(pos: Coordinate, path: Pathway, graph: Graph, new_point: inout Bool, node_id: inout Int) -> Coordinate {
    let posX = pos.longitude
    let posY = pos.latitude
    let pathStartX = graph.nodes[path.from].point.longitude
    let pathStartY = graph.nodes[path.from].point.latitude
    let pathEndX = graph.nodes[path.to].point.longitude
    let pathEndY = graph.nodes[path.to].point.latitude
    
    let pathX = pathEndX - pathStartX
    let pathY = pathEndY - pathStartY
    
    let pathPosX = posX - pathStartX
    let pathPosY = posY - pathStartY
    
    let path_sq = pathX * pathX + pathY * pathY
    let path_dot_pos = pathPosX * pathX + pathPosY * pathY
    var point = path_sq != 0 ? path_dot_pos / path_sq : path_dot_pos
    
    if point < 0.0 {
        point = 0.0
    } else if point > 1.0 {
        point = 1.0
    }
    
    let closest = Coordinate(
        latitude: pathStartY + point * pathY,
        longitude: pathStartX + point * pathX
    )
    if coordinatesEqual(a: closest, b: graph.nodes[path.from].point) {
        new_point = false
        node_id = graph.nodes[path.from].id
    } else if coordinatesEqual(a: closest, b: graph.nodes[path.to].point) {
        new_point = false
        node_id = graph.nodes[path.to].id
    } else {
        new_point = true
        node_id = -1
    }
    return closest
}

private func coordinatesEqual(a: Coordinate, b: Coordinate) -> Bool {
    return a.distance(to: b) < 5
}

func a_star(graph: inout Graph, start: Int, goal: Int, out_path_len: inout Int) -> [Int] {
    let n = graph.num_nodes
    var g_score: [Double] = Array(repeating: Double.infinity, count: n)
    var f_score: [Double] = Array(repeating: Double.infinity, count: n)
    var visited: [Bool] = Array(repeating: false, count: n)
    var came_from: [Int] = Array(repeating: -1, count: n)
    
    g_score[start] = 0
    f_score[start] = graph.nodes[start].point.distance(to: graph.nodes[goal].point)
    
    while (true) {
        var current = -1
        var lowest = Double.infinity
        for i in 0..<n {
            if !visited[i] && f_score[i] < lowest {
                lowest = f_score[i]
                current = i
            }
        }
        if current == -1 || current == goal {
            break;
        }
        visited[current] = true
        var neighbor_count = 0
        let neighbors = get_neighbors(graph: &graph, node_index: current, out_count: &neighbor_count)
        for i in 0..<neighbor_count {
            let neighbor = neighbors[i]
            if visited[neighbor] {
                continue
            }
            var dist = Double.infinity
            for p in 0..<graph.num_paths {
                if graph.pathways[p].from == current && graph.pathways[p].to == neighbor ||
                    graph.pathways[p].to == current && graph.pathways[p].from == neighbor {
                    dist = graph.pathways[p].distance
                    break
                }
            }
            let tentative_g = g_score[current] + dist
            if tentative_g < g_score[neighbor] {
                came_from[neighbor] = current
                g_score[neighbor] = tentative_g
                f_score[neighbor] = tentative_g + graph.nodes[neighbor].point.distance(to: graph.nodes[goal].point)
            }
        }
    }
    var node_path: [Int] = []
    var at = goal
    while at != -1 {
        node_path.append(at)
        at = came_from[at]
    }
    
    if node_path.isEmpty {
        return []
    }
    node_path.reverse()
    return node_path
}

func get_neighbors(graph: inout Graph, node_index: Int, out_count: inout Int) -> [Int] {
    var neighbors: [Int] = []
    for i in 0..<graph.num_paths {
        if graph.pathways[i].from == node_index {
            neighbors.append(graph.pathways[i].to)
        } else if graph.pathways[i].to == node_index {
            neighbors.append(graph.pathways[i].from)
        }
    }
    out_count = neighbors.count
    return neighbors
}

func find_route(lat: Double, lng: Double, dest_abbr: String) -> ([CLLocationCoordinate2D], [Node], Double) {
    var tempNodes = nodes
    var tempPaths = pathways
    
    var graph = Graph(
            nodes: tempNodes,
            pathways: tempPaths,
            num_nodes: tempNodes.count,
            num_paths: tempPaths.count
        )
    distance = -1.0
    let pos = Coordinate(latitude: lat, longitude: lng)
    let goal_id = find_closest_goal(graph: graph, abbr: dest_abbr, pos: pos)
    guard goal_id != -1 else {
        print("Could not find goal for abbr: \(String(describing: dest_abbr))")
        return ([], [], -1.0)
    }
    let pos_node = find_closest_coordinate(pos: pos, graph: &graph)
    var newSteps: Int = -1
    let node_path = a_star(graph: &graph, start: pos_node.id, goal: goal_id, out_path_len: &newSteps)
    for i in 0..<node_path.count - 1{
        distance += graph.nodes[node_path[i]].point.distance(to: graph.nodes[node_path[i + 1]].point)
    }
    print("Distance: \(distance)")
    return (node_path.map { graph.nodes[$0].point.clLocationCoordinate }, node_path.map { graph.nodes[$0] }, distance)
}


let nodes: [Node] = [
    Node(id: 0, abbr: "KIN", point: Coordinate(latitude: 30.2903876632107, longitude: -97.7399904834272)),
    Node(id: 1, abbr: nil, point: Coordinate(latitude: 30.2903945389373, longitude: -97.7401692798991)),
    Node(id: 2, abbr: nil, point: Coordinate(latitude: 30.2898048622009, longitude: -97.7402103302699)),
    Node(id: 3, abbr: nil, point: Coordinate(latitude: 30.2903978772834, longitude: -97.74025490104)),
    Node(id: 4, abbr: nil, point: Coordinate(latitude: 30.2898232277367, longitude: -97.7403028350487)),
    Node(id: 5, abbr: nil, point: Coordinate(latitude: 30.2904587455353, longitude: -97.7412190084972)),
    Node(id: 6, abbr: nil, point: Coordinate(latitude: 30.2898874347087, longitude: -97.7412789495823)),
    Node(id: 7, abbr: "DMC", point: Coordinate(latitude: 30.2901490661497, longitude: -97.7407537919167)),
    Node(id: 8, abbr: nil, point: Coordinate(latitude: 30.2899655921875, longitude: -97.7407466149121)),
    Node(id: 9, abbr: nil, point: Coordinate(latitude: 30.2905638820077, longitude: -97.7412006547079)),
    Node(id: 10, abbr: "ADH", point: Coordinate(latitude: 30.291399757255, longitude: -97.7410398374182)),
    Node(id: 11, abbr: nil, point: Coordinate(latitude: 30.2913998477242, longitude: -97.741127669286)),
    Node(id: 12, abbr: nil, point: Coordinate(latitude: 30.2904807943904, longitude: -97.7402472656092)),
    Node(id: 13, abbr: nil, point: Coordinate(latitude: 30.2911901128526, longitude: -97.7401796865149)),
    Node(id: 14, abbr: nil, point: Coordinate(latitude: 30.2912533147207, longitude: -97.7411456903777)),
    Node(id: 15, abbr: nil, point: Coordinate(latitude: 30.2910775689156, longitude: -97.7401080736303)),
    Node(id: 16, abbr: nil, point: Coordinate(latitude: 30.2909570997159, longitude: -97.7390414659747)),
    Node(id: 17, abbr: nil, point: Coordinate(latitude: 30.2897345678097, longitude: -97.7391514260669)),
    Node(id: 18, abbr: nil, point: Coordinate(latitude: 30.28971387716, longitude: -97.7390461388857)),
    Node(id: 19, abbr: nil, point: Coordinate(latitude: 30.2909466233397, longitude: -97.7389520625)),
    Node(id: 20, abbr: "TSG", point: Coordinate(latitude: 30.2909635230549, longitude: -97.7386058165575)),
    Node(id: 21, abbr: "BWY", point: Coordinate(latitude: 30.2907923544986, longitude: -97.7380507145428)),
    Node(id: 22, abbr: nil, point: Coordinate(latitude: 30.2907729758832, longitude: -97.7379027844292)),
    Node(id: 23, abbr: nil, point: Coordinate(latitude: 30.28962773091, longitude: -97.7380223208458)),
    Node(id: 24, abbr: nil, point: Coordinate(latitude: 30.2896665247778, longitude: -97.7384779715794)),
    Node(id: 25, abbr: "SSB", point: Coordinate(latitude: 30.2898369896281, longitude: -97.7384727957542)),
    Node(id: 26, abbr: "UA9", point: Coordinate(latitude: 30.2903186991485, longitude: -97.7386565165943)),
    Node(id: 27, abbr: nil, point: Coordinate(latitude: 30.2903290036985, longitude: -97.7390050256507)),
    Node(id: 28, abbr: nil, point: Coordinate(latitude: 30.2897129091236, longitude: -97.7413065286243)),
    Node(id: 29, abbr: "CMB", point: Coordinate(latitude: 30.2892354849611, longitude: -97.741302924406)),
    Node(id: 30, abbr: nil, point: Coordinate(latitude: 30.2888018648108, longitude: -97.7414244515245)),
    Node(id: 31, abbr: nil, point: Coordinate(latitude: 30.2887588817664, longitude: -97.7407858133673)),
    Node(id: 32, abbr: "HSM", point: Coordinate(latitude: 30.2888243379421, longitude: -97.7407792021412)),
    Node(id: 33, abbr: nil, point: Coordinate(latitude: 30.2887897054333, longitude: -97.7410058592802)),
    Node(id: 34, abbr: nil, point: Coordinate(latitude: 30.2896839584912, longitude: -97.7409420206103)),
    Node(id: 35, abbr: "CMB", point: Coordinate(latitude: 30.2895223595224, longitude: -97.7410553334637)),
    Node(id: 36, abbr: "CMA", point: Coordinate(latitude: 30.2896011686821, longitude: -97.740682401637)),
    Node(id: 37, abbr: nil, point: Coordinate(latitude: 30.289637474614, longitude: -97.7403078982034)),
    Node(id: 38, abbr: "CMA", point: Coordinate(latitude: 30.2892184401943, longitude: -97.7407205392964)),
    Node(id: 39, abbr: "HSM", point: Coordinate(latitude: 30.2889929857814, longitude: -97.7407504626907)),
    Node(id: 40, abbr: "CMB", point: Coordinate(latitude: 30.2891532466481, longitude: -97.7410184007029)),
    Node(id: 41, abbr: nil, point: Coordinate(latitude: 30.2896378953035, longitude: -97.7402346508472)),
    Node(id: 42, abbr: nil, point: Coordinate(latitude: 30.2891013975731, longitude: -97.74021213496)),
    Node(id: 43, abbr: nil, point: Coordinate(latitude: 30.2887307450972, longitude: -97.74038266478)),
    Node(id: 44, abbr: nil, point: Coordinate(latitude: 30.2887161610711, longitude: -97.7402871634707)),
    Node(id: 45, abbr: nil, point: Coordinate(latitude: 30.2889704765005, longitude: -97.7397932388718)),
    Node(id: 46, abbr: "LTD", point: Coordinate(latitude: 30.2892775178504, longitude: -97.7397453677273)),
    Node(id: 47, abbr: "BLD", point: Coordinate(latitude: 30.2886219710093, longitude: -97.7394525773722)),
    Node(id: 48, abbr: "AND", point: Coordinate(latitude: 30.288248647796, longitude: -97.73985744425)),
    Node(id: 49, abbr: "CRD", point: Coordinate(latitude: 30.2886951445086, longitude: -97.7399394192631)),
    Node(id: 50, abbr: nil, point: Coordinate(latitude: 30.2890708725596, longitude: -97.7392349098242)),
    Node(id: 51, abbr: nil, point: Coordinate(latitude: 30.2895722089703, longitude: -97.7391706311046)),
    Node(id: 52, abbr: nil, point: Coordinate(latitude: 30.2895355139895, longitude: -97.7389031960066)),
    Node(id: 53, abbr: "BME", point: Coordinate(latitude: 30.2892840589122, longitude: -97.738862480912)),
    Node(id: 54, abbr: "BME", point: Coordinate(latitude: 30.2892715150922, longitude: -97.7382104945741)),
    Node(id: 55, abbr: "NMS", point: Coordinate(latitude: 30.2892507700621, longitude: -97.738091220092)),
    Node(id: 56, abbr: "BME", point: Coordinate(latitude: 30.2893977222239, longitude: -97.7385366449038)),
    Node(id: 57, abbr: nil, point: Coordinate(latitude: 30.2895255305279, longitude: -97.7385288392565)),
    Node(id: 58, abbr: "NMS", point: Coordinate(latitude: 30.2893502158883, longitude: -97.7375839368349)),
    Node(id: 59, abbr: nil, point: Coordinate(latitude: 30.2894400716917, longitude: -97.7375796306321)),
    Node(id: 60, abbr: "MBB", point: Coordinate(latitude: 30.2891459049084, longitude: -97.7372355535072)),
    Node(id: 61, abbr: "MBB", point: Coordinate(latitude: 30.2889359933216, longitude: -97.7370508163614)),
    Node(id: 62, abbr: "NMS", point: Coordinate(latitude: 30.2890778614681, longitude: -97.7376401165411)),
    Node(id: 63, abbr: nil, point: Coordinate(latitude: 30.2889708519574, longitude: -97.7376441084225)),
    Node(id: 64, abbr: nil, point: Coordinate(latitude: 30.2888884777152, longitude: -97.7373597628349)),
    Node(id: 65, abbr: nil, point: Coordinate(latitude: 30.2884877470752, longitude: -97.7373952811497)),
    Node(id: 66, abbr: "AHG", point: Coordinate(latitude: 30.2885427177517, longitude: -97.7377985921368)),
    Node(id: 67, abbr: "AHG", point: Coordinate(latitude: 30.2883794431719, longitude: -97.7378886452089)),
    Node(id: 68, abbr: nil, point: Coordinate(latitude: 30.2833030219496, longitude: -97.7278376727988)),
    Node(id: 69, abbr: nil, point: Coordinate(latitude: 30.2880206172186, longitude: -97.7374541063939)),
    Node(id: 70, abbr: nil, point: Coordinate(latitude: 30.2880735131151, longitude: -97.7380753982971)),
    Node(id: 71, abbr: nil, point: Coordinate(latitude: 30.2884641623586, longitude: -97.7382849249216)),
    Node(id: 72, abbr: nil, point: Coordinate(latitude: 30.2885367840977, longitude: -97.738985473911)),
    Node(id: 73, abbr: "BUR", point: Coordinate(latitude: 30.2886362216005, longitude: -97.7386096398503)),
    Node(id: 74, abbr: "BUR", point: Coordinate(latitude: 30.289078039183, longitude: -97.7381466025645)),
    Node(id: 75, abbr: nil, point: Coordinate(latitude: 30.2886679750955, longitude: -97.7403899529324)),
    Node(id: 76, abbr: nil, point: Coordinate(latitude: 30.2883551325844, longitude: -97.7404223070785)),
    Node(id: 77, abbr: nil, point: Coordinate(latitude: 30.2877249209428, longitude: -97.7405409738727)),
    Node(id: 78, abbr: "LFH", point: Coordinate(latitude: 30.287997659103, longitude: -97.740760118731)),
    Node(id: 79, abbr: "LCH", point: Coordinate(latitude: 30.2885015794457, longitude: -97.7408339004336)),
    Node(id: 80, abbr: nil, point: Coordinate(latitude: 30.2876840997214, longitude: -97.7403836455501)),
    Node(id: 81, abbr: "CSS", point: Coordinate(latitude: 30.2882620911711, longitude: -97.7402940534826)),
    Node(id: 82, abbr: "GWB", point: Coordinate(latitude: 30.2876646390666, longitude: -97.7399551940923)),
    Node(id: 83, abbr: nil, point: Coordinate(latitude: 30.287609667898, longitude: -97.7399555503232)),
    Node(id: 84, abbr: nil, point: Coordinate(latitude: 30.2877494390003, longitude: -97.7414868611689)),
    Node(id: 85, abbr: nil, point: Coordinate(latitude: 30.2887233527937, longitude: -97.7414161179061)),
    Node(id: 86, abbr: nil, point: Coordinate(latitude: 30.2876102599027, longitude: -97.7414722715716)),
    Node(id: 87, abbr: nil, point: Coordinate(latitude: 30.2875408854481, longitude: -97.7405335612807)),
    Node(id: 88, abbr: nil, point: Coordinate(latitude: 30.2875287621034, longitude: -97.7403704075355)),
    Node(id: 89, abbr: nil, point: Coordinate(latitude: 30.2874675844258, longitude: -97.7397504505449)),
    Node(id: 90, abbr: "BIO", point: Coordinate(latitude: 30.2873027157329, longitude: -97.7397622585511)),
    Node(id: 91, abbr: "BIO", point: Coordinate(latitude: 30.2871296227588, longitude: -97.7399605429479)),
    Node(id: 92, abbr: "BIO", point: Coordinate(latitude: 30.2871022998801, longitude: -97.7396155123813)),
    Node(id: 93, abbr: "BOT", point: Coordinate(latitude: 30.2870922664105, longitude: -97.7399636652068)),
    Node(id: 94, abbr: nil, point: Coordinate(latitude: 30.28706292597, longitude: -97.7393377884972)),
    Node(id: 95, abbr: nil, point: Coordinate(latitude: 30.2871445689131, longitude: -97.7402547582265)),
    Node(id: 96, abbr: nil, point: Coordinate(latitude: 30.2866658113372, longitude: -97.7393728562848)),
    Node(id: 97, abbr: nil, point: Coordinate(latitude: 30.2867576962046, longitude: -97.7401623896538)),
    Node(id: 98, abbr: "PAI", point: Coordinate(latitude: 30.2870359378235, longitude: -97.7389216060503)),
    Node(id: 99, abbr: nil, point: Coordinate(latitude: 30.2866254420427, longitude: -97.7389302289332)),
    Node(id: 100, abbr: "BGH", point: Coordinate(latitude: 30.2869237872028, longitude: -97.7388678466188)),
    Node(id: 101, abbr: "HMA", point: Coordinate(latitude: 30.2868620143704, longitude: -97.7403662146931)),
    Node(id: 102, abbr: "FAC", point: Coordinate(latitude: 30.2865658494366, longitude: -97.7401179427212)),
    Node(id: 103, abbr: "FAC", point: Coordinate(latitude: 30.2859713726489, longitude: -97.7402771674493)),
    Node(id: 104, abbr: nil, point: Coordinate(latitude: 30.2866704911647, longitude: -97.7406567209795)),
    Node(id: 105, abbr: nil, point: Coordinate(latitude: 30.2859993110668, longitude: -97.7406798445549)),
    Node(id: 106, abbr: nil, point: Coordinate(latitude: 30.2858392893282, longitude: -97.7410361592586)),
    Node(id: 107, abbr: "UNB", point: Coordinate(latitude: 30.2860207805775, longitude: -97.741248891961)),
    Node(id: 108, abbr: "UNB", point: Coordinate(latitude: 30.2866209388058, longitude: -97.7409603135123)),
    Node(id: 109, abbr: "UNB", point: Coordinate(latitude: 30.2870346102143, longitude: -97.741126107557)),
    Node(id: 110, abbr: nil, point: Coordinate(latitude: 30.2870697590397, longitude: -97.7414941674025)),
    Node(id: 111, abbr: nil, point: Coordinate(latitude: 30.2859009022969, longitude: -97.7416185443684)),
    Node(id: 112, abbr: nil, point: Coordinate(latitude: 30.2852143090658, longitude: -97.7416573316254)),
    Node(id: 113, abbr: "GOL", point: Coordinate(latitude: 30.2852357154158, longitude: -97.7414623266481)),
    Node(id: 114, abbr: "GOL", point: Coordinate(latitude: 30.2854853351884, longitude: -97.7412090674437)),
    Node(id: 115, abbr: "GOL", point: Coordinate(latitude: 30.2854769934288, longitude: -97.7409574217557)),
    Node(id: 116, abbr: "GOL", point: Coordinate(latitude: 30.2854501767478, longitude: -97.7408410599849)),
    Node(id: 117, abbr: nil, point: Coordinate(latitude: 30.2851477285924, longitude: -97.7407190194749)),
    Node(id: 118, abbr: nil, point: Coordinate(latitude: 30.2851345102052, longitude: -97.7412263970285)),
    Node(id: 119, abbr: nil, point: Coordinate(latitude: 30.2850175893762, longitude: -97.7416579183584)),
    Node(id: 120, abbr: "WMB", point: Coordinate(latitude: 30.2852326121289, longitude: -97.7406463798066)),
    Node(id: 121, abbr: nil, point: Coordinate(latitude: 30.2850665001725, longitude: -97.7402323661769)),
    Node(id: 122, abbr: "BTL", point: Coordinate(latitude: 30.2852265412666, longitude: -97.7403078242602)),
    Node(id: 123, abbr: nil, point: Coordinate(latitude: 30.2846003175878, longitude: -97.7407591059276)),
    Node(id: 124, abbr: "SUT", point: Coordinate(latitude: 30.2848693911427, longitude: -97.7407125025459)),
    Node(id: 125, abbr: "SUT", point: Coordinate(latitude: 30.2850675134923, longitude: -97.7407238181152)),
    Node(id: 126, abbr: "HRC", point: Coordinate(latitude: 30.2843326999534, longitude: -97.7408672953427)),
    Node(id: 127, abbr: "HRC", point: Coordinate(latitude: 30.2843766258838, longitude: -97.7414622218749)),
    Node(id: 128, abbr: nil, point: Coordinate(latitude: 30.2838304501003, longitude: -97.7405996087876)),
    Node(id: 129, abbr: nil, point: Coordinate(latitude: 30.2839135071601, longitude: -97.7418095469874)),
    Node(id: 130, abbr: nil, point: Coordinate(latitude: 30.2837417472544, longitude: -97.7397809902143)),
    Node(id: 131, abbr: nil, point: Coordinate(latitude: 30.2837262215338, longitude: -97.739413653308)),
    Node(id: 132, abbr: nil, point: Coordinate(latitude: 30.2840781372639, longitude: -97.7393251613653)),
    Node(id: 133, abbr: nil, point: Coordinate(latitude: 30.2841170871353, longitude: -97.7398131452904)),
    Node(id: 134, abbr: "MTC", point: Coordinate(latitude: 30.2833079981639, longitude: -97.7274498002295)),
    Node(id: 135, abbr: nil, point: Coordinate(latitude: 30.284981580302, longitude: -97.7397300387205)),
    Node(id: 136, abbr: nil, point: Coordinate(latitude: 30.2845120044826, longitude: -97.7397516116438)),
    Node(id: 137, abbr: nil, point: Coordinate(latitude: 30.2844937917608, longitude: -97.7393760290401)),
    Node(id: 138, abbr: nil, point: Coordinate(latitude: 30.284958301062, longitude: -97.7393407831373)),
    Node(id: 139, abbr: "CAL", point: Coordinate(latitude: 30.2844705938331, longitude: -97.7398706661009)),
    Node(id: 140, abbr: "PAR", point: Coordinate(latitude: 30.2848731820527, longitude: -97.739828808972)),
    Node(id: 141, abbr: "PAR", point: Coordinate(latitude: 30.2845845477195, longitude: -97.7402984679613)),
    Node(id: 142, abbr: "PAR", point: Coordinate(latitude: 30.2848937199156, longitude: -97.7402219726175)),
    Node(id: 143, abbr: "CAL", point: Coordinate(latitude: 30.2844717700152, longitude: -97.7402859789256)),
    Node(id: 144, abbr: "HRH", point: Coordinate(latitude: 30.2840943595932, longitude: -97.7403077299643)),
    Node(id: 145, abbr: "HRH", point: Coordinate(latitude: 30.2840438740308, longitude: -97.7399038479601)),
    Node(id: 147, abbr: "BAT", point: Coordinate(latitude: 30.2848287044458, longitude: -97.7391578900101)),
    Node(id: 146, abbr: "BAT", point: Coordinate(latitude: 30.2847783368792, longitude: -97.7386358546033)),
    Node(id: 148, abbr: "MEZ", point: Coordinate(latitude: 30.2844198732279, longitude: -97.7388229910687)),
    Node(id: 149, abbr: "MEZ", point: Coordinate(latitude: 30.2843915815053, longitude: -97.7386789690175)),
    Node(id: 150, abbr: "MEZ", point: Coordinate(latitude: 30.2844056504634, longitude: -97.7391965934477)),
    Node(id: 151, abbr: "BEN", point: Coordinate(latitude: 30.2838927338544, longitude: -97.7391469201941)),
    Node(id: 152, abbr: "BEN", point: Coordinate(latitude: 30.2839825132283, longitude: -97.7387192859718)),
    Node(id: 153, abbr: nil, point: Coordinate(latitude: 30.2845709944975, longitude: -97.7384750268364)),
    Node(id: 154, abbr: "GSB", point: Coordinate(latitude: 30.2844629848394, longitude: -97.7382377770672)),
    Node(id: 155, abbr: nil, point: Coordinate(latitude: 30.2853250592823, longitude: -97.7394704092707)),
    Node(id: 156, abbr: "MAI", point: Coordinate(latitude: 30.2857736683066, longitude: -97.7394260061386)),
    Node(id: 157, abbr: "MAI", point: Coordinate(latitude: 30.2861852714341, longitude: -97.7393831955681)),
    Node(id: 158, abbr: "GSB", point: Coordinate(latitude: 30.284028129675, longitude: -97.7381393241062)),
    Node(id: 159, abbr: "CBA", point: Coordinate(latitude: 30.284277689187, longitude: -97.7380357866474)),
    Node(id: 160, abbr: "CBA", point: Coordinate(latitude: 30.2844006999067, longitude: -97.7375354184603)),
    Node(id: 161, abbr: "CBA", point: Coordinate(latitude: 30.2839908626217, longitude: -97.7375685479325)),
    Node(id: 162, abbr: nil, point: Coordinate(latitude: 30.2836205979802, longitude: -97.7383236421573)),
    Node(id: 163, abbr: nil, point: Coordinate(latitude: 30.2836613666068, longitude: -97.7387553625574)),
    Node(id: 164, abbr: nil, point: Coordinate(latitude: 30.2874878143196, longitude: -97.7392458761322)),
    Node(id: 165, abbr: "GEA", point: Coordinate(latitude: 30.2876852618841, longitude: -97.7392241250935)),
    Node(id: 166, abbr: "FNT", point: Coordinate(latitude: 30.2877760510795, longitude: -97.7376859201331)),
    Node(id: 167, abbr: nil, point: Coordinate(latitude: 30.2879931396021, longitude: -97.7376023106492)),
    Node(id: 168, abbr: "FNT", point: Coordinate(latitude: 30.2877783038448, longitude: -97.7379773903386)),
    Node(id: 169, abbr: "NHB", point: Coordinate(latitude: 30.2874905737391, longitude: -97.737989732691)),
    Node(id: 170, abbr: nil, point: Coordinate(latitude: 30.2874215119733, longitude: -97.7379851668801)),
    Node(id: 171, abbr: nil, point: Coordinate(latitude: 30.2862580538448, longitude: -97.7388878149875)),
    Node(id: 172, abbr: nil, point: Coordinate(latitude: 30.2861518012396, longitude: -97.7387142257729)),
    Node(id: 173, abbr: nil, point: Coordinate(latitude: 30.2859325553564, longitude: -97.7387542179284)),
    Node(id: 174, abbr: "GEB", point: Coordinate(latitude: 30.2862697340245, longitude: -97.7386022959335)),
    Node(id: 175, abbr: nil, point: Coordinate(latitude: 30.2859261407355, longitude: -97.7384059708065)),
    Node(id: 176, abbr: "WCH", point: Coordinate(latitude: 30.2859904588272, longitude: -97.7383990976459)),
    Node(id: 177, abbr: "WCH", point: Coordinate(latitude: 30.2861742478358, longitude: -97.7381831798203)),
    Node(id: 178, abbr: "COM", point: Coordinate(latitude: 30.285860239302, longitude: -97.7386592823976)),
    Node(id: 179, abbr: "COM", point: Coordinate(latitude: 30.2856462402862, longitude: -97.7384571737575)),
    Node(id: 180, abbr: nil, point: Coordinate(latitude: 30.2854722215483, longitude: -97.7388503059708)),
    Node(id: 181, abbr: "GAR", point: Coordinate(latitude: 30.2851534789294, longitude: -97.7381758875645)),
    Node(id: 182, abbr: "GAR", point: Coordinate(latitude: 30.2851649692433, longitude: -97.7387357567867)),
    Node(id: 183, abbr: nil, point: Coordinate(latitude: 30.2865753724403, longitude: -97.7384138602732)),
    Node(id: 184, abbr: nil, point: Coordinate(latitude: 30.287273853341, longitude: -97.7383307117937)),
    Node(id: 185, abbr: nil, point: Coordinate(latitude: 30.2863734803788, longitude: -97.7381045575688)),
    Node(id: 186, abbr: "WEL", point: Coordinate(latitude: 30.2867758074643, longitude: -97.7380363393544)),
    Node(id: 187, abbr: "WEL", point: Coordinate(latitude: 30.2867537500415, longitude: -97.7375638829049)),
    Node(id: 188, abbr: "WEL", point: Coordinate(latitude: 30.286699076925, longitude: -97.7372938598943)),
    Node(id: 189, abbr: "WEL", point: Coordinate(latitude: 30.2857425503065, longitude: -97.7375106054329)),
    Node(id: 190, abbr: "WEL", point: Coordinate(latitude: 30.2860801186661, longitude: -97.7373475669389)),
    Node(id: 191, abbr: "WEL", point: Coordinate(latitude: 30.2865273852275, longitude: -97.7374725725473)),
    Node(id: 192, abbr: nil, point: Coordinate(latitude: 30.2858346984141, longitude: -97.7379184269316)),
    Node(id: 193, abbr: nil, point: Coordinate(latitude: 30.2855981169081, longitude: -97.7378991590317)),
    Node(id: 194, abbr: nil, point: Coordinate(latitude: 30.2856156689611, longitude: -97.7374565316801)),
    Node(id: 195, abbr: nil, point: Coordinate(latitude: 30.2851458880843, longitude: -97.7379933821008)),
    Node(id: 196, abbr: "WAG", point: Coordinate(latitude: 30.2851222650785, longitude: -97.7376917802697)),
    Node(id: 197, abbr: "WAG", point: Coordinate(latitude: 30.285264790159, longitude: -97.737453325602)),
    Node(id: 198, abbr: "WAG", point: Coordinate(latitude: 30.2849277256547, longitude: -97.737491756628)),
    Node(id: 199, abbr: nil, point: Coordinate(latitude: 30.2848576435968, longitude: -97.7382500883624)),
    Node(id: 200, abbr: nil, point: Coordinate(latitude: 30.2847341810736, longitude: -97.7372988995135)),
    Node(id: 201, abbr: nil, point: Coordinate(latitude: 30.2839803379371, longitude: -97.7373557078624)),
    Node(id: 202, abbr: "GRE", point: Coordinate(latitude: 30.284216353347, longitude: -97.7368185535978)),
    Node(id: 203, abbr: nil, point: Coordinate(latitude: 30.2845820376829, longitude: -97.7366241563086)),
    Node(id: 204, abbr: "WCP", point: Coordinate(latitude: 30.2847528913648, longitude: -97.7365316620071)),
    Node(id: 205, abbr: "GRP", point: Coordinate(latitude: 30.2844424701618, longitude: -97.7359129727791)),
    Node(id: 206, abbr: "WCP", point: Coordinate(latitude: 30.2848797376361, longitude: -97.7358173143095)),
    Node(id: 207, abbr: "WCP", point: Coordinate(latitude: 30.2849666661416, longitude: -97.7366154600844)),
    Node(id: 208, abbr: "RLP", point: Coordinate(latitude: 30.2849084906412, longitude: -97.7354367339961)),
    Node(id: 209, abbr: "RLP", point: Coordinate(latitude: 30.2852447680806, longitude: -97.7354224009417)),
    Node(id: 210, abbr: nil, point: Coordinate(latitude: 30.2854951478168, longitude: -97.7372168406825)),
    Node(id: 211, abbr: "BRB", point: Coordinate(latitude: 30.2852537431838, longitude: -97.7369946783389)),
    Node(id: 212, abbr: nil, point: Coordinate(latitude: 30.2854152768047, longitude: -97.7359022439437)),
    Node(id: 213, abbr: "EPS", point: Coordinate(latitude: 30.2857991420124, longitude: -97.736949395107)),
    Node(id: 214, abbr: "EPS", point: Coordinate(latitude: 30.2857508649019, longitude: -97.7363487269708)),
    Node(id: 215, abbr: nil, point: Coordinate(latitude: 30.2862892311473, longitude: -97.737096979467)),
    Node(id: 216, abbr: "GDC", point: Coordinate(latitude: 30.286252363038, longitude: -97.7365651267562)),
    Node(id: 217, abbr: "GDC", point: Coordinate(latitude: 30.2862363491556, longitude: -97.7364244260341)),
    Node(id: 218, abbr: "GDC", point: Coordinate(latitude: 30.2859837727892, longitude: -97.7366407734323)),
    Node(id: 219, abbr: "POB", point: Coordinate(latitude: 30.2865558301401, longitude: -97.736619892016)),
    Node(id: 220, abbr: "POB", point: Coordinate(latitude: 30.287137827148, longitude: -97.7365329716802)),
    Node(id: 221, abbr: nil, point: Coordinate(latitude: 30.285867033921, longitude: -97.7362139250136)),
    Node(id: 222, abbr: nil, point: Coordinate(latitude: 30.2859446427106, longitude: -97.7371187828928)),
    Node(id: 223, abbr: "JGB", point: Coordinate(latitude: 30.2855979992922, longitude: -97.7358344238703)),
    Node(id: 224, abbr: "JGB", point: Coordinate(latitude: 30.2858715576339, longitude: -97.7360015171099)),
    Node(id: 225, abbr: nil, point: Coordinate(latitude: 30.2879953062788, longitude: -97.7391856389715)),
    Node(id: 226, abbr: nil, point: Coordinate(latitude: 30.2879134107211, longitude: -97.7395591051445)),
    Node(id: 227, abbr: nil, point: Coordinate(latitude: 30.2878632890137, longitude: -97.7388528145514)),
    Node(id: 228, abbr: nil, point: Coordinate(latitude: 30.2874741392256, longitude: -97.7388833980206)),
    Node(id: 229, abbr: "FNT", point: Coordinate(latitude: 30.287877779887, longitude: -97.7381511094455)),
    Node(id: 230, abbr: nil, point: Coordinate(latitude: 30.2873417064675, longitude: -97.7370052833967)),
    Node(id: 231, abbr: nil, point: Coordinate(latitude: 30.2877285768742, longitude: -97.7369737464869)),
    Node(id: 232, abbr: "PAT", point: Coordinate(latitude: 30.2878161037276, longitude: -97.736562065942)),
    Node(id: 233, abbr: "GLT", point: Coordinate(latitude: 30.2875026975692, longitude: -97.736216501029)),
    Node(id: 234, abbr: nil, point: Coordinate(latitude: 30.2877208633201, longitude: -97.7362524698709)),
    Node(id: 235, abbr: nil, point: Coordinate(latitude: 30.2879416522838, longitude: -97.7358804495762)),
    Node(id: 236, abbr: nil, point: Coordinate(latitude: 30.2886610586061, longitude: -97.7368126534146)),
    Node(id: 237, abbr: nil, point: Coordinate(latitude: 30.2886604524459, longitude: -97.7364084151796)),
    Node(id: 238, abbr: "PMA", point: Coordinate(latitude: 30.2888905578568, longitude: -97.7362280366234)),
    Node(id: 239, abbr: "PMA", point: Coordinate(latitude: 30.2886858297499, longitude: -97.7360832497235)),
    Node(id: 240, abbr: "EER", point: Coordinate(latitude: 30.2885487017583, longitude: -97.7357710343082)),
    Node(id: 241, abbr: nil, point: Coordinate(latitude: 30.288336708038, longitude: -97.7360688433278)),
    Node(id: 242, abbr: "ECJ", point: Coordinate(latitude: 30.2888287567751, longitude: -97.7357762310882)),
    Node(id: 243, abbr: "ECJ", point: Coordinate(latitude: 30.289172502746, longitude: -97.7353431905383)),
    Node(id: 244, abbr: nil, point: Coordinate(latitude: 30.287250821105, longitude: -97.7357570155754)),
    Node(id: 245, abbr: "PPE", point: Coordinate(latitude: 30.2871085612818, longitude: -97.7358322641112)),
    Node(id: 246, abbr: "PPL", point: Coordinate(latitude: 30.2870314781574, longitude: -97.7351000839143)),
    Node(id: 247, abbr: nil, point: Coordinate(latitude: 30.2871357755911, longitude: -97.7346766930303)),
    Node(id: 248, abbr: "CT1", point: Coordinate(latitude: 30.2869293338768, longitude: -97.734704499994)),
    Node(id: 249, abbr: "PPA", point: Coordinate(latitude: 30.2869703001697, longitude: -97.7344243348805)),
    Node(id: 250, abbr: "PA4", point: Coordinate(latitude: 30.2866477625292, longitude: -97.7345787295369)),
    Node(id: 251, abbr: "PA3", point: Coordinate(latitude: 30.2864474720015, longitude: -97.7345816212935)),
    Node(id: 252, abbr: "PA1", point: Coordinate(latitude: 30.2863278656643, longitude: -97.7345751672281)),
    Node(id: 253, abbr: "PB6", point: Coordinate(latitude: 30.2863369130474, longitude: -97.7348607596239)),
    Node(id: 254, abbr: "PB5", point: Coordinate(latitude: 30.2863153621795, longitude: -97.734765101154)),
    Node(id: 255, abbr: "CT2", point: Coordinate(latitude: 30.2864549813204, longitude: -97.7344273942751)),
    Node(id: 256, abbr: "PB2", point: Coordinate(latitude: 30.2866063075446, longitude: -97.734247660078)),
    Node(id: 257, abbr: "E23", point: Coordinate(latitude: 30.2861797417899, longitude: -97.7350319285644)),
    Node(id: 258, abbr: nil, point: Coordinate(latitude: 30.2855490095153, longitude: -97.734993958543)),
    Node(id: 259, abbr: "LTH", point: Coordinate(latitude: 30.2859524347198, longitude: -97.7350731046638)),
    Node(id: 260, abbr: "WIN", point: Coordinate(latitude: 30.2857040284928, longitude: -97.7347790884552)),
    Node(id: 261, abbr: "D21", point: Coordinate(latitude: 30.2836869400739, longitude: -97.7416976120878)),
    Node(id: 262, abbr: "D21", point: Coordinate(latitude: 30.2834138280233, longitude: -97.7408582483041)),
    Node(id: 263, abbr: nil, point: Coordinate(latitude: 30.2827259145161, longitude: -97.7419520657134)),
    Node(id: 264, abbr: nil, point: Coordinate(latitude: 30.2826429831189, longitude: -97.7409180112741)),
    Node(id: 265, abbr: nil, point: Coordinate(latitude: 30.2821146489404, longitude: -97.740991772022)),
    Node(id: 266, abbr: "RRH", point: Coordinate(latitude: 30.2821823262519, longitude: -97.741406099973)),
    Node(id: 267, abbr: "RHG", point: Coordinate(latitude: 30.282281082566, longitude: -97.7415606936996)),
    Node(id: 268, abbr: nil, point: Coordinate(latitude: 30.2816203030341, longitude: -97.7410250344731)),
    Node(id: 269, abbr: nil, point: Coordinate(latitude: 30.2818766092772, longitude: -97.7418998013199)),
    Node(id: 270, abbr: "ATT", point: Coordinate(latitude: 30.2815352806551, longitude: -97.7405789600637)),
    Node(id: 271, abbr: nil, point: Coordinate(latitude: 30.2808467930084, longitude: -97.7384680196598)),
    Node(id: 272, abbr: nil, point: Coordinate(latitude: 30.28067940692, longitude: -97.7379327303685)),
    Node(id: 273, abbr: nil, point: Coordinate(latitude: 30.2812742324475, longitude: -97.7378628462508)),
    Node(id: 274, abbr: "BMS", point: Coordinate(latitude: 30.2810795949151, longitude: -97.7380083979994)),
    Node(id: 275, abbr: "BMA", point: Coordinate(latitude: 30.2809908171991, longitude: -97.7377732437059)),
    Node(id: 276, abbr: "BMK", point: Coordinate(latitude: 30.2815672013784, longitude: -97.737834871649)),
    Node(id: 277, abbr: "SZB", point: Coordinate(latitude: 30.2818042359467, longitude: -97.7384426644028)),
    Node(id: 278, abbr: nil, point: Coordinate(latitude: 30.2832302313525, longitude: -97.7374333784876)),
    Node(id: 279, abbr: "PCL", point: Coordinate(latitude: 30.2830460930166, longitude: -97.7381143243014)),
    Node(id: 280, abbr: "UTC", point: Coordinate(latitude: 30.2834278865343, longitude: -97.7387088317386)),
    Node(id: 281, abbr: nil, point: Coordinate(latitude: 30.28177408867, longitude: -97.7374706360472)),
    Node(id: 282, abbr: "JES", point: Coordinate(latitude: 30.28303458436, longitude: -97.737116437774)),
    Node(id: 283, abbr: "JES", point: Coordinate(latitude: 30.2828302964175, longitude: -97.7368255123919)),
    Node(id: 284, abbr: "JCD", point: Coordinate(latitude: 30.2824387652045, longitude: -97.7369056119541)),
    Node(id: 285, abbr: "JCD", point: Coordinate(latitude: 30.2819491273205, longitude: -97.7372538485988)),
    Node(id: 286, abbr: "JCD", point: Coordinate(latitude: 30.2819582203464, longitude: -97.7360850341113)),
    Node(id: 287, abbr: "JCD", point: Coordinate(latitude: 30.2826177022382, longitude: -97.736339215325)),
    Node(id: 288, abbr: "JCD", point: Coordinate(latitude: 30.2824846010559, longitude: -97.7359876783059)),
    Node(id: 289, abbr: "JCD", point: Coordinate(latitude: 30.2822189319674, longitude: -97.7354727360848)),
    Node(id: 290, abbr: nil, point: Coordinate(latitude: 30.2815586240436, longitude: -97.7357843542898)),
    Node(id: 291, abbr: "BRG", point: Coordinate(latitude: 30.2812949248788, longitude: -97.7359411796981)),
    Node(id: 292, abbr: "BSB", point: Coordinate(latitude: 30.2814382969676, longitude: -97.7354865557476)),
    Node(id: 293, abbr: "CS3", point: Coordinate(latitude: 30.280905504744, longitude: -97.7354931984058)),
    Node(id: 294, abbr: nil, point: Coordinate(latitude: 30.2819524840499, longitude: -97.7352042951583)),
    Node(id: 295, abbr: "CLK", point: Coordinate(latitude: 30.2817090801822, longitude: -97.7349366505127)),
    Node(id: 296, abbr: nil, point: Coordinate(latitude: 30.2827450579422, longitude: -97.7352697578222)),
    Node(id: 297, abbr: "RHD", point: Coordinate(latitude: 30.2830106622723, longitude: -97.7350707923957)),
    Node(id: 298, abbr: "PHD", point: Coordinate(latitude: 30.2826072973534, longitude: -97.7350797296)),
    Node(id: 299, abbr: "SJH", point: Coordinate(latitude: 30.2819098327729, longitude: -97.7343819990255)),
    Node(id: 300, abbr: nil, point: Coordinate(latitude: 30.2835325497063, longitude: -97.7373788018217)),
    Node(id: 301, abbr: nil, point: Coordinate(latitude: 30.2833828111285, longitude: -97.736440950676)),
    Node(id: 302, abbr: "BHD", point: Coordinate(latitude: 30.2832276708637, longitude: -97.73612529868)),
    Node(id: 303, abbr: nil, point: Coordinate(latitude: 30.2829324268713, longitude: -97.7362865036328)),
    Node(id: 304, abbr: "LDH", point: Coordinate(latitude: 30.2827189281413, longitude: -97.7359754302513)),
    Node(id: 305, abbr: nil, point: Coordinate(latitude: 30.2825092832824, longitude: -97.7356086591233)),
    Node(id: 306, abbr: nil, point: Coordinate(latitude: 30.2829284730276, longitude: -97.7355690441535)),
    Node(id: 307, abbr: nil, point: Coordinate(latitude: 30.283269670136, longitude: -97.7355230484598)),
    Node(id: 308, abbr: "GRS", point: Coordinate(latitude: 30.2836497346863, longitude: -97.7360465402228)),
    Node(id: 309, abbr: "GRC", point: Coordinate(latitude: 30.2838311304622, longitude: -97.7359134460779)),
    Node(id: 310, abbr: nil, point: Coordinate(latitude: 30.2832305118319, longitude: -97.7346439544558)),
    Node(id: 312, abbr: nil, point: Coordinate(latitude: 30.2836591351739, longitude: -97.7348403214923)),
    Node(id: 311, abbr: nil, point: Coordinate(latitude: 30.2834826881423, longitude: -97.7346671094633)),
    Node(id: 313, abbr: "MHD", point: Coordinate(latitude: 30.2838310309385, longitude: -97.7349885659272)),
    Node(id: 314, abbr: nil, point: Coordinate(latitude: 30.2895598669963, longitude: -97.7370524105144)),
    Node(id: 315, abbr: "SEA", point: Coordinate(latitude: 30.2896921352963, longitude: -97.7370691114564)),
    Node(id: 316, abbr: nil, point: Coordinate(latitude: 30.290759846975, longitude: -97.7374368255486)),
    Node(id: 317, abbr: "ASE", point: Coordinate(latitude: 30.290938054122, longitude: -97.7375055990641)),
    Node(id: 318, abbr: "SWG", point: Coordinate(latitude: 30.2908677411367, longitude: -97.7371920320664)),
    Node(id: 319, abbr: nil, point: Coordinate(latitude: 30.2895660371084, longitude: -97.7366191289847)),
    Node(id: 320, abbr: "CPE", point: Coordinate(latitude: 30.2900118040613, longitude: -97.7361714305815)),
    Node(id: 321, abbr: "ETC", point: Coordinate(latitude: 30.2898295602426, longitude: -97.7356490913306)),
    Node(id: 322, abbr: nil, point: Coordinate(latitude: 30.28952308154, longitude: -97.7357368917665)),
    Node(id: 323, abbr: "ECJ", point: Coordinate(latitude: 30.2892066771919, longitude: -97.7357738664369)),
    Node(id: 324, abbr: "CS5", point: Coordinate(latitude: 30.2905944229021, longitude: -97.7355875157748)),
    Node(id: 325, abbr: "LS1", point: Coordinate(latitude: 30.2905981321679, longitude: -97.7362606349862)),
    Node(id: 326, abbr: "KEY", point: Coordinate(latitude: 30.2906577065769, longitude: -97.7364093613805)),
    Node(id: 327, abbr: "SW7", point: Coordinate(latitude: 30.2908188060919, longitude: -97.7362443845714)),
    Node(id: 328, abbr: "CPB", point: Coordinate(latitude: 30.2910479565101, longitude: -97.736211915174)),
    Node(id: 329, abbr: "ARC", point: Coordinate(latitude: 30.2912039167259, longitude: -97.7361410985696)),
    Node(id: 330, abbr: "EHZ", point: Coordinate(latitude: 30.2902541726894, longitude: -97.7355029777174)),
    Node(id: 331, abbr: "FSB", point: Coordinate(latitude: 30.2903236990242, longitude: -97.7355372649401)),
    Node(id: 332, abbr: nil, point: Coordinate(latitude: 30.2915494276657, longitude: -97.7354037643526)),
    Node(id: 333, abbr: "E26", point: Coordinate(latitude: 30.2925261896633, longitude: -97.7362513738334)),
    Node(id: 334, abbr: nil, point: Coordinate(latitude: 30.2832218080724, longitude: -97.7340453093063)),
    Node(id: 335, abbr: "BEL", point: Coordinate(latitude: 30.2834539893069, longitude: -97.7338330680251)),
    Node(id: 336, abbr: "STD", point: Coordinate(latitude: 30.2836495811782, longitude: -97.7332550100728)),
    Node(id: 337, abbr: "NEZ", point: Coordinate(latitude: 30.284625580417, longitude: -97.7324530086225)),
    Node(id: 338, abbr: "SEZ", point: Coordinate(latitude: 30.2828057412425, longitude: -97.7326187188482)),
    Node(id: 339, abbr: "STD", point: Coordinate(latitude: 30.2836325354408, longitude: -97.7317314105783)),
    Node(id: 340, abbr: "MNC", point: Coordinate(latitude: 30.2825022082542, longitude: -97.7326409937559)),
    Node(id: 341, abbr: nil, point: Coordinate(latitude: 30.2842792399552, longitude: -97.7339541027066)),
    Node(id: 342, abbr: "UTX", point: Coordinate(latitude: 30.2843534843065, longitude: -97.7341520203953)),
    Node(id: 343, abbr: "TCP", point: Coordinate(latitude: 30.2849445961765, longitude: -97.7338880952195)),
    Node(id: 344, abbr: nil, point: Coordinate(latitude: 30.2854110304542, longitude: -97.7337987860412)),
    Node(id: 345, abbr: "WCS", point: Coordinate(latitude: 30.2858446113084, longitude: -97.7337211277082)),
    Node(id: 346, abbr: nil, point: Coordinate(latitude: 30.2853810109507, longitude: -97.7334230672315)),
    Node(id: 347, abbr: "ART", point: Coordinate(latitude: 30.2856466805246, longitude: -97.7333641005427)),
    Node(id: 348, abbr: nil, point: Coordinate(latitude: 30.2857061222291, longitude: -97.7327877189713)),
    Node(id: 349, abbr: nil, point: Coordinate(latitude: 30.2853384787811, longitude: -97.7328606834383)),
    Node(id: 350, abbr: nil, point: Coordinate(latitude: 30.2862761907735, longitude: -97.7325906080409)),
    Node(id: 351, abbr: nil, point: Coordinate(latitude: 30.2866428174039, longitude: -97.7321292052264)),
    Node(id: 352, abbr: nil, point: Coordinate(latitude: 30.2869904161468, longitude: -97.7320183336022)),
    Node(id: 353, abbr: "TMM", point: Coordinate(latitude: 30.2869767094524, longitude: -97.7322540536741)),
    Node(id: 354, abbr: nil, point: Coordinate(latitude: 30.2873505079653, longitude: -97.7319871214903)),
    Node(id: 355, abbr: "DTB", point: Coordinate(latitude: 30.2873179829552, longitude: -97.7322053024298)),
    Node(id: 356, abbr: "SJG", point: Coordinate(latitude: 30.2875475124899, longitude: -97.7324600494219)),
    Node(id: 357, abbr: nil, point: Coordinate(latitude: 30.2870156762675, longitude: -97.7336314727773)),
    Node(id: 358, abbr: nil, point: Coordinate(latitude: 30.2891277865933, longitude: -97.7344037813359)),
    Node(id: 359, abbr: "CRH", point: Coordinate(latitude: 30.2885644928611, longitude: -97.7335133298524)),
    Node(id: 360, abbr: "CRH", point: Coordinate(latitude: 30.2884685022635, longitude: -97.7330036891847)),
    Node(id: 361, abbr: "CS4", point: Coordinate(latitude: 30.288669449108, longitude: -97.7327415242084)),
    Node(id: 362, abbr: "HSS", point: Coordinate(latitude: 30.2883731991589, longitude: -97.7327680634093)),
    Node(id: 363, abbr: "E24", point: Coordinate(latitude: 30.2881087131071, longitude: -97.7322925685199)),
    Node(id: 364, abbr: "TS1", point: Coordinate(latitude: 30.2882138417388, longitude: -97.7331127796545)),
    Node(id: 365, abbr: "SJG", point: Coordinate(latitude: 30.2876756579533, longitude: -97.7333198545722)),
    Node(id: 366, abbr: nil, point: Coordinate(latitude: 30.2881239486232, longitude: -97.7338960161187)),
    Node(id: 367, abbr: "JON", point: Coordinate(latitude: 30.2882388120342, longitude: -97.7317486458683)),
    Node(id: 368, abbr: nil, point: Coordinate(latitude: 30.2878736298799, longitude: -97.7319827209917)),
    Node(id: 369, abbr: "TNH", point: Coordinate(latitude: 30.2886236251938, longitude: -97.7312014542746)),
    Node(id: 370, abbr: "CCJ", point: Coordinate(latitude: 30.2882158773611, longitude: -97.7304379257602)),
    Node(id: 371, abbr: "MRH", point: Coordinate(latitude: 30.2872884661603, longitude: -97.7315150317499)),
    Node(id: 372, abbr: "PAC", point: Coordinate(latitude: 30.2866392844123, longitude: -97.7312395709797)),
    Node(id: 373, abbr: "DFA", point: Coordinate(latitude: 30.2860090979374, longitude: -97.7317607367641)),
    Node(id: 374, abbr: nil, point: Coordinate(latitude: 30.281811587588, longitude: -97.7332059340321)),
    Node(id: 375, abbr: "RSC", point: Coordinate(latitude: 30.2814329364276, longitude: -97.7329524233707)),
    Node(id: 376, abbr: nil, point: Coordinate(latitude: 30.2807057592414, longitude: -97.7335674874257)),
    Node(id: 377, abbr: "TSC", point: Coordinate(latitude: 30.2801235431188, longitude: -97.7332441136013)),
    Node(id: 378, abbr: "TSP", point: Coordinate(latitude: 30.2802732685746, longitude: -97.7337453095015)),
    Node(id: 379, abbr: nil, point: Coordinate(latitude: 30.2810549714443, longitude: -97.7318710007009)),
    Node(id: 380, abbr: "MCA", point: Coordinate(latitude: 30.2809670300831, longitude: -97.7306752140274)),
    Node(id: 381, abbr: nil, point: Coordinate(latitude: 30.2799731880491, longitude: -97.7322452702204)),
    Node(id: 382, abbr: "TS2", point: Coordinate(latitude: 30.2796573591172, longitude: -97.7316569863463)),
    Node(id: 383, abbr: "BBR", point: Coordinate(latitude: 30.2803331156161, longitude: -97.7317674388754)),
    Node(id: 384, abbr: "CS7", point: Coordinate(latitude: 30.2802452601151, longitude: -97.7314649569446)),
    Node(id: 385, abbr: "CT7", point: Coordinate(latitude: 30.2800084027401, longitude: -97.7311814600246)),
    Node(id: 386, abbr: "MFH", point: Coordinate(latitude: 30.2819808830818, longitude: -97.7311463935486)),
    Node(id: 387, abbr: "MAG", point: Coordinate(latitude: 30.2827361711195, longitude: -97.7309523524902)),
    Node(id: 388, abbr: nil, point: Coordinate(latitude: 30.2839233285282, longitude: -97.7310910539831)),
    Node(id: 389, abbr: "UPB", point: Coordinate(latitude: 30.284060779651, longitude: -97.7303984992336)),
    Node(id: 390, abbr: "MMS", point: Coordinate(latitude: 30.2835942846682, longitude: -97.7304596871267)),
    Node(id: 391, abbr: "MMS", point: Coordinate(latitude: 30.2833326357453, longitude: -97.729557312386)),
    Node(id: 392, abbr: "MMS", point: Coordinate(latitude: 30.2833118170781, longitude: -97.7290691922549)),
    Node(id: 393, abbr: "MMS", point: Coordinate(latitude: 30.2830793461842, longitude: -97.7290596578401)),
    Node(id: 394, abbr: "MMS", point: Coordinate(latitude: 30.2823685757214, longitude: -97.7291676167529)),
    Node(id: 395, abbr: "MMS", point: Coordinate(latitude: 30.2816463093852, longitude: -97.729556285603)),
    Node(id: 396, abbr: nil, point: Coordinate(latitude: 30.2852055097773, longitude: -97.7307284026102)),
    Node(id: 397, abbr: nil, point: Coordinate(latitude: 30.2848175889568, longitude: -97.7297758621788)),
    Node(id: 398, abbr: "LBJ", point: Coordinate(latitude: 30.28562916649, longitude: -97.7293663852541)),
    Node(id: 399, abbr: "SRH", point: Coordinate(latitude: 30.2848709512317, longitude: -97.7290607810644)),
    Node(id: 400, abbr: nil, point: Coordinate(latitude: 30.2868123484083, longitude: -97.7301624774623)),
    Node(id: 401, abbr: "TCC", point: Coordinate(latitude: 30.2869717623892, longitude: -97.729138963266)),
    Node(id: 402, abbr: "E11", point: Coordinate(latitude: 30.2873188714129, longitude: -97.7291240853879)),
    Node(id: 403, abbr: nil, point: Coordinate(latitude: 30.286535915628, longitude: -97.7289676790749)),
    Node(id: 404, abbr: nil, point: Coordinate(latitude: 30.2861155198962, longitude: -97.7273239249985)),
    Node(id: 405, abbr: "G11", point: Coordinate(latitude: 30.286584717099, longitude: -97.7271374695624)),
    Node(id: 406, abbr: nil, point: Coordinate(latitude: 30.2856866177672, longitude: -97.7270288400972)),
    Node(id: 407, abbr: "IPF", point: Coordinate(latitude: 30.2862485890107, longitude: -97.7265615909049)),
    Node(id: 408, abbr: "AF1", point: Coordinate(latitude: 30.2866046031939, longitude: -97.7259313136958)),
    Node(id: 409, abbr: "PH1", point: Coordinate(latitude: 30.2855732713401, longitude: -97.7264302883917)),
    Node(id: 410, abbr: "AFP", point: Coordinate(latitude: 30.2852773648925, longitude: -97.726337982683)),
    Node(id: 411, abbr: "AF2", point: Coordinate(latitude: 30.2847613495384, longitude: -97.7264850850839)),
    Node(id: 412, abbr: "PH2", point: Coordinate(latitude: 30.2846047728942, longitude: -97.7265434440847)),
    Node(id: 413, abbr: "PHR", point: Coordinate(latitude: 30.288317, longitude: -97.738337))
]


let pathways: [Pathway] = [
    Pathway(from: 0, to: 1, distance: 17.184114),
    Pathway(from: 1, to: 2, distance: 65.687508),
    Pathway(from: 1, to: 3, distance: 8.229268),
    Pathway(from: 3, to: 4, distance: 64.063736),
    Pathway(from: 3, to: 5, distance: 92.815601),
    Pathway(from: 5, to: 6, distance: 63.787119),
    Pathway(from: 8, to: 7, distance: 20.413037),
    Pathway(from: 4, to: 8, distance: 45.455212),
    Pathway(from: 6, to: 8, distance: 51.845807),
    Pathway(from: 6, to: 4, distance: 93.993441),
    Pathway(from: 5, to: 9, distance: 11.822731),
    Pathway(from: 9, to: 14, distance: 76.842957),
    Pathway(from: 11, to: 10, distance: 8.433074),
    Pathway(from: 3, to: 12, distance: 9.249075),
    Pathway(from: 9, to: 12, distance: 92.004344),
    Pathway(from: 12, to: 13, distance: 79.139168),
    Pathway(from: 13, to: 14, distance: 93.015697),
    Pathway(from: 14, to: 11, distance: 16.385363),
    Pathway(from: 13, to: 15, distance: 14.278855),
    Pathway(from: 1, to: 15, distance: 76.176591),
    Pathway(from: 15, to: 16, distance: 103.281791),
    Pathway(from: 16, to: 17, distance: 136.348905),
    Pathway(from: 2, to: 17, distance: 101.971077),
    Pathway(from: 17, to: 18, distance: 10.367688),
    Pathway(from: 19, to: 20, distance: 33.297593),
    Pathway(from: 21, to: 22, distance: 14.365939),
    Pathway(from: 22, to: 23, distance: 127.861767),
    Pathway(from: 23, to: 24, distance: 43.961670),
    Pathway(from: 18, to: 24, distance: 54.806341),
    Pathway(from: 24, to: 25, distance: 18.961366),
    Pathway(from: 18, to: 27, distance: 68.512860),
    Pathway(from: 27, to: 26, distance: 33.481643),
    Pathway(from: 6, to: 28, distance: 19.586214),
    Pathway(from: 28, to: 29, distance: 53.088346),
    Pathway(from: 29, to: 30, distance: 49.608257),
    Pathway(from: 28, to: 30, distance: 101.934424),
    Pathway(from: 30, to: 33, distance: 40.214417),
    Pathway(from: 31, to: 33, distance: 21.404199),
    Pathway(from: 28, to: 34, distance: 35.146129),
    Pathway(from: 33, to: 34, distance: 99.625281),
    Pathway(from: 28, to: 35, distance: 32.103694),
    Pathway(from: 34, to: 35, distance: 21.006075),
    Pathway(from: 34, to: 36, distance: 26.573001),
    Pathway(from: 34, to: 37, distance: 61.104558),
    Pathway(from: 36, to: 37, distance: 36.184045),
    Pathway(from: 4, to: 37, distance: 20.660554),
    Pathway(from: 36, to: 38, distance: 42.714773),
    Pathway(from: 38, to: 39, distance: 25.233524),
    Pathway(from: 39, to: 32, distance: 18.954748),
    Pathway(from: 40, to: 38, distance: 29.503878),
    Pathway(from: 40, to: 39, distance: 31.295448),
    Pathway(from: 34, to: 40, distance: 59.466491),
    Pathway(from: 35, to: 40, distance: 41.196442),
    Pathway(from: 29, to: 25, distance: 279.846770),
    Pathway(from: 29, to: 40, distance: 28.808659),
    Pathway(from: 37, to: 41, distance: 7.033036),
    Pathway(from: 2, to: 41, distance: 18.712175),
    Pathway(from: 41, to: 42, distance: 59.695068),
    Pathway(from: 43, to: 31, distance: 38.835090),
    Pathway(from: 43, to: 37, distance: 101.079107),
    Pathway(from: 43, to: 44, distance: 9.311983),
    Pathway(from: 44, to: 42, distance: 43.437937),
    Pathway(from: 44, to: 41, distance: 102.616257),
    Pathway(from: 42, to: 45, distance: 42.774270),
    Pathway(from: 45, to: 46, distance: 34.449500),
    Pathway(from: 45, to: 47, distance: 50.711019),
    Pathway(from: 47, to: 46, distance: 78.126775),
    Pathway(from: 48, to: 47, distance: 56.871845),
    Pathway(from: 48, to: 45, distance: 80.500200),
    Pathway(from: 49, to: 45, distance: 33.679570),
    Pathway(from: 49, to: 47, distance: 47.447675),
    Pathway(from: 49, to: 48, distance: 50.268276),
    Pathway(from: 45, to: 50, distance: 54.758594),
    Pathway(from: 17, to: 51, distance: 18.147432),
    Pathway(from: 51, to: 50, distance: 56.086747),
    Pathway(from: 41, to: 51, distance: 102.423166),
    Pathway(from: 18, to: 52, distance: 24.118880),
    Pathway(from: 51, to: 52, distance: 26.000097),
    Pathway(from: 52, to: 53, distance: 28.232532),
    Pathway(from: 53, to: 54, distance: 62.616549),
    Pathway(from: 54, to: 55, distance: 11.682247),
    Pathway(from: 53, to: 56, distance: 33.741892),
    Pathway(from: 56, to: 54, distance: 34.316289),
    Pathway(from: 52, to: 57, distance: 35.961222),
    Pathway(from: 57, to: 56, distance: 14.231403),
    Pathway(from: 57, to: 59, distance: 91.632923),
    Pathway(from: 59, to: 58, distance: 10.000074),
    Pathway(from: 58, to: 55, distance: 49.946667),
    Pathway(from: 58, to: 60, distance: 40.435738),
    Pathway(from: 60, to: 61, distance: 29.316136),
    Pathway(from: 62, to: 58, distance: 30.761112),
    Pathway(from: 62, to: 55, distance: 47.388703),
    Pathway(from: 60, to: 62, distance: 39.574522),
    Pathway(from: 62, to: 63, distance: 11.905103),
    Pathway(from: 63, to: 64, distance: 28.797316),
    Pathway(from: 64, to: 65, distance: 44.689590),
    Pathway(from: 66, to: 65, distance: 39.203985),
    Pathway(from: 66, to: 67, distance: 20.109191),
    Pathway(from: 65, to: 69, distance: 52.248732),
    Pathway(from: 69, to: 70, distance: 59.943870),
    Pathway(from: 70, to: 71, distance: 47.870876),
    Pathway(from: 67, to: 71, distance: 39.198271),
    Pathway(from: 72, to: 71, distance: 67.747313),
    Pathway(from: 72, to: 73, distance: 37.742226),
    Pathway(from: 71, to: 73, distance: 36.580143),
    Pathway(from: 74, to: 63, distance: 49.697870),
    Pathway(from: 74, to: 73, distance: 66.258331),
    Pathway(from: 75, to: 43, distance: 7.014708),
    Pathway(from: 75, to: 76, distance: 34.924984),
    Pathway(from: 76, to: 77, distance: 70.996695),
    Pathway(from: 77, to: 78, distance: 36.911893),
    Pathway(from: 76, to: 79, distance: 42.743310),
    Pathway(from: 44, to: 81, distance: 50.494673),
    Pathway(from: 81, to: 80, distance: 64.842954),
    Pathway(from: 77, to: 80, distance: 15.773473),
    Pathway(from: 80, to: 83, distance: 41.929561),
    Pathway(from: 83, to: 82, distance: 6.112619),
    Pathway(from: 77, to: 84, distance: 90.862494),
    Pathway(from: 30, to: 85, distance: 8.766743),
    Pathway(from: 75, to: 85, distance: 98.720903),
    Pathway(from: 84, to: 85, distance: 108.507238),
    Pathway(from: 84, to: 86, distance: 15.539303),
    Pathway(from: 86, to: 87, distance: 90.462123),
    Pathway(from: 77, to: 87, distance: 20.476215),
    Pathway(from: 87, to: 88, distance: 15.723516),
    Pathway(from: 80, to: 88, distance: 17.319484),
    Pathway(from: 89, to: 88, distance: 59.914207),
    Pathway(from: 89, to: 90, distance: 18.367613),
    Pathway(from: 90, to: 91, distance: 27.072641),
    Pathway(from: 92, to: 90, distance: 26.366037),
    Pathway(from: 91, to: 90, distance: 27.072641),
    Pathway(from: 91, to: 93, distance: 4.164646),
    Pathway(from: 92, to: 94, distance: 27.023509),
    Pathway(from: 91, to: 95, distance: 28.298786),
    Pathway(from: 88, to: 95, distance: 44.139997),
    Pathway(from: 94, to: 96, distance: 44.285386),
    Pathway(from: 96, to: 97, distance: 76.495091),
    Pathway(from: 97, to: 95, distance: 43.923091),
    Pathway(from: 94, to: 98, distance: 40.073535),
    Pathway(from: 99, to: 98, distance: 45.652620),
    Pathway(from: 99, to: 96, distance: 42.736773),
    Pathway(from: 99, to: 94, distance: 62.432700),
    Pathway(from: 100, to: 98, distance: 13.496695),
    Pathway(from: 100, to: 99, distance: 33.710927),
    Pathway(from: 100, to: 94, distance: 47.701635),
    Pathway(from: 101, to: 97, distance: 22.750238),
    Pathway(from: 101, to: 95, distance: 33.191300),
    Pathway(from: 97, to: 102, distance: 21.755125),
    Pathway(from: 102, to: 103, distance: 67.847865),
    Pathway(from: 104, to: 102, distance: 53.025041),
    Pathway(from: 104, to: 97, distance: 48.445245),
    Pathway(from: 104, to: 105, distance: 74.664944),
    Pathway(from: 103, to: 105, distance: 38.789280),
    Pathway(from: 105, to: 106, distance: 38.563511),
    Pathway(from: 106, to: 107, distance: 28.714249),
    Pathway(from: 108, to: 104, distance: 29.666646),
    Pathway(from: 108, to: 107, distance: 72.258547),
    Pathway(from: 109, to: 108, distance: 48.675038),
    Pathway(from: 109, to: 107, distance: 113.347667),
    Pathway(from: 110, to: 86, distance: 60.137797),
    Pathway(from: 110, to: 109, distance: 35.555837),
    Pathway(from: 111, to: 107, distance: 37.914208),
    Pathway(from: 111, to: 106, distance: 56.338251),
    Pathway(from: 111, to: 112, distance: 76.436576),
    Pathway(from: 112, to: 113, distance: 18.875026),
    Pathway(from: 113, to: 114, distance: 36.902321),
    Pathway(from: 114, to: 115, distance: 24.180703),
    Pathway(from: 115, to: 116, distance: 11.564070),
    Pathway(from: 116, to: 117, distance: 35.613840),
    Pathway(from: 117, to: 118, distance: 48.740500),
    Pathway(from: 118, to: 119, distance: 43.426457),
    Pathway(from: 112, to: 119, distance: 21.874334),
    Pathway(from: 117, to: 120, distance: 11.736110),
    Pathway(from: 117, to: 121, distance: 47.593328),
    Pathway(from: 121, to: 122, distance: 19.214234),
    Pathway(from: 123, to: 119, distance: 97.985891),
    Pathway(from: 123, to: 124, distance: 30.252442),
    Pathway(from: 124, to: 125, distance: 22.057008),
    Pathway(from: 125, to: 117, distance: 8.931418),
    Pathway(from: 123, to: 126, distance: 31.518939),
    Pathway(from: 126, to: 127, distance: 57.333666),
    Pathway(from: 123, to: 128, distance: 86.964638),
    Pathway(from: 126, to: 128, distance: 61.478756),
    Pathway(from: 129, to: 128, distance: 116.546133),
    Pathway(from: 129, to: 127, distance: 61.352627),
    Pathway(from: 129, to: 119, distance: 123.628820),
    Pathway(from: 119, to: 127, distance: 73.707474),
    Pathway(from: 128, to: 130, distance: 79.221153),
    Pathway(from: 130, to: 131, distance: 35.314376),
    Pathway(from: 131, to: 132, distance: 40.043215),
    Pathway(from: 130, to: 133, distance: 41.849999),
    Pathway(from: 133, to: 132, distance: 47.056394),
    Pathway(from: 133, to: 136, distance: 44.308580),
    Pathway(from: 136, to: 137, distance: 36.120450),
    Pathway(from: 137, to: 132, distance: 46.476105),
    Pathway(from: 135, to: 136, distance: 52.255593),
    Pathway(from: 138, to: 137, distance: 51.761905),
    Pathway(from: 135, to: 138, distance: 37.465870),
    Pathway(from: 133, to: 139, distance: 39.694340),
    Pathway(from: 139, to: 136, distance: 12.324204),
    Pathway(from: 135, to: 140, distance: 15.337151),
    Pathway(from: 136, to: 140, distance: 40.839501),
    Pathway(from: 140, to: 142, distance: 37.820638),
    Pathway(from: 142, to: 141, distance: 35.154328),
    Pathway(from: 141, to: 139, distance: 42.987648),
    Pathway(from: 139, to: 143, distance: 39.878776),
    Pathway(from: 141, to: 143, distance: 12.597534),
    Pathway(from: 143, to: 144, distance: 42.018121),
    Pathway(from: 144, to: 145, distance: 39.185328),
    Pathway(from: 145, to: 133, distance: 11.921732),
    Pathway(from: 145, to: 130, distance: 35.606074),
    Pathway(from: 137, to: 147, distance: 42.726941),
    Pathway(from: 147, to: 146, distance: 50.437863),
    Pathway(from: 146, to: 148, distance: 43.722459),
    Pathway(from: 148, to: 149, distance: 14.182393),
    Pathway(from: 150, to: 137, distance: 19.822036),
    Pathway(from: 150, to: 148, distance: 35.908367),
    Pathway(from: 148, to: 152, distance: 49.641287),
    Pathway(from: 152, to: 151, distance: 42.258014),
    Pathway(from: 151, to: 131, distance: 31.603707),
    Pathway(from: 153, to: 146, distance: 27.749451),
    Pathway(from: 153, to: 149, distance: 27.954889),
    Pathway(from: 153, to: 152, distance: 69.512491),
    Pathway(from: 154, to: 153, distance: 25.752868),
    Pathway(from: 138, to: 155, distance: 42.638807),
    Pathway(from: 135, to: 155, distance: 45.609239),
    Pathway(from: 155, to: 156, distance: 50.064991),
    Pathway(from: 156, to: 157, distance: 45.952468),
    Pathway(from: 157, to: 96, distance: 53.442895),
    Pathway(from: 158, to: 159, distance: 29.476929),
    Pathway(from: 159, to: 154, distance: 28.296626),
    Pathway(from: 159, to: 160, distance: 49.954789),
    Pathway(from: 159, to: 161, distance: 55.045860),
    Pathway(from: 131, to: 163, distance: 63.619982),
    Pathway(from: 163, to: 162, distance: 41.701509),
    Pathway(from: 162, to: 158, distance: 48.649059),
    Pathway(from: 164, to: 165, distance: 22.054307),
    Pathway(from: 164, to: 89, distance: 48.500216),
    Pathway(from: 164, to: 94, distance: 48.062681),
    Pathway(from: 166, to: 167, distance: 25.439099),
    Pathway(from: 167, to: 69, distance: 14.554456),
    Pathway(from: 167, to: 70, distance: 46.295313),
    Pathway(from: 166, to: 168, distance: 27.987304),
    Pathway(from: 168, to: 169, distance: 32.016113),
    Pathway(from: 170, to: 169, distance: 7.691832),
    Pathway(from: 170, to: 164, distance: 121.274601),
    Pathway(from: 171, to: 99, distance: 41.054254),
    Pathway(from: 171, to: 172, distance: 20.430503),
    Pathway(from: 172, to: 173, distance: 24.679635),
    Pathway(from: 173, to: 171, distance: 38.399832),
    Pathway(from: 172, to: 174, distance: 16.954973),
    Pathway(from: 175, to: 173, distance: 33.445986),
    Pathway(from: 175, to: 176, distance: 7.182240),
    Pathway(from: 177, to: 176, distance: 29.111375),
    Pathway(from: 177, to: 174, distance: 41.620131),
    Pathway(from: 173, to: 178, distance: 12.155468),
    Pathway(from: 178, to: 179, distance: 30.705666),
    Pathway(from: 180, to: 178, distance: 46.882577),
    Pathway(from: 180, to: 173, distance: 52.011719),
    Pathway(from: 180, to: 155, distance: 61.749752),
    Pathway(from: 181, to: 182, distance: 53.773748),
    Pathway(from: 182, to: 180, distance: 35.891796),
    Pathway(from: 182, to: 155, distance: 72.752597),
    Pathway(from: 183, to: 99, distance: 49.892532),
    Pathway(from: 183, to: 184, distance: 78.076903),
    Pathway(from: 184, to: 170, distance: 37.018770),
    Pathway(from: 184, to: 164, distance: 91.035782),
    Pathway(from: 185, to: 183, distance: 37.228951),
    Pathway(from: 185, to: 177, distance: 23.404617),
    Pathway(from: 185, to: 186, distance: 45.213779),
    Pathway(from: 186, to: 187, distance: 45.430717),
    Pathway(from: 187, to: 188, distance: 26.630367),
    Pathway(from: 187, to: 191, distance: 26.653901),
    Pathway(from: 188, to: 191, distance: 25.669677),
    Pathway(from: 191, to: 190, distance: 51.161745),
    Pathway(from: 191, to: 189, distance: 87.346156),
    Pathway(from: 190, to: 189, distance: 40.669645),
    Pathway(from: 192, to: 185, distance: 62.518856),
    Pathway(from: 192, to: 175, distance: 47.905070),
    Pathway(from: 192, to: 193, distance: 26.371676),
    Pathway(from: 179, to: 193, distance: 53.846791),
    Pathway(from: 193, to: 194, distance: 42.545614),
    Pathway(from: 194, to: 189, distance: 15.033637),
    Pathway(from: 195, to: 181, distance: 17.544468),
    Pathway(from: 195, to: 193, distance: 51.093020),
    Pathway(from: 195, to: 196, distance: 29.078659),
    Pathway(from: 196, to: 197, distance: 27.846112),
    Pathway(from: 196, to: 198, distance: 28.927785),
    Pathway(from: 197, to: 198, distance: 37.661136),
    Pathway(from: 199, to: 195, distance: 40.433408),
    Pathway(from: 199, to: 146, distance: 38.076606),
    Pathway(from: 199, to: 153, distance: 38.502624),
    Pathway(from: 199, to: 138, distance: 105.325027),
    Pathway(from: 199, to: 181, distance: 33.658161),
    Pathway(from: 200, to: 199, distance: 92.359369),
    Pathway(from: 200, to: 198, distance: 28.391638),
    Pathway(from: 200, to: 160, distance: 43.483432),
    Pathway(from: 200, to: 201, distance: 84.000944),
    Pathway(from: 201, to: 161, distance: 20.470599),
    Pathway(from: 201, to: 202, distance: 57.870792),
    Pathway(from: 200, to: 203, distance: 66.961409),
    Pathway(from: 203, to: 204, distance: 20.971540),
    Pathway(from: 203, to: 205, distance: 70.029452),
    Pathway(from: 206, to: 204, distance: 70.026983),
    Pathway(from: 204, to: 207, distance: 25.095604),
    Pathway(from: 206, to: 208, distance: 36.682964),
    Pathway(from: 209, to: 208, distance: 37.417715),
    Pathway(from: 210, to: 194, distance: 26.632439),
    Pathway(from: 210, to: 197, distance: 34.230492),
    Pathway(from: 210, to: 211, distance: 34.287012),
    Pathway(from: 211, to: 197, distance: 44.056332),
    Pathway(from: 211, to: 200, distance: 64.737873),
    Pathway(from: 210, to: 212, distance: 126.539076),
    Pathway(from: 212, to: 209, distance: 49.822886),
    Pathway(from: 210, to: 213, distance: 42.450914),
    Pathway(from: 213, to: 214, distance: 57.924995),
    Pathway(from: 214, to: 212, distance: 56.836539),
    Pathway(from: 215, to: 188, distance: 49.338130),
    Pathway(from: 215, to: 190, distance: 33.460517),
    Pathway(from: 215, to: 216, distance: 51.232132),
    Pathway(from: 216, to: 217, distance: 13.626759),
    Pathway(from: 218, to: 216, distance: 30.736484),
    Pathway(from: 216, to: 219, distance: 34.151318),
    Pathway(from: 219, to: 220, distance: 65.251148),
    Pathway(from: 221, to: 218, distance: 42.992103),
    Pathway(from: 221, to: 212, distance: 58.472405),
    Pathway(from: 221, to: 214, distance: 18.286500),
    Pathway(from: 222, to: 213, distance: 22.941053),
    Pathway(from: 222, to: 218, distance: 46.103804),
    Pathway(from: 222, to: 190, distance: 26.636598),
    Pathway(from: 222, to: 215, distance: 38.373690),
    Pathway(from: 222, to: 210, distance: 50.860721),
    Pathway(from: 212, to: 223, distance: 21.335920),
    Pathway(from: 223, to: 224, distance: 34.390276),
    Pathway(from: 224, to: 221, distance: 20.401433),
    Pathway(from: 225, to: 72, distance: 63.202709),
    Pathway(from: 225, to: 226, distance: 36.997363),
    Pathway(from: 226, to: 89, distance: 52.868696),
    Pathway(from: 225, to: 227, distance: 35.167218),
    Pathway(from: 227, to: 228, distance: 43.371069),
    Pathway(from: 164, to: 228, distance: 34.837478),
    Pathway(from: 228, to: 184, distance: 57.551414),
    Pathway(from: 228, to: 170, distance: 86.444322),
    Pathway(from: 227, to: 229, distance: 67.395033),
    Pathway(from: 229, to: 70, distance: 22.946529),
    Pathway(from: 229, to: 168, distance: 20.014360),
    Pathway(from: 229, to: 166, distance: 46.076296),
    Pathway(from: 230, to: 220, distance: 50.701083),
    Pathway(from: 230, to: 188, distance: 76.641382),
    Pathway(from: 230, to: 215, distance: 117.360804),
    Pathway(from: 230, to: 231, distance: 43.124530),
    Pathway(from: 231, to: 166, distance: 68.584469),
    Pathway(from: 231, to: 232, distance: 40.708987),
    Pathway(from: 233, to: 232, distance: 48.118576),
    Pathway(from: 233, to: 231, distance: 76.924733),
    Pathway(from: 233, to: 230, distance: 77.823894),
    Pathway(from: 233, to: 234, distance: 24.503564),
    Pathway(from: 234, to: 232, distance: 31.556670),
    Pathway(from: 234, to: 231, distance: 69.260384),
    Pathway(from: 234, to: 235, distance: 43.343728),
    Pathway(from: 236, to: 61, distance: 38.177657),
    Pathway(from: 236, to: 237, distance: 38.813574),
    Pathway(from: 237, to: 238, distance: 30.897107),
    Pathway(from: 237, to: 239, distance: 31.348487),
    Pathway(from: 238, to: 239, distance: 26.673904),
    Pathway(from: 235, to: 240, distance: 68.313567),
    Pathway(from: 241, to: 240, distance: 37.058370),
    Pathway(from: 241, to: 235, distance: 47.506877),
    Pathway(from: 241, to: 237, distance: 48.569210),
    Pathway(from: 240, to: 242, distance: 31.144737),
    Pathway(from: 242, to: 235, distance: 99.147922),
    Pathway(from: 242, to: 243, distance: 56.478220),
    Pathway(from: 244, to: 230, distance: 120.281202),
    Pathway(from: 244, to: 220, distance: 75.557634),
    Pathway(from: 245, to: 244, distance: 17.390557),
    Pathway(from: 247, to: 246, distance: 42.275010),
    Pathway(from: 247, to: 244, distance: 104.516113),
    Pathway(from: 247, to: 248, distance: 23.110056),
    Pathway(from: 247, to: 249, distance: 30.425315),
    Pathway(from: 247, to: 250, distance: 55.073863),
    Pathway(from: 251, to: 250, distance: 22.273052),
    Pathway(from: 251, to: 252, distance: 13.314066),
    Pathway(from: 248, to: 253, distance: 67.561343),
    Pathway(from: 254, to: 252, distance: 18.290133),
    Pathway(from: 254, to: 253, distance: 9.492460),
    Pathway(from: 255, to: 252, distance: 20.027844),
    Pathway(from: 256, to: 255, distance: 24.103340),
    Pathway(from: 256, to: 250, distance: 32.121242),
    Pathway(from: 257, to: 253, distance: 23.990780),
    Pathway(from: 258, to: 209, distance: 53.262432),
    Pathway(from: 258, to: 212, distance: 88.471825),
    Pathway(from: 258, to: 259, distance: 45.498065),
    Pathway(from: 259, to: 257, distance: 25.582785),
    Pathway(from: 258, to: 260, distance: 26.884813),
    Pathway(from: 261, to: 129, distance: 27.390084),
    Pathway(from: 262, to: 261, distance: 86.128522),
    Pathway(from: 262, to: 128, distance: 52.563311),
    Pathway(from: 263, to: 129, distance: 132.761652),
    Pathway(from: 264, to: 262, distance: 85.906044),
    Pathway(from: 264, to: 263, distance: 99.719570),
    Pathway(from: 264, to: 265, distance: 59.173567),
    Pathway(from: 266, to: 265, distance: 40.490400),
    Pathway(from: 267, to: 266, distance: 18.464740),
    Pathway(from: 265, to: 268, distance: 55.061547),
    Pathway(from: 269, to: 268, distance: 88.701180),
    Pathway(from: 269, to: 263, distance: 94.571816),
    Pathway(from: 268, to: 270, distance: 43.864496),
    Pathway(from: 271, to: 270, distance: 216.675668),
    Pathway(from: 271, to: 268, distance: 260.162975),
    Pathway(from: 271, to: 272, distance: 54.666794),
    Pathway(from: 272, to: 273, distance: 66.481218),
    Pathway(from: 273, to: 274, distance: 25.763317),
    Pathway(from: 272, to: 274, distance: 45.088234),
    Pathway(from: 275, to: 274, distance: 24.643971),
    Pathway(from: 275, to: 273, distance: 32.667792),
    Pathway(from: 275, to: 272, distance: 37.862714),
    Pathway(from: 276, to: 273, distance: 32.687267),
    Pathway(from: 276, to: 277, distance: 64.037857),
    Pathway(from: 278, to: 201, distance: 83.740933),
    Pathway(from: 278, to: 162, distance: 95.873644),
    Pathway(from: 278, to: 279, distance: 68.516590),
    Pathway(from: 279, to: 162, distance: 66.969378),
    Pathway(from: 280, to: 162, distance: 42.745552),
    Pathway(from: 280, to: 162, distance: 42.745552),
    Pathway(from: 281, to: 278, distance: 161.955421),
    Pathway(from: 281, to: 273, distance: 67.139314),
    Pathway(from: 278, to: 282, distance: 37.409370),
    Pathway(from: 282, to: 283, distance: 36.005366),
    Pathway(from: 283, to: 284, distance: 44.210521),
    Pathway(from: 285, to: 284, distance: 63.893946),
    Pathway(from: 285, to: 281, distance: 28.498355),
    Pathway(from: 286, to: 284, distance: 95.203648),
    Pathway(from: 283, to: 287, distance: 52.338104),
    Pathway(from: 288, to: 287, distance: 36.857498),
    Pathway(from: 288, to: 289, distance: 57.598550),
    Pathway(from: 281, to: 290, distance: 163.685216),
    Pathway(from: 290, to: 286, distance: 52.989718),
    Pathway(from: 290, to: 291, distance: 32.962917),
    Pathway(from: 290, to: 292, distance: 31.571020),
    Pathway(from: 292, to: 293, distance: 59.247308),
    Pathway(from: 290, to: 294, distance: 70.854930),
    Pathway(from: 294, to: 289, distance: 39.271196),
    Pathway(from: 294, to: 295, distance: 37.323250),
    Pathway(from: 294, to: 296, distance: 88.354204),
    Pathway(from: 296, to: 297, distance: 35.174635),
    Pathway(from: 297, to: 298, distance: 44.860404),
    Pathway(from: 296, to: 298, distance: 23.824386),
    Pathway(from: 294, to: 299, distance: 79.101664),
    Pathway(from: 299, to: 295, distance: 57.748285),
    Pathway(from: 162, to: 300, distance: 91.251647),
    Pathway(from: 300, to: 278, distance: 34.022343),
    Pathway(from: 300, to: 201, distance: 49.841203),
    Pathway(from: 300, to: 301, distance: 91.580207),
    Pathway(from: 301, to: 302, distance: 34.874821),
    Pathway(from: 301, to: 303, distance: 52.230214),
    Pathway(from: 287, to: 304, distance: 36.700162),
    Pathway(from: 303, to: 304, distance: 38.154960),
    Pathway(from: 288, to: 305, distance: 36.497696),
    Pathway(from: 303, to: 306, distance: 68.893331),
    Pathway(from: 306, to: 305, distance: 46.766796),
    Pathway(from: 306, to: 296, distance: 35.239598),
    Pathway(from: 306, to: 307, distance: 38.195646),
    Pathway(from: 301, to: 307, distance: 89.031841),
    Pathway(from: 308, to: 202, distance: 97.287440),
    Pathway(from: 308, to: 309, distance: 23.878164),
    Pathway(from: 310, to: 307, distance: 84.524357),
    Pathway(from: 310, to: 311, distance: 28.128774),
    Pathway(from: 311, to: 312, distance: 25.721035),
    Pathway(from: 312, to: 313, distance: 23.832077),
    Pathway(from: 314, to: 23, distance: 93.431685),
    Pathway(from: 314, to: 315, distance: 14.794742),
    Pathway(from: 316, to: 22, distance: 44.762564),
    Pathway(from: 316, to: 317, distance: 20.887007),
    Pathway(from: 22, to: 317, distance: 42.323194),
    Pathway(from: 316, to: 318, distance: 26.388602),
    Pathway(from: 314, to: 319, distance: 41.607424),
    Pathway(from: 319, to: 320, distance: 65.610100),
    Pathway(from: 319, to: 321, distance: 97.639282),
    Pathway(from: 321, to: 320, distance: 54.091857),
    Pathway(from: 321, to: 322, distance: 35.106143),
    Pathway(from: 319, to: 322, distance: 84.843070),
    Pathway(from: 323, to: 242, distance: 42.023504),
    Pathway(from: 323, to: 243, distance: 41.525978),
    Pathway(from: 322, to: 323, distance: 35.361270),
    Pathway(from: 321, to: 324, distance: 85.254209),
    Pathway(from: 324, to: 325, distance: 64.630550),
    Pathway(from: 325, to: 326, distance: 15.741593),
    Pathway(from: 319, to: 326, distance: 123.047822),
    Pathway(from: 327, to: 325, distance: 24.587411),
    Pathway(from: 327, to: 328, distance: 25.670405),
    Pathway(from: 328, to: 329, distance: 18.627317),
    Pathway(from: 316, to: 326, distance: 99.303020),
    Pathway(from: 321, to: 330, distance: 49.254997),
    Pathway(from: 330, to: 331, distance: 8.402735),
    Pathway(from: 331, to: 324, distance: 30.487363),
    Pathway(from: 329, to: 332, distance: 80.547214),
    Pathway(from: 333, to: 332, distance: 135.717902),
    Pathway(from: 310, to: 334, distance: 57.491106),
    Pathway(from: 334, to: 335, distance: 32.891841),
    Pathway(from: 336, to: 335, distance: 59.614795),
    Pathway(from: 335, to: 337, distance: 185.827195),
    Pathway(from: 336, to: 338, distance: 111.969503),
    Pathway(from: 338, to: 339, distance: 125.344807),
    Pathway(from: 339, to: 337, distance: 130.360454),
    Pathway(from: 338, to: 340, distance: 33.819080),
    Pathway(from: 334, to: 341, distance: 117.906923),
    Pathway(from: 342, to: 341, distance: 20.719903),
    Pathway(from: 341, to: 343, distance: 74.255326),
    Pathway(from: 343, to: 344, distance: 52.569355),
    Pathway(from: 344, to: 258, distance: 115.780984),
    Pathway(from: 344, to: 345, distance: 48.785295),
    Pathway(from: 344, to: 346, distance: 36.230481),
    Pathway(from: 346, to: 347, distance: 30.078850),
    Pathway(from: 346, to: 348, distance: 70.912538),
    Pathway(from: 349, to: 346, distance: 54.206612),
    Pathway(from: 349, to: 348, distance: 41.476141),
    Pathway(from: 349, to: 347, distance: 59.253851),
    Pathway(from: 348, to: 350, distance: 66.153994),
    Pathway(from: 350, to: 351, distance: 60.205751),
    Pathway(from: 351, to: 352, distance: 40.090542),
    Pathway(from: 352, to: 353, distance: 22.684647),
    Pathway(from: 352, to: 354, distance: 40.152438),
    Pathway(from: 355, to: 354, distance: 21.259130),
    Pathway(from: 354, to: 356, distance: 50.417111),
    Pathway(from: 345, to: 357, distance: 130.500905),
    Pathway(from: 247, to: 357, distance: 101.244558),
    Pathway(from: 357, to: 249, distance: 76.296110),
    Pathway(from: 243, to: 358, distance: 90.335220),
    Pathway(from: 358, to: 359, distance: 105.986234),
    Pathway(from: 360, to: 359, distance: 50.084522),
    Pathway(from: 360, to: 361, distance: 33.658668),
    Pathway(from: 362, to: 360, distance: 24.982933),
    Pathway(from: 360, to: 364, distance: 30.192180),
    Pathway(from: 364, to: 362, distance: 37.543361),
    Pathway(from: 365, to: 366, distance: 74.466457),
    Pathway(from: 365, to: 357, distance: 79.251932),
    Pathway(from: 366, to: 364, distance: 75.865328),
    Pathway(from: 366, to: 359, distance: 61.235656),
    Pathway(from: 364, to: 361, distance: 61.945579),
    Pathway(from: 356, to: 363, distance: 64.441472),
    Pathway(from: 368, to: 367, distance: 46.411411),
    Pathway(from: 368, to: 363, distance: 39.603112),
    Pathway(from: 368, to: 356, distance: 58.442582),
    Pathway(from: 368, to: 354, distance: 58.170118),
    Pathway(from: 368, to: 355, distance: 65.377071),
    Pathway(from: 367, to: 369, distance: 67.759331),
    Pathway(from: 369, to: 370, distance: 86.198878),
    Pathway(from: 352, to: 371, distance: 58.598416),
    Pathway(from: 372, to: 371, distance: 76.878822),
    Pathway(from: 372, to: 351, distance: 85.422174),
    Pathway(from: 372, to: 352, distance: 84.355242),
    Pathway(from: 372, to: 373, distance: 86.107396),
    Pathway(from: 373, to: 351, distance: 78.849611),
    Pathway(from: 373, to: 350, distance: 85.038156),
    Pathway(from: 368, to: 370, distance: 153.130916),
    Pathway(from: 374, to: 334, distance: 176.310585),
    Pathway(from: 374, to: 375, distance: 48.634738),
    Pathway(from: 374, to: 376, distance: 127.769858),
    Pathway(from: 376, to: 377, distance: 71.801301),
    Pathway(from: 376, to: 378, distance: 51.032274),
    Pathway(from: 375, to: 379, distance: 112.024743),
    Pathway(from: 379, to: 380, distance: 115.239762),
    Pathway(from: 379, to: 381, distance: 125.543036),
    Pathway(from: 381, to: 377, distance: 97.360023),
    Pathway(from: 381, to: 382, distance: 66.516461),
    Pathway(from: 382, to: 383, distance: 75.885644),
    Pathway(from: 383, to: 381, distance: 60.885820),
    Pathway(from: 379, to: 383, distance: 80.880491),
    Pathway(from: 383, to: 384, distance: 30.644558),
    Pathway(from: 384, to: 382, distance: 67.922591),
    Pathway(from: 385, to: 384, distance: 37.877889),
    Pathway(from: 385, to: 382, distance: 60.072772),
    Pathway(from: 385, to: 381, distance: 102.227314),
    Pathway(from: 379, to: 386, distance: 124.263351),
    Pathway(from: 386, to: 387, distance: 86.026325),
    Pathway(from: 379, to: 388, distance: 327.622020),
    Pathway(from: 388, to: 389, distance: 68.233579),
    Pathway(from: 389, to: 390, distance: 52.203625),
    Pathway(from: 388, to: 390, distance: 70.809825),
    Pathway(from: 387, to: 390, distance: 106.501231),
    Pathway(from: 391, to: 390, distance: 91.401514),
    Pathway(from: 391, to: 392, distance: 46.927240),
    Pathway(from: 393, to: 392, distance: 25.865827),
    Pathway(from: 393, to: 391, distance: 55.468123),
    Pathway(from: 393, to: 394, distance: 79.711134),
    Pathway(from: 394, to: 395, distance: 88.560479),
    Pathway(from: 395, to: 386, distance: 157.154152),
    Pathway(from: 396, to: 349, distance: 205.274261),
    Pathway(from: 396, to: 388, distance: 146.763121),
    Pathway(from: 396, to: 397, distance: 101.124123),
    Pathway(from: 397, to: 389, distance: 103.228719),
    Pathway(from: 397, to: 398, distance: 98.436646),
    Pathway(from: 397, to: 399, distance: 68.918121),
    Pathway(from: 398, to: 399, distance: 89.270468),
    Pathway(from: 396, to: 400, distance: 186.752968),
    Pathway(from: 400, to: 401, distance: 99.861790),
    Pathway(from: 400, to: 402, distance: 114.512963),
    Pathway(from: 400, to: 403, distance: 118.769102),
    Pathway(from: 401, to: 403, distance: 51.178564),
    Pathway(from: 404, to: 405, distance: 55.158738),
    Pathway(from: 404, to: 406, distance: 55.473530),
    Pathway(from: 406, to: 407, distance: 76.926317),
    Pathway(from: 408, to: 407, distance: 72.315997),
    Pathway(from: 406, to: 409, distance: 58.838314),
    Pathway(from: 410, to: 406, distance: 80.444510),
    Pathway(from: 410, to: 409, distance: 34.076171),
    Pathway(from: 410, to: 411, distance: 59.091340),
    Pathway(from: 411, to: 412, distance: 18.290113),
    Pathway(from: 412, to: 134, distance: 168.422926),
    Pathway(from: 68, to: 134, distance: 37.248286),
    Pathway(from: 68, to: 392, distance: 118.256609),
    Pathway(from: 68, to: 406, distance: 276.188649),
    Pathway(from: 319, to: 315, distance: 45.423554),
    Pathway(from: 236, to: 231, distance: 104.834734),
    Pathway(from: 236, to: 319, distance: 102.330334),
    Pathway(from: 413, to: 70, distance: 20)
]
