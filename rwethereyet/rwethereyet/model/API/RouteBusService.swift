//
//  RouteBusService.swift
//  rwethereyet
//
//  Created by Lewis Tham on 14/1/18.
//  Copyright © 2018 somethingwithc. All rights reserved.
//

import Foundation
//map json to RouteBusService objects, to refer to for bus services to grab in initialisation


enum RouteBusService {
    struct Base : Codable {
        let services : [Service]?
        
        enum CodingKeys: String, CodingKey {
            case services = "services"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            services = try values.decodeIfPresent([Service].self, forKey: .services) //R1(from: decoder)// values.decodeIfPresent([String].self, forKey: .r1)
        }
        
    }
    
    struct Service : Codable{
        
        let svcNo:String?
        enum CodingKeys: String, CodingKey {
            case svcNo = "no"//can access nested?
        }
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            svcNo = try values.decodeIfPresent(String.self, forKey: .svcNo)
        }
    }
}
