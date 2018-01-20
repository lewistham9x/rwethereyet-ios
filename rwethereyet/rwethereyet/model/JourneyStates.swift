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
    func changeStop(stop: BusStop?, legible: Bool)
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
        
        
        var currStop : BusStop?

        //check if the user is at the location of any bus stop
        for stop in stopList
        {
            if (isAtStop(stop: stop, lat: lat, lon: lon)){
                //prevStop only changes to anything within bus stop list if its in select state
                //select state changestop will cause an update in bus services displayed
                //if its in other state, it will check if its the next stop in the route first
                //need to update receiver
                print("New Stop Detected: "+stop.name!)
                
                currStop = stop
                break
            }
        }
        
        
        //sends nil if not at a particular bus stop
        if (currStop != nil && currStop != myJourney.getReachedStop()) //if stop is eligible  (is within the correct route or
        {
            changeStop(stop: currStop, legible: true)
        }
        else
        {
            changeStop(stop: currStop, legible: false)
        }
    }
    
    
    
    func changeStop(stop: BusStop?, legible: Bool) {
        
        myJourney.setCurrStop(stop: stop) //sets current stop whether its eligible or not
        if (legible) //in this case legible means that the user is at a bus stop
        {
            myJourney.setReachedStop(stop: stop!)
            
            //updates services available verytime prevStop updates during selection process to show bus destinations to choose from
            
            myJourney.updateSelectViewSvcsInfo()
            
            //will show first service by default
            //upon user selection will have to change bus service and route
            myJourney.chooseSvcRoute(chosenInt: 0)
        }
        else
        {
            //do nothing, wont update to show no bus services
        }
    }
    
    func notify() {
        
    }
    
    func updateView() {
        
    }
    
}
