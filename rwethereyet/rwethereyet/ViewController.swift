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
        
        //resetBusData()// >>SUDDENLY CAUSES A CRASH??? AFTER LAST 3 COMMITS INVOLVING BUS SERVICES
        //initBusData()
        //initBusServiceData(svcNo: "74", routeCount: 2)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!
    
    func initBusData()
    { //must change to run somewhereinside appdelegate thing to update or save all bus api data into coredata
        //initialise and create all bus stops
        
        //must ensure that this is only initialised once, if not bus service routes when created will have duplicate stops too
        
        let busStopsURL = "https://raw.githubusercontent.com/cheeaun/busrouter-sg/master/data/2/bus-stops.json" //"https://busrouter.sg/data/2/bus-stops.json"
        
        let context = self.appDelegate.persistentContainer.viewContext
        
        print(busStopsURL)
        
        
        guard let url = URL(string: busStopsURL) else {return}
        //self.aiLoading.startAnimating() -- not working

        let task = URLSession.shared.dataTask(with: url) { (data, res, err) in
            DispatchQueue.main.async{
                let status = (res as! HTTPURLResponse).statusCode
                print("response status: \(status)")
                do {
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode([RouteBusStop.Base].self, from: data!)
                    
                    let routeBusStopArray = responseModel
                    print("Got stop array")
                    
                    do{
                        let result = try context.fetch(BusStop.fetchRequest())
                        var busStopList = result as! [BusStop]
                        
                        for routeStop in routeBusStopArray {
                            //print("Creating CoreData Object for "+routeStop.name!)
                            
                            let busStop = BusStop(context : context)
                            busStop.latitude = Float(routeStop.latitude)!
                            busStop.longitude = Float(routeStop.longitude)!
                            busStop.name = routeStop.name
                            busStop.stopNo = routeStop.stopNo
                            
                            busStopList.append(busStop)
                            //print("Saved the CoreData Object for "+routeStop.name!)
                            //print(busStop.stopNo!) //DEBUG
                        }
                        self.appDelegate.saveContext() //save Bus Stop to CoreData
                    }
                    print(routeBusStopArray.count)
                    
                    print("Loaded all bus stops")

                    
                }
                catch let jsonErr { print("Failed to request bus stop data", jsonErr)}
            }
        }
        task.resume()

        /*
         let busServiceRoute = BusServiceRoute(context : context)
         busServiceRoute.hasStops?.array[0]
         
         busStop.formsRoute?.allObjects
         */
    }
    
    
    @IBAction func btReinitStops(_ sender: Any) {
        initBusData()
    }
    
    @IBAction func btPrintStops(_ sender: Any)
    {
        printStopNames()
    }
    @IBAction func btResetCoreData(_ sender: Any) {
        resetBusData()
    }
    
    @IBOutlet weak var tbSvc: UITextField!
    @IBAction func btGetAllSvcRoutes(_ sender: Any) {
        initAllBusServiceData()
    }
    
    @IBAction func btGetSvcRoute(_ sender: Any) {
        print("Get service button clicked")
        initBusServiceData(svcNo: tbSvc.text!, routeCount: 1)
    }
    
    @IBAction func btPrintSvcRoute(_ sender: Any) {
        print("Print service button clicked")
        printRoute(svcNo: tbSvc.text!, routeNo: 1)
    }
    
    
    
    //TAKES TOO LONG TO INITIALISE, WILL INITIALISE EACH BUS SERVICE INDIVIDUALLY
    
    func initAllBusServiceData()
    {
        let busSvcsURL = "https://raw.githubusercontent.com/cheeaun/busrouter-sg/master/data/2/bus-services.json"
        print(busSvcsURL)
        Alamofire.request(busSvcsURL).responseArray(keyPath: "services") { (response: DataResponse<[RouteBusService]>) in
            
            let routeBusServiceArray = response.result.value
            
            if (response.result.isSuccess)
            {
                print("Successfully request for bus service list")
                if let routeBusServiceArray =  routeBusServiceArray {
                    
                    for routeSvc in routeBusServiceArray {
                        //print(routeSvc.svcNo!)
                        self.initBusServiceData(svcNo: routeSvc.svcNo!, routeCount: routeSvc.routeCount!)
                    }
                    print("Loaded all bus services")
                }
            }
            else{
                print("Failed to request bus service list")
            }
        }
    }
    
    
    func initBusServiceData(svcNo: String, routeCount: Int16)//routecount may have to be checked within here itself, if using method separately. check if .count==0 works instead of relying on getting bus service info<<<<<
        
        //MUST ensure that THERE ARE BUS STOPS BEFORE EXECUTING THIS METHOD OR WILL CRASH, DO A CHECK LATER
    {
        let context = self.appDelegate.persistentContainer.viewContext
        
        let result = try context.fetch(BusStop.fetchRequest())
        
        let stops = result as! [BusStop]

        let busServiceURL = "https://raw.githubusercontent.com/cheeaun/busrouter-sg/master/data/2/bus-services/" + svcNo + ".json"

        guard let url = URL(string: busServiceURL) else {return}
        //self.aiLoading.startAnimating() -- not working

        let task = URLSession.shared.dataTask(with: url) { (data, res, err) in
            DispatchQueue.main.async{
                let status = (res as! HTTPURLResponse).statusCode
                print("response status: \(status)")
                do {
                    let jsonDecoder = JSONDecoder()
                    let busSvcResponse = try jsonDecoder.decode([RouteBusServiceResponse.Base].self, from: data!)
                    
                    let routeBusStopArray = responseModel
                    print("Successfully requested bus service: " + svcNo)
                    
                    do{
                        if (routeCount > 0) //check if route exists
                        {
                            /*
                            let result = try context.fetch(BusStop.fetchRequest())
                            var busStopList = result as! [BusStop]
                            
                            for routeStop in routeBusStopArray {
                                //print("Creating CoreData Object for "+routeStop.name!)
                                
                                let busStop = BusStop(context : context)
                                busStop.latitude = Float(routeStop.latitude)!
                                busStop.longitude = Float(routeStop.longitude)!
                                busStop.name = routeStop.name
                                busStop.stopNo = routeStop.stopNo
                                
                                busStopList.append(busStop)
                                //print("Saved the CoreData Object for "+routeStop.name!)
                                //print(busStop.stopNo!) //DEBUG
                            }
                            self.appDelegate.saveContext() //save Bus Stop to CoreData
                            */
                            
                            //create bus service route
                            let busServiceRoute = BusServiceRoute(context : context) //need to prevent duplicates later <<<<
                            busServiceRoute.svcNo=svcNo
                            busServiceRoute.routeNo = 1
                            
                            //relate bus service route to bus stops
                            for stopNo in (busSvcResponse?.route1!)!
                            {
                                do
                                {
                                    for stop in stops //relate bus stop object to service accordingly
                                    {
                                        if (stopNo == stop.stopNo!)
                                        {
                                            busServiceRoute.addToHasStops(stop) //associate matching stop to bus service route
                                            stop.addToHasServicesRoute(busServiceRoute) //adds this service's route to the stop (for implementation of viewing what bus services are available at a bus stop, nearby bus services)
                                            break //prevent duplicate stops in bus service route
                                        }
                                    }
                                }
                                catch
                                {
                                    print("Error")
                                }
                            }
                            
                            self.appDelegate.saveContext()//not sure what saves. are relationships for stops saved? how bout second route will it duplicate?
                            
                            print("Loaded route 1 of "+svcNo)
                            
                        }
                        
                        if (routeCount == 2) //check if route exists
                        {
                            //create bus service route
                            let busServiceRoute = BusServiceRoute(context : context) //need to prevent duplicates later<<<<<
                            busServiceRoute.svcNo=svcNo
                            busServiceRoute.routeNo = 2
                            
                            
                            //relate bus service route to bus stops
                            for stopNo in (busSvcResponse?.route2!)!
                            {
                                do
                                {
                                    for stop in stops //relate bus stop object to service accordingly
                                    {
                                        if (stopNo == stop.stopNo!)
                                        {
                                            busServiceRoute.addToHasStops(stop) //associate matching stop to bus service route
                                            stop.addToHasServicesRoute(busServiceRoute) //adds this service's route to the stop (for implementation of viewing what bus services are available at a bus stop, nearby bus services)
                                            
                                            break//prevent duplicate stops in bus service route
                                        }
                                    }
                                }
                                catch
                                {
                                        print("Error")
                                }
                            }
                            self.appDelegate.saveContext()
                            print("Loaded route 2 of "+svcNo)
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
            
            print(String(stops.count)+" stops")
        }
        catch
        {
            print("Error")
        }
    }
    
    func printRoute(svcNo: String, routeNo: Int16)
    {
        let context = self.appDelegate.persistentContainer.viewContext
        
        do
        {
            let result = try context.fetch(BusServiceRoute.fetchRequest())
            
            let routes = result as! [BusServiceRoute]
            
            for route in routes{
                if (route.svcNo == svcNo)
                {
                    if (route.routeNo == routeNo)
                    {
                        let stops = route.hasStops?.array as! [BusStop]
                        
                        for stop in stops {
                            print(stop.name!) //! used to remove Optional()
                        }
                        break //prevent multiple printing of multiple services
                    }
                }
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
}

