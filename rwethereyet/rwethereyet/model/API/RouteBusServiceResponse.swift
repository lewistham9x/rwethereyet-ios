//
//  RouteBusServiceResponse.swift
//  rwethereyet
//
//  Created by Lewis Tham on 13/1/18.
//  Copyright © 2018 somethingwithc. All rights reserved.
//

import Foundation

//map API json  to RouteBusStop objects, to add into CoreData as BusStop objects later

enum RouteBusServiceResponse {
    struct Base : Codable {
        let route1 : [String]?
        let route2 : [String]?
        
        enum CodingKeys: String, CodingKey {
            case route1 = "1.stops"//can access nested?
            case route2 = "2.stops"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            route1 = try values.decodeIfPresent([String].self, forKey: .route1)
            route2 = try values.decodeIfPresent([String].self, forKey: .route2)
        }
        
    }
}

/*
 
 class RouteBusServiceResponse: Mappable {
 var route1: [String]?
 var route2: [String]?
 
 required init?(map: Map){
 
 }
 
 //https://github.com/tristanhimmelman/AlamofireObjectMapper#easy-mapping-of-nested-objects
 func mapping(map: Map) {
 route1 <- map["1.stops"]
 route2 <- map["2.stops"]
 }
 }
*/
