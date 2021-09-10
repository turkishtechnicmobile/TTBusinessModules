//
//  ConstantFS.swift
//  NMBusinessModules
//
//  Created by MnzfM on 8.03.2021.
//

import Foundation
import NMBaseApp

class ConstantFS: ConstantManager {
 
//    static let empty = ""
//    static let mostUsedLocations: [String] = ["IST", "ISL", "SAW", "ESB"]
//    static let fleets = ["A320", "A330", "A350", "B737", "B747", "B777", "B787"]
    static let flightScheduleOrigin = "IST"
    
    struct Filter {
        static let airCraft = "A/C"
        static let origin = "Origin"
        static let destination = "Destination"
        static let fleet = "Fleet"
    }
    
    struct Message {
        static let noResultsFound = "No results found"
    }
    
    struct Hamburger {
        static let flightSchedule = "FLIGHT SCHEDULES"
    }
}

enum IconFS:String {
    case planeLandIcon = "plane-land-icon"
    case planeTakeOffIcon = "plane-takeoff-icon"
}
