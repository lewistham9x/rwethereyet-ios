//
//  RouteBusStop.swift
//  rwethereyet
///Users/lewistham/Documents/GitHub/rwethereyet-ios/rwethereyet/rwethereyet/AppDelegate.swift
//  Created by Lewis Tham on 13/1/18.
//  Copyright © 2018 somethingwithc. All rights reserved.
//

import Foundation
import ObjectMapper

//map API json  to RouteBusStop objects, to add into CoreData as BusStop objects later

class RouteBusStop: Mappable {
    var stopNo:String?
    var latitude: String?
    var longitude: String?
    var name: String?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        stopNo <- map["no"]
        latitude <- map["lat"]
        longitude <- map["lng"]
        name <- map["name"]
    }
}
