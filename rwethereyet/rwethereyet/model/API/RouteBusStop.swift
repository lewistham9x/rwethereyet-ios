//
//  RouteBusStop.swift
//  rwethereyet
///Users/lewistham/Documents/GitHub/rwethereyet-ios/rwethereyet/rwethereyet/AppDelegate.swift
//  Created by Lewis Tham on 13/1/18.
//  Copyright © 2018 somethingwithc. All rights reserved.
//

import Foundation

//map API json  to RouteBusStop objects, to add into CoreData as BusStop objects later


enum RouteBusStop {
    struct Base : Codable {
        let stopNo : String?
        var latitude : String = ""
        var longitude : String = ""
        let name : String?

        enum CodingKeys: String, CodingKey {
            
            case stopNo = "no"
            case latitude = "lat"
            case longitude = "lng"
            case name = "name"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            stopNo = try values.decodeIfPresent(String.self, forKey: .stopNo)
            latitude = (try values.decodeIfPresent(String.self, forKey: .latitude))!
            longitude = (try values.decodeIfPresent(String.self, forKey: .longitude))!
            name = try values.decodeIfPresent(String.self, forKey: .name)
        }
        
    }
    
}
/*
class RouteBusStop: Mappable {
    var stopNo:String?
    var latitude: String = ""
    var longitude: String = ""
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
*/
