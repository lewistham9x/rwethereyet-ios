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
    
    let stopsToAlert = 1 //configurable stops before alert state–– to implement configurable in the future
    
    private var currLat : Double
    private var currLon : Double
    private var reachedStop : BusStop? //reached stop is the last stop that user reached (any stop or within the route depending on the state), will be nil if user hasnt reached a stop
    
    private var currStop : BusStop? //curr stop is the stop the user is at NOW, user can be not at any stop at any point of time    
    
    private var chosenServiceRoute : BusServiceRoute? //required to save service number
    
    var routeDestinations : [BusStop]?
    var busRoute : [BusStop]?
    
    
    init() {
        currLat = 0
        currLon = 0
        reachedStop = nil
        
        busRoute = nil
        
        selectState = SelectState(myJourney: self)
        inJourneyState = InJourneyState(myJourney: self)
        alertState = AlertState(myJourney: self)
        reachedState = ReachedState(myJourney: self)
        
        state = selectState
        
        //startLoc()
    }
    
    public func startLoc()
    {
        print("checking stops now")
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
        /*
        //hard code debug
        let fnewLat = 1.33243896358504
        let fnewLon = 103.77768506316727
*/
        
        currLat = newLat
        currLon = newLon
         
        if (isAtAStop(lat: newLat, lon: newLon))
        {
            state.reachedGudStop()
        }
    }
    
    //function checks if the bus is at ANY stop that exists
    private func isAtAStop(lat: Double, lon: Double) -> Bool
    {
        let stopList = getAllStops()
        
        print("checking if near any stop")
        
        var succ = false
        
        var nearStops = [] as! [BusStop]
        
        //check if the user is at the location of any bus stop
        for stop in stopList
        {
            if (isNearStop(stop: stop, lat: lat, lon: lon))
            {
                //prevStop only changes to anything within bus stop list if its in select state
                //select state changestop will cause an update in bus services displayed
                //if its in other state, it will check if its the next stop in the route first
                //need to update receiver
                print(stop.name!+" is near")
                
                nearStops.append(stop)
                succ = true
            }
        }
        
        if succ //if at a stop, calculate and set curr as the nearest one
        {
            var nStop : BusStop = nearStops[0] //neareststop
            var currDist = distance(lat1: lat, lon1: lon, lat2: nStop.latitude, lon2: nStop.longitude, unit: "K")

            for stop in nearStops
            {
                let dist = distance(lat1: lat, lon1: lon, lat2: stop.latitude, lon2: stop.longitude, unit: "K")
                print(String(dist))
                if (dist < currDist)
                {
                    nStop = stop
                    currDist = dist
                 }
            }
            
            print("user is closest to " + nStop.name!)
            currStop = nStop
        }
        
        return succ
    }
    
    public func getUpdatedPost() //get updated info
    {
        postJourneyReach()
    }
    
    
    
    
    
    
    
    
    /*––––––––––––––––––––––––––––––––
        JOURNEY & ALERT STATE FUNCTIONS
     –––––––––––––––––––––––––––––––––*/
    
    //if user reaches the next stop
    public func reachStop()
    {
        if isWithinRoute()
        {
            if reachedNextStop()
            {
                postJourneyReach()
                state.checkStopsLeft()
            }
        }
    }
    
    private func isWithinRoute() -> Bool
    {
        let stopList = routeStops(svc: chosenServiceRoute!)
        
        let succ = stopList.contains(currStop!)//checks if the current route contains the current stop
        
        return succ
    }
    
    private func reachedNextStop() -> Bool
    {
        //new algo: check if the index of currstop is bigger than reachedstop
        //helps if location is off when it passes a stop, will be able to continue the journey, instead of checking if the bus is at the location of prevStop+1
        
        let stopList = routeStops(svc: chosenServiceRoute!)

        var succ = false
        
        
        //get the indeces of the current bus stop and previously reached bus stop, if current is higher it takes over
        
        let currIndex = getStopIndex(stop: currStop!, array: stopList)
        let prevIndex = prevStopIndex()
        
        if (prevIndex>currIndex)
        {
            reachedStop = currStop!
            succ = true
        }
        
        return succ //hehexd
    }
    
    public func postJourneyReach()
    {
        //post update to viewcontroller to show new stop info and stops remaining
        //maybe can post the stop after, so that can do the graphic
        //future feature: will have 3 dots in the journey screen
        //first represents current, second represents next and third represents destination
        //can show distance to the next stop(between first and second)
        //can show stops left after the next stop (between second and third)
        //distance to next stop will be denoted by a little moving car graphic
        //will post the final stop, the next stop and distance to it to accomodate this future feature
        let finalStop = busRoute![lastStopIndex()]
        let nextStop = busRoute![prevStopIndex()+1]
        let distanceToNext = 0.0
        
        NotificationCenter.default.post(
            name: Notification.Name("postJourneyReach"),
            object: nil,
            userInfo: ["reach":reachedStop!,"left":stopsLeft(),"final":finalStop,"next":nextStop,"distance":distanceToNext])
    }
    
    public func postJourneyAlert()
    {
        NotificationCenter.default.post(
            name: Notification.Name("postJourneyAlert"),
            object: nil,
            userInfo: ["alert":true])
    }
    
    public func postJourneyEnd()
    {
        NotificationCenter.default.post(
            name: Notification.Name("postJourneyAlert"),
            object: nil,
            userInfo: ["end":true])
    }
    
    
    //journey state to alert state
    public func toAlertState()
    {
        self.state = alertState
    }

    
    //alert state to reached state
    public func toReachedState()
    {
        self.state = reachedState
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

        var i = startIndex+1
        
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
    
    
    
    //setters, getters & derived-ish attributes?

    public func setCurrStop(stop: BusStop)
    {
        currStop=stop
    }
    public func getCurrStop() -> BusStop?
    {
        return currStop
    }
    public func updateReachedStop(stop: BusStop)
    {
        reachedStop=stop
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
        var i = 0
        
        if busRoute?.isEmpty == false
        {
            i = (busRoute?.count)! - 1
        }
        
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

//get the index of a certain stop within its array
private func getStopIndex(stop: BusStop, array: [BusStop]) -> Int
{
    let i = array.index(of: stop) //finding index of the stop user is at
    return i!
}

//get the available bus services for a particular bus stop
public func availSvcs(stop: BusStop) -> [BusServiceRoute]
{
    return (stop.hasServicesRoute?.array as? [BusServiceRoute])!
}

//get the bus route for a particular bus service
public func routeStops(svc: BusServiceRoute) -> [BusStop]
{
    return (svc.hasStops?.array as? [BusStop])!
}


public func isNearStop(stop: BusStop, lat: Double, lon: Double) -> Bool
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



