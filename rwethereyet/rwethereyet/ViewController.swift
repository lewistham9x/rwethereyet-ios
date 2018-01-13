//
//  ViewController.swift
//  rwethereyet
//
//  Created by Lewis Tham on 8/1/18.
//  Copyright © 2018 somethingwithc. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper

class ViewController: UIViewController {
    
    let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        resetBusData()
        initBusData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   
    func initBusData()
    { //must change to run somewhereinside appdelegate thing to update or save all bus api data into coredata
        //initialise and create all bus stops
        
        let busStopsURL = "https://raw.githubusercontent.com/cheeaun/busrouter-sg/master/data/2/bus-stops.json" //"https://busrouter.sg/data/2/bus-stops.json"
        
        let context = self.appDelegate.persistentContainer.viewContext
        
        print(busStopsURL)
        
        Alamofire.request(busStopsURL).responseArray { (response: DataResponse<[RouteBusStop]>) in
            
            let routeBusStopArray = response.result.value
            
            if (response.result.isSuccess)
            {
                if let routeBusStopArray =  routeBusStopArray {
                    
                    for routeStop in routeBusStopArray {
                        let busStop = BusStop(context : context)
                        busStop.latitude = Float(routeStop.latitude)!
                        busStop.longitude = Float(routeStop.longitude)!
                        busStop.name = routeStop.name
                        busStop.stopNo = routeStop.stopNo
                        
                        self.appDelegate.saveContext() //save Bus Stop to CoreData
                        
                        print(busStop.stopNo!) //DEBUG
                    }
                }
            }
            else
            {
                print("Attempting to grab data again")
                self.initBusData()
            }
        }
        
        initBusServiceData(svcNo: "74")
        
        //initialise Bus Services
        
        
        
        /*
        let busStop = BusStop(context : context)
        busStop.stopNo = "0"
        
         
        busStop.addToFormsRoute(<#T##value: BusServiceRoute##BusServiceRoute#>)
        
        let busServiceRoute = BusServiceRoute(context : context)
        busServiceRoute.hasStops?.array[0]
        
        busStop.formsRoute?.allObjects
        */
        //grab all bus service numbers
        //query each bus service
        //for each route
        //for each bus stop number in the service
        //busStop.addToServiceRoutes(serviceRoute)
        //busServiceRoutes.addToBusStop(busStop)
    }
    
    
    @IBAction func btPrintStops(_ sender: Any)
    {
        printStopNames()
    }
    @IBAction func btResetCoreData(_ sender: Any) {
        resetBusData()
    }
    
    func initBusServiceData(svcNo: String)
    {
        let context = self.appDelegate.persistentContainer.viewContext
        
        let busServiceURL = "https://raw.githubusercontent.com/cheeaun/busrouter-sg/master/data/2/bus-services/" + svcNo + ".json"
        Alamofire.request(busServiceURL).responseObject { (response: DataResponse<RouteBusServiceResponse>) in
            
            let busSvcResponse = response.result.value
            print((busSvcResponse?.route1![0])!+"<<<<<<")
            
            //create BusService object in CoreData
            let busService = BusService(context : context)
            busService.svcNo=svcNo
            
            
            if (busSvcResponse?.route1![0] != "") //check if route exists
            {
                //create bus service route
                let busServiceRoute = BusServiceRoute(context : context)
                busServiceRoute.routeNo = 1
                
                //relate bus service route to bus service
                busService.addToHasRoute(busServiceRoute) //adds routes to service
                
                busServiceRoute.fromService(busService)
                
                //relate bus service route to bus stops
                for stopNo in (busSvcResponse?.route1!)!
                {
                    do
                    {
                        let result = try context.fetch(BusStop.fetchRequest())
                        
                        let stops = result as! [BusStop]
                        
                        for stop in stops //relate bus stop object to service accordingly
                        {
                            if (stopNo == stop.stopNo!)
                            {
                                
                            }
                        }
                    }
                    catch
                    {
                        print("Error")
                    }
                }
                
            }
            
            
            for stopNo in (busSvcResponse?.route2)!
            {
                
            }
            
        }
    }
    
    func printStopNames()
    {
        let context = self.appDelegate.persistentContainer.viewContext

        do
        {
            let result = try context.fetch(BusStop.fetchRequest())
            
            let stops = result as! [BusStop]
            
            for stop in stops {
                print(stop.name!) //! used to remove Optional()
            }
        }
        catch
        {
            print("Error")
        }
    }
    
    func resetBusData()
    {
        let context = self.appDelegate.persistentContainer.viewContext
         
         
        //need to clear all data temporarily so no duplicates will be saved
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
    }
}

