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
    
    private var state : JourneyState!
    
    private var selectState : JourneyState!
    private var inJourneyState : JourneyState!
    private var reachingState : JourneyState!
    private var reachedState : JourneyState!
    
    private var currLat : Double
    private var currLon : Double
    private var reachedStop : BusStop? //reached stop is the last stop that user reached (any stop or within the route depending on the state), will be nil if user hasnt reached a stop
    
    private var currStop : BusStop? //curr stop is the stop the user is at NOW, user can be not at any stop at any point of time    
    
    //private var availSvcs : [BusServiceRoute]? derived from prevStop
    private var chosenServiceRoute : BusServiceRoute? //required to save service number
    
    
    var routeDestinations : [BusStop]?
    var busRoute : [BusStop]?
    
    
    init() {
        currLat = 0
        currLon = 0
        reachedStop = nil
        
        busRoute = nil
        
        selectState = SelectState(myJourney: self) //change to subclass later
        inJourneyState = SelectState(myJourney: self)
        reachingState = SelectState(myJourney: self)
        reachedState = SelectState(myJourney: self)
        
        state = selectState
        
        print("checking stops now")
        startLoc()
    }
    
    //derived-ish attributes?
    public func getReachedStop() -> BusStop?
    {
        return reachedStop
    }
    
    private func getSvcNo() -> String
    {
        return (chosenServiceRoute?.svcNo)!
    }
    private func getSvcRoute() -> Int16
    {
        return (chosenServiceRoute?.routeNo)!
    }
    
    private func prevStopIndex() -> Int //??? correct???
    {
        let i = busRoute?.index(of: reachedStop!) //finding index of the stop user is at
        
        return i!
    }
    private func lastStopIndex() -> Int
    {
        let i = (busRoute?.count)!-1
        
        return i
    }
    func stopsLeft() -> Int //??? not sure if its correct
    {
        return lastStopIndex() - prevStopIndex()
    }
    
    //proper functions
    
    private func startLoc()
    {
        Locator.requestAuthorizationIfNeeded(.always)
        
        Locator.events.listen { newStatus in
            print("Authorization status changed to \(newStatus)")
        }
        Locator.subscribePosition(
            accuracy: .room,
            onUpdate:
            {
                newLocation in
                self.currLat = newLocation.coordinate.latitude
                self.currLon = newLocation.coordinate.longitude
                
                self.state.onLocationChanged(newLat: self.currLat, newLon: self.currLon)}
            )
        {
            (err, lastlocation) -> (Void) in
            print("Failed with err: \(err)")
        }
    }

    public func updateSelectViewSvcsInfo()
    {
        //post update to viewcontroller to show new bus services
        NotificationCenter.default.post(
            name: Notification.Name("updateSvcs"),
            object: nil,
            userInfo: ["reachedStop":reachedStop!,"currentStop":currStop!])
        
        //no need an observer to update stops after selection as journey can be accessed for routeDestinations
    }
    
    
    //user input(select from tvc) to run this method
    //upon service switch, need to update the tableview controller with routeDestinations
    public func chooseSvcRoute(chosenInt: Int)
    {
        chosenServiceRoute = availSvcs(stop: currStop!)[chosenInt]
        setRouteDestinations(busSvcRoute: chosenServiceRoute!)
        //tvc change to chosen svcroute
        updateSelectViewSvcsInfo()
    }
    
    //gets all the available destinations based on the service selected, will only show bus stops after the bus stop the user is at
    private func setRouteDestinations(busSvcRoute : BusServiceRoute)
    {
        let route = busSvcRoute.hasStops?.array as! [BusStop] //grab the bus stop list of the bus service route user selected
        
        var startIndex = route.index(of: reachedStop!)! //finding index of the stop user is at

        var i = startIndex
        
        var destinations : [BusStop] = []
        
        //trim to create journey route from service's route
        while (i <= route.count-1)
        {
            destinations.append(route[i])
            i = i+1
        }
        routeDestinations=destinations //sets the route destinations to whatever stops are available
    }
    
    //user input (selects the bus stop to set the route of the bus journey) ––> bus service no and route will be locked in too
    //selects from trimmed list of from current stop to end, to create the bus journey route
    public func selectBusRoute(selectedIndex : Int16)
    {
        setRoute(end: selectedIndex, route: routeDestinations!)
    }
    
    
    //from selection, create a bus journey route proceed to journey state
    private func setRoute(end: Int16, route: [BusStop])
    {
        var journeyRoute : [BusStop] = []
        
        var i = 0
        //trim to create journey route from service's route
        while (i <= end)
        {
            journeyRoute.append(route[i])
            i = i+1
        }
        
        print(journeyRoute[0].name!+journeyRoute.last!.name!)
        
        busRoute=journeyRoute
        
        //change state to journey state
        self.state = inJourneyState
        
        //segue to new vc
        //vc.segue or some shit l0l0l0
        //not required because button already does so?
    }
    
    
    func setCurrStop(stop: BusStop?)
    {
        currStop = stop
    }
    
    func setReachedStop(stop: BusStop)
    {
        reachedStop = stop
    }
    
}



//public functions

//get the available bus services for a particular bus stop

public func availSvcs(stop: BusStop) -> [BusServiceRoute]
{
    return (stop.hasServicesRoute?.array as? [BusServiceRoute])!
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



