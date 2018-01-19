//
//  Journey.swift
//  rwethereyet
//
//  Created by Lewis Tham on 19/1/18.
//  Copyright © 2018 somethingwithc. All rights reserved.
//


//handles global functions regarding locations and bus journey

import Foundation
import CoreData
import SwiftLocation

public class Journey{
    init() {
        checkCurrentStop()
    }
    //static var currentStop : BusStop
    
    func checkCurrentStop()
    {
        Locator.requestAuthorizationIfNeeded(.always)
        
        Locator.events.listen { newStatus in
            print("Authorization status changed to \(newStatus)")
        }
        
        /*
         //initialise location checks
         Locator.subscribeSignificantLocations(onUpdate: { newLocation in
         print("New location \(newLocation)")
         }) { (err, lastLocation) -> (Void) in
         print("Failed with err: \(err)")
         }
         */
        
        Locator.subscribePosition(accuracy: .room, onUpdate:
            {
                newLocation in
                print("New location \(newLocation)")
                
                let stopList = getAllStops()
                for stop in stopList
                {
                    if (isAtStop(stop: stop, lat: newLocation.coordinate.latitude, lon: newLocation.coordinate.longitude)){
                        
                        break
                    }
                }
        })
        {
            (err, lastlocation) -> (Void) in
            print("Failed with err: \(err)")
        }
    }
}






public func isAtStop(stop: BusStop, lat: Double, lon: Double) -> Bool
{
    if (withinRadius(stop: stop,lat: lat,lon: lon,rad: 50)) //to make radius customisable in the future as a sensitivity feature, by default, the current fine-tuned accurate radius is 50m
    {
        return true
    }
    else
    {
        return false
    }
}

public func withinRadius(stop: BusStop, lat: Double, lon: Double, rad: Double) -> Bool //rad is in metres
{
    let distanceBetween = distance(lat1: lat, lon1: lon, lat2: stop.latitude, lon2: stop.longitude, unit: "K") //in km
    if distanceBetween*1000 < rad{
        return true
    }
    else{
        return false
    }
}



