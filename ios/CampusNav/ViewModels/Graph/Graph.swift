//
//  Graph.swift
//  CampusNav
//
//  Created by Jonah Blackmon on 7/26/25.
//

import Foundation
import MapKit

struct Graph {
    var nodes: [Node]
    var pathways: [Pathway]
    var num_nodes: Int
    var num_paths: Int
    
    init(nodes: [Node], pathways: [Pathway], num_nodes: Int, num_paths: Int) {
        self.num_nodes = num_nodes
        self.num_paths = num_paths
        self.nodes = nodes
        self.pathways = pathways
    }
}
