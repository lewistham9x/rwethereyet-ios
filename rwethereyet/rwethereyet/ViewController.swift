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
        
        initBusData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    func initBusData(){ //must change to run somewhereinside appdelegate thing to update or save all bus api data into coredata
        //let context = self.appDelegate.persistentContainer.viewContext
        //initialise and create all bus stops
        
        let busStopsURL = "https://raw.githubusercontent.com/cheeaun/busrouter-sg/master/data/2/bus-stops.json" //"https://busrouter.sg/data/2/bus-stops.json"
        print(busStopsURL)
        Alamofire.request(busStopsURL).responseArray { (response: DataResponse<[RouteBusStop]>) in
            
            let routeBusStopArray = response.result.value
            
            if let routeBusStopArray =  routeBusStopArray {
                
                //let busStopArray =
                //let busStop = BusStop(context : context)
                
                for routeStop in routeBusStopArray {
                    //busStop.latitude = routeStop.latitude
                    print("test")
                }
            }
        }
        
        
        
        
        
        /*
        let busStop = BusStop(context : context)
        busStop.stopNo = "0"
        
        */
        //https://github.com/tristanhimmelman/AlamofireObjectMapper
        
        /*
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
        
        
        
        
        
        //need to clear all data temporarily so no duplicates will be saved
        
    }
}

