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
    private var alertState : JourneyState!
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
        inJourneyState = InJourneyState(myJourney: self)
        alertState = AlertState(myJourney: self)
        reachedState = ReachedState(myJourney: self)
        
        state = selectState
        
        print("checking stops now")
        startLoc()
    }
    
    
    
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
                self.onLocationChanged(newLat: newLocation.coordinate.latitude, newLon: newLocation.coordinate.longitude)}
            )
        {
            (err, lastlocation) -> (Void) in
            print("Failed with err: \(err)")
        }
    }
    
    private func onLocationChanged(newLat: Double, newLon: Double)
    {
        currLat = newLat
        currLon = newLon
        
        if (isAtAStop(lat: newLat, lon: newLon))
        {
            if (state.stopIsGud())
            {
                reachedStop=currStop
                selectSvc(svcInt: 0)
            }
        }
    }
    
    //function checks if the bus is at ANY stop that exists
    private func isAtAStop(lat: Double, lon: Double) -> Bool
    {
        let stopList = getAllStops()
        
        print("checking if near any stop")
        
        var succ = false
        
        //check if the user is at the location of any bus stop
        for stop in stopList
        {
            if (isAtStop(stop: stop, lat: lat, lon: lon))
            {
                //prevStop only changes to anything within bus stop list if its in select state
                //select state changestop will cause an update in bus services displayed
                //if its in other state, it will check if its the next stop in the route first
                //need to update receiver
                print("Stop Detected: "+stop.name!)
                
                currStop = stop
                succ = true
                break
            }
        }
        return succ
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*––––––––––––––––––––––––––––
        SELECTION STATE FUNCTIONS
 	–––––––––––––––––––––––––––––*/
    
    //user input(select from tvc) to run this method, will auto select 0 if first reach
    //upon service switch, need to update the tableview controller with routeDestinations
    public func selectSvc(svcInt: Int)
    {
        chosenServiceRoute = availSvcs(stop: currStop!)[svcInt]
        updateAvailDests(busSvcRoute: chosenServiceRoute!)
        
        
        //tvc change to chosen svcroute
        postSelectionInfo() //updates viewcontroller with new destinations
    }
    
    
    public func postSelectionInfo()
    {
        //post update to viewcontroller to show new bus services
        NotificationCenter.default.post(
            name: Notification.Name("postSelectionInfo"),
            object: nil,
            userInfo: ["reach":reachedStop!,"dest":routeDestinations!])
        
        //no need an observer to update stops after selection as journey can be accessed for routeDestinations
    }
    
    //gets all the available destinations based on the service selected, will only show bus stops after the bus stop the user is at
    private func updateAvailDests(busSvcRoute : BusServiceRoute)
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
    public func selectBusRoute(end : Int16)
    {
        var journeyRoute : [BusStop] = []
        
        var i = 0
        //trim to create journey route from service's route
        while (i <= end)
        {
            journeyRoute.append(routeDestinations![i])
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
    
    
    
    //getters & derived-ish attributes?

    public func getCurrStop() -> BusStop?
    {
        return currStop
    }
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
}





















/*––––––––––––––
 PUBLIC FUNCTIONS
 –––––––––––––––*/

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



