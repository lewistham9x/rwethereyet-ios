//
//  DataInitialiser.swift
//  rwethereyet
//
//  Created by Lewis Tham on 19/1/18.
//  Copyright © 2018 somethingwithc. All rights reserved.
//

import Foundation
import SwiftOverlays


func postLoad(loading: Bool)
{
    NotificationCenter.default.post(
        name: Notification.Name("loading"),
        object: nil,
        userInfo: ["loading":loading])
}

//code below is just initialising data from database dont touch l0l
func initData()
{
    if (needsUpdate())
    {
        print("Updating database")
        
        postLoad(loading: true)
        
        resetCoreData() //ERRORS MAY OCCUR, SOMETIMES FAILS TO RESET – shouldnt be too big of a problem if bus stops overlap since will reinit the database again
        initBusStopData()
    }
    else
    {
        print("Database up to date")
    }
}

func needsUpdate() -> Bool
{
    //hard code bus service and bus stop count
    let context = appDelegate.persistentContainer.viewContext
    do
    {
        let a = try context.fetch(BusStop.fetchRequest())
        let stops = a as! [BusStop]
        if (stops.count == 4856) //will save last stop count to check against in the future, as of now, 4856 is number of bus stops
        {
            let b = try context.fetch(BusServiceRoute.fetchRequest())
            
            let svcs = b as! [BusServiceRoute]
            if (svcs.count == 561) //will save last service count to check against in the future, as of now, 561 is the number of bus services
            {
                return false
            }
            else{
                return true
            }
        }
        else{
            return true
        }
    }
    catch
    {
        return true
    }
}




func initBusStopData()
{ //must change to run somewhereinside appdelegate thing to update or save all bus api data into coredata
    //initialise and create all bus stops
    //must ensure that this is only initialised once, if not bus service routes when created will have duplicate stops too
    let busStopsURL = "https://raw.githubusercontent.com/cheeaun/busrouter-sg/master/data/2/bus-stops.json"
    let context = appDelegate.persistentContainer.viewContext
    print(busStopsURL)
    guard let url = URL(string: busStopsURL) else {return}
    
    let task = URLSession.shared.dataTask(with: url) { (data, res, err) in
        DispatchQueue.main.async{
            let status = (res as! HTTPURLResponse).statusCode
            print("response status: \(status)")
            do {
                let jsonDecoder = JSONDecoder()
                
                let responseModel = try jsonDecoder.decode([RouteBusStop.Base].self, from: data!)
                
                let routeBusStopArray = responseModel
                
                let stopCount = routeBusStopArray.count
                
                do{
                    let result = try context.fetch(BusStop.fetchRequest())
                    var busStopList = result as! [BusStop]
                    
                    var count = 1
                    
                    for routeStop in routeBusStopArray {
                        //print("Creating CoreData Object for  "+routeStop.name!)
                        let busStop = BusStop(context : context)
                        busStop.latitude = Double(routeStop.latitude)!
                        busStop.longitude = Double(routeStop.longitude)!
                        busStop.name = routeStop.name
                        busStop.stopNo = routeStop.stopNo
                        
                        busStopList.append(busStop)
                        //print("Saved the CoreData Object for "+routeStop.name!)
                        //print(busStop.stopNo!) //DEBUG
                        
                        count = count + 1
                        
                        if (count == stopCount)
                        {
                            initBusStopComplete()
                        }
                    }
                }
            }
            catch let jsonErr { print("Failed to request bus stop data", jsonErr)}
        }
    }
    task.resume()
}

//this functions runs when the list of all bus stops have been initialised
func initBusStopComplete()
{
    appDelegate.saveContext() //save Bus Stop to CoreData
    print("Loaded all bus stops")
    initServiceListData()
}


func initServiceListData()
{
    let busSvcsURL = "https://raw.githubusercontent.com/cheeaun/busrouter-sg/master/data/2/bus-services.json"
    print(busSvcsURL)
    guard let url = URL(string: busSvcsURL) else {return}

    let task = URLSession.shared.dataTask(with: url) { (data, res, err) in
        DispatchQueue.main.async{
            let status = (res as! HTTPURLResponse).statusCode
            print("response status: \(status)")
            do {
                let jsonDecoder = JSONDecoder()
                let routeBusSvcs = try jsonDecoder.decode(RouteBusService.Base.self, from: data!)
                
                let routeBusSvcArray = routeBusSvcs.services
                
                var svcList = [] as! [String]
                
                for routeSvc in routeBusSvcArray! {
                    svcList.append(routeSvc.svcNo!)
                }
                initServiceListComplete(svcs: svcList)
            }
            catch let jsonErr { print("Failed to request bus service data", jsonErr)}
        }
    }
    task.resume()
}

