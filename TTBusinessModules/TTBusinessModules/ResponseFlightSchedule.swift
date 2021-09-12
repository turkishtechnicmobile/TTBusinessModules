//
//  ResponseFlightSchedule.swift
//  NMBusinessModules
//
//  Created by Nazif MASMANACI on 27.04.2021.
//  Copyright © 2021 Turkish Technic. All rights reserved.
//

import Foundation
import ObjectMapper
import TTBaseModel

public class ResponseFlightSchedule: Mappable {
    
    // MARK: Properties
    public var flights: [FlightArrivalOrDeparture]?
    
    public required init() { }
    
    public required init(map: Map) { }
    
    public func mapping(map: Map) {
        self.flights <- map["flightSchedule"]
    }
}

public class FlightArrivalOrDeparture : Mappable {
    public var ac : String!
    public var acType : String!
    public var acSeries : String!
    public var flight : String!
    public var leg : Int!
    public var origin : String!
    public var destination : String!
    public var scheduleDate : Date!
    public var arrivalDate : Date!
    public var gate : String!
    public var position : String!
    
    public required init?(map: Map) { }
    
    required init?() { }
    
    public func mapping(map: Map) {
        
        // TODO: Remzi
//        let dateFormatter = ConstantFormatted.dateFormattedMapping()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 60*60*3) // GTM +3:00
        dateFormatter.locale = Locale(identifier: "tr_TR")
        
        var tempDateString : String!
        
        ac <- map[SerializationKeys.ac]
        acType <- map[SerializationKeys.acType]
        acSeries <- map[SerializationKeys.acSeries]
        flight <- map[SerializationKeys.flight]
        leg <- map[SerializationKeys.leg]
        origin <- map[SerializationKeys.origin]
        destination <- map[SerializationKeys.destination]
        
        tempDateString <- map[SerializationKeys.scheduleDate]
        if tempDateString != nil {
            scheduleDate = dateFormatter.date(from: tempDateString)
        }
        
        tempDateString <- map[SerializationKeys.arrivalDate]
        if tempDateString != nil {
            arrivalDate = dateFormatter.date(from: tempDateString)
        }
        
        gate <- map[SerializationKeys.depGate]
        if gate == nil {
            gate <- map[SerializationKeys.arrGate]
        }
        position <- map[SerializationKeys.depPosition]
        if position == nil {
            position <- map[SerializationKeys.arrPosition]
        }
    }
}

extension FlightArrivalOrDeparture {
    private struct SerializationKeys {
        static let ac = "ac"
        static let acType = "acType"
        static let acSeries = "acSeries"
        static let flight = "flight"
        static let leg = "leg"
        static let origin = "origin"
        static let destination = "destination"
        static let scheduleDate = "scheduleDate"
        static let arrivalDate = "arrivalDate"
        
        static let depGate = "depGate" // departure için
        static let depPosition = "depPosition" // departure için
        
        static let arrGate = "arrGate" // arrival için
        static let arrPosition = "arrPosition" // arrival için
    }
}
