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
        let r1 : R?
        let r2 : R?
        
        //let route1 : [String]?
        //let route2 : [String]?
        
        enum CodingKeys: String, CodingKey {
            case r1 = "1"//can access nested?
            case r2 = "2"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            r1 = try values.decodeIfPresent(R.self, forKey: .r1) //R1(from: decoder)// values.decodeIfPresent([String].self, forKey: .r1)
            r2 = try values.decodeIfPresent(R.self, forKey: .r2) //R2(from: decoder)// values.decodeIfPresent([String].self, forKey: .r2)
        }
        
    }
    
    struct R : Codable{
        
        let route:[String]?
        let stops:[String]?
        enum CodingKeys: String, CodingKey {
            case route = "route"//can access nested?
            case stops = "stops"
        }
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            route = try values.decodeIfPresent([String].self, forKey: .route)
            stops = try values.decodeIfPresent([String].self, forKey: .stops)
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
