//
//  Data.swift
//  rwethereyet
//
//  Created by Lewis Tham on 19/1/18.
//  Copyright © 2018 somethingwithc. All rights reserved.
//

import Foundation
import UIKit

let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
let context = appDelegate.persistentContainer.viewContext

func getAllStops() -> [BusStop]
{
    do
    {
        let result = try context.fetch(BusStop.fetchRequest())
        
        let stops = result as! [BusStop]
        
        return stops
    }
    catch{
        return []
    }
}

func getAllSvcs() -> [BusServiceRoute]
{
    do
    {
        let result = try context.fetch(BusServiceRoute.fetchRequest())
        
        let svc = result as! [BusServiceRoute]
        
        return svc
    }
    catch{
        return []
    }
}
