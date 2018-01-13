//
//  RouteBusServiceResponse.swift
//  rwethereyet
//
//  Created by Lewis Tham on 13/1/18.
//  Copyright © 2018 somethingwithc. All rights reserved.
//

import Foundation
import ObjectMapper

//map API json  to RouteBusStop objects, to add into CoreData as BusStop objects later

class RouteBusServiceResponse: Mappable {
    var route1: RouteBusServiceRouteResponse?
    var route2: RouteBusServiceRouteResponse?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        route1 <- map["1"]
        route2 <- map["2"]
    }
}