func initServiceListComplete(svcs: [String])
{
    
}



func initBusServiceData(svcNo: String)//routecount may have to be checked within here itself, if using method separately. check if .count==0 works instead of relying on getting bus service info<<<<<
    
    //MUST ensure that THERE ARE BUS STOPS BEFORE EXECUTING THIS METHOD OR WILL CRASH, DO A CHECK LATER
    //need to check if the bus service already exists before adding if not there will be duplicates
{
    let context = appDelegate.persistentContainer.viewContext
    
    let busServiceURL = "https://busrouter.sg/data/2/bus-services/" + svcNo + ".json"
    
    guard let url = URL(string: busServiceURL) else {return}
    //self.aiLoading.startAnimating() -- not working
    
    let task = URLSession.shared.dataTask(with: url) { (data, res, err) in
        DispatchQueue.main.async{
            let status = (res as! HTTPURLResponse).statusCode
            print("response status: \(status)")
            do {
                let jsonDecoder = JSONDecoder()
                let busSvcResponse = try jsonDecoder.decode(RouteBusServiceResponse.Base.self, from: data!)
                
                //initialise bus stop list
                let stopsResult = try context.fetch(BusStop.fetchRequest())
                var stops = stopsResult as! [BusStop]
                
                //initialise bus service list
                let svcsResult = try context.fetch(BusServiceRoute.fetchRequest())
                var svcs = svcsResult as! [BusServiceRoute]
                
                //count routes for received bus service
                var routeCount = 0
                if (busSvcResponse.r1?.stops?.count == 0)
                {
                    routeCount = 0 //bus service 969A no crash plz
                }
                else if (busSvcResponse.r2?.stops?.count == 0)
                {
                    routeCount = 1
                }
                else
                {
                    routeCount = 2
                }
                
                //print(stops![0])
                
                do{
                    var i = 1
                    while (i<=routeCount)
                    {
                        //create bus service route
                        let busServiceRoute = BusServiceRoute(context : context) //need to prevent duplicates later <<<<
                        busServiceRoute.svcNo=svcNo
                        
                        var routeSvcStops : [String]
                        
                        if (i==1)
                        {
                            routeSvcStops = (busSvcResponse.r1?.stops)!
                            busServiceRoute.routeNo = 1
                        }
                            
                        else
                        {
                            routeSvcStops = (busSvcResponse.r2?.stops)!
                            busServiceRoute.routeNo = 2
                        }
                        
                        //relate bus service route to bus stops
                        for routeStop in (routeSvcStops)
                        {
                            for stop in stops //relate bus stop object to service accordingly
                            {
                                if (routeStop == stop.stopNo!)
                                {
                                    busServiceRoute.addToHasStops(stop) //associate matching stop to bus service route
                                    stop.addToHasServicesRoute(busServiceRoute) //adds this service's route to the stop (for implementation of viewing what bus services are available at a bus stop, nearby bus services)
                                    break //prevent duplicate stops in bus service route
                                }
                            }
                            
                            
                        }
                        
                        svcs.append(busServiceRoute)
                        print("Loaded route " +  String(i) + " of "+svcNo)
                        
                        i = i+1 //increase count
                    }
                    appDelegate.saveContext()//save context once in the external initall method to optimise loading
                    
                    
                    print("Loaded service")
                    
                    
                    //hard code to notify loading complete, no time for proper implementation
                    
                    if (svcNo == "NR8")
                    {
                        postLoad(loading: false)
                        
                    }
                    
                }
                
            }
            catch let jsonErr { print("Failed to request bus stop data", jsonErr)}
        }
    }
    task.resume()
    
    /*
     print(svcNo+"'s first route\n––––––––––––––")
     self.printRoute(svcNo: svcNo, routeNo: 1)
     */
}


    
func resetCoreData()
{
    let context = appDelegate.persistentContainer.viewContext
    //need to clear all data temporarily so no duplicates will be saved
    //occasionally bus stops dont reset, have error
    do
    {
        let result = try context.fetch(BusStop.fetchRequest())
        var busStops = result as! [BusStop]
        
        for stop in busStops
        {
            context.delete(stop)
        }
        
        try context.save()
        
        print("Bus Stops reset")
    }
    catch
    {
        print("Error")
    }
    
    do
    {
        let result = try context.fetch(BusServiceRoute.fetchRequest())
        var busSvcs = result as! [BusServiceRoute]
        
        for svc in busSvcs
        {
            context.delete(svc)
        }
        
        try context.save()
        
        print("Bus Services reset")
    }
    catch
    {
        print("Error")
    }
}
