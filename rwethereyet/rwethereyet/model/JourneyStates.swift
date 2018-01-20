//
//  JourneyStates.swift
//  rwethereyet
//
//  Created by Lewis Tham on 19/1/18.
//  Copyright © 2018 somethingwithc. All rights reserved.
//

import Foundation

protocol JourneyState{ //applying state pattern
    init(myJourney : Journey)
    func onLocationChanged(newLat: Double, newLon: Double)
    func checkStop(lat: Double, lon: Double)
    func changeStop(stop: BusStop)
    func notify()
    func updateView()
}

class SelectState: JourneyState{
    
    var myJourney : Journey

    required init(myJourney : Journey) {
        self.myJourney = myJourney
    }
    
    func onLocationChanged(newLat: Double, newLon: Double) {
        checkStop(lat: newLat, lon: newLon)
        
    }
    
    func checkStop(lat: Double, lon: Double) {
        let stopList = getAllStops()
        
        print("checking if near any stop")
        
        for stop in stopList
        {
            if (isAtStop(stop: stop, lat: lat, lon: lon)){
                //prevStop only changes to anything within bus stop list if its in select state
                //select state changestop will cause an update in bus services displayed
                //if its in other state, it will check if its the next stop in the route first
                //need to update receiver
                print("New Stop Detected: "+stop.name!)
                changeStop(stop: stop)
                break
            }
        }
    }
    
    func changeStop(stop: BusStop) {
        //set prevstop to said stop
        myJourney.setPrevStop(stop: stop)
        //in other states, will change state, segue to new controller
        //gets all bus services based on prevStop
        
        //updates services available verytime prevStop updates during selection process to show bus destinations to choose from
        myJourney.setSvcRoutesForCurrentStop()

        //upon user selection will have to change bus service and rotue
        

    }
    
    func notify() {
        
    }
    
    func updateView() {
        
    }
    
}
