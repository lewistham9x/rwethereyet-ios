//
//  ViewController.swift
//  rwethereyet
//
//  Created by Lewis Tham on 8/1/18.
//  Copyright © 2018 somethingwithc. All rights reserved.
//

import UIKit
import SwiftLocation
import SwiftOverlays

class ViewController: UIViewController {
    
    let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
    
    var newJourney = Journey()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initData()
        
        
        //observer to update current stop –– will current bus stop and its available services
        NotificationCenter.default.addObserver(forName: Notification.Name("updateSvcs"), object: nil, queue: nil, using: updateCurrentStop(notif: ))
        
        //observer to check if still initialising stops
        NotificationCenter.default.addObserver(forName: Notification.Name("loading"), object: nil, queue: nil, using: showLoading(notif: ))

        
        
        //if user selects
        //use newJourney.chooseSvcRoute(chosenInt: selected)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("Memory warning received")
    }
    
    func showLoading(notif: Notification) -> Void{
        //guard helps deal with optionals
        guard let userInfo = notif.userInfo, //grab all passed values
            let loading = userInfo["loading"] as? Bool
            else{
                return
        }
        
        if (loading)
        {
            //show updating message overlay
            self.showWaitOverlayWithText("Performing First Time Setup...")
        }
        else
        {
            //remove overlays
            self.removeAllOverlays()
        }
    }
    
    func postLoad(loading: Bool)
    {
        NotificationCenter.default.post(
            name: Notification.Name("loading"),
            object: nil,
            userInfo: ["loading":loading])
    }
    
    func updateCurrentStop(notif: Notification) -> Void
    {
        
        //guard helps deal with optionals
        guard let userInfo = notif.userInfo, //grab all passed values
            let lastStop = userInfo["reach"] as? BusStop,
            let destinations = userInfo["dest"] as? [BusStop]!
            else{
                return
        }
        
        
        lbLocation.text = lastStop.name
        let svcs = availSvcs(stop: lastStop)
        
        for svc in svcs
        {
            print(svc.svcNo!+", route "+String(svc.routeNo))
        }
        
        
        print("Current Stop: "+lastStop.name!+" ("+lastStop.stopNo!+")")
        
        print("select your destination:")
        for stop in destinations
        {
            print(stop.name!+" ("+stop.stopNo!+")")
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func initData()
    {
        if (needsUpdate())
        {
            print("Updating database")
            
            postLoad(loading: true)
            
            //if requires update, all methods will run at the same time, causing app to crash
            //possibly due to many accessingz of coredata ––> need to find a way to separate them
            initBusData()
            //print("Database updated")
            
        }
        else
        {
            print("Database up to date")
        }
    }
    
    
    
    func needsUpdate() -> Bool
    {
        //hard code bus service and bus stop count
        let context = self.appDelegate.persistentContainer.viewContext
        
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
    
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!
    
    func initBusData()
    { //must change to run somewhereinside appdelegate thing to update or save all bus api data into coredata
        //initialise and create all bus stops
        
        //must ensure that this is only initialised once, if not bus service routes when created will have duplicate stops too
        
        
        resetBusData() //ERRORS MAY OCCUR, SOMETIMES FAILS TO RESET – shouldnt be too big of a problem if bus stops overlap since will reinit the database again
        
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
                            busStop.latitude = Double(routeStop.latitude)!
                            busStop.longitude = Double(routeStop.longitude)!
                            busStop.name = routeStop.name
                            busStop.stopNo = routeStop.stopNo
                            
                            busStopList.append(busStop)
                            //print("Saved the CoreData Object for "+routeStop.name!)
                            //print(busStop.stopNo!) //DEBUG
                        }
                        self.appDelegate.saveContext() //save Bus Stop to CoreData
                    }
                    print("Loaded all bus stops")
                    
                    
                }
                catch let jsonErr { print("Failed to request bus stop data", jsonErr)}
            }
            
            self.initAllBusServiceData()
            
        }
        task.resume()
        
        /*
         let busServiceRoute = BusServiceRoute(context : context)
         busServiceRoute.hasStops?.array[0]
         
         busStop.formsRoute?.allObjects
         */
    }
    
    func initAllBusServiceData()
    {
        let busSvcsURL = "https://raw.githubusercontent.com/cheeaun/busrouter-sg/master/data/2/bus-services.json"
        print(busSvcsURL)
        
        guard let url = URL(string: busSvcsURL) else {return}
        //self.aiLoading.startAnimating() -- not working
        
        let task = URLSession.shared.dataTask(with: url) { (data, res, err) in
            DispatchQueue.main.async{
                let status = (res as! HTTPURLResponse).statusCode
                print("response status: \(status)")
                do {
                    let jsonDecoder = JSONDecoder()
                    let routeBusSvcs = try jsonDecoder.decode(RouteBusService.Base.self, from: data!)
                    print("Got service array")
                    
                    let routeBusSvcArray = routeBusSvcs.services
                    
                    for routeSvc in routeBusSvcArray! {
                        self.initBusServiceData(svcNo: routeSvc.svcNo!)
                        print(routeSvc.svcNo!)
                        

                    }
                    
                    //self.appDelegate.saveContext()
                    
                }
                catch let jsonErr { print("Failed to request bus service data", jsonErr)}
            }

        }
        task.resume()
    }
    
    
    func initBusServiceData(svcNo: String)//routecount may have to be checked within here itself, if using method separately. check if .count==0 works instead of relying on getting bus service info<<<<<
        
        //MUST ensure that THERE ARE BUS STOPS BEFORE EXECUTING THIS METHOD OR WILL CRASH, DO A CHECK LATER
        //need to check if the bus service already exists before adding if not there will be duplicates
    {
        let context = self.appDelegate.persistentContainer.viewContext
        
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
                            
                            
                            //hard code loading
                            if (svcNo != "NR8")
                            {
                                self.postLoad(loading: true)
                            }

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
                        self.appDelegate.saveContext()//save context once in the external initall method to optimise loading
                        
                        
                        print("Loaded service")
                        
                        
                        //hard code to notify loading complete, no time for proper implementation
                        
                        if (svcNo == "NR8")
                        {
                            self.postLoad(loading: false)

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
        initBusServiceData(svcNo: tbSvc.text!)
    }
    
    @IBAction func btPrintSvcRoute(_ sender: Any) {
        print("Print service button clicked")
        printRoute(svcNo: tbSvc.text!, routeNo: 1)
        printRoute(svcNo: tbSvc.text!, routeNo: 2)
        
    }
    @IBAction func btPrintStopsServices(_ sender: Any) {
        printSvcs(name: tbSvc.text!)
    }
    @IBOutlet weak var lbLocation: UILabel!
    
    
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
            print("printed route")
            print("––––––––––––––––––––––––––––––––––––––––––––––––")
            
        }
        catch
        {
            print("Error")
        }
    }
    
    func printSvcs(name: String)
    {
        let context = self.appDelegate.persistentContainer.viewContext
        
        do
        {
            let result = try context.fetch(BusStop.fetchRequest())
            
            let stops = result as! [BusStop]
            
            var selectedStop : BusStop = BusStop()
            
            for stop in stops{
                if (stop.name == name)
                {
                    selectedStop=stop
                    break
                }
            }
            
            if (selectedStop != nil)
            {
                let services = selectedStop.hasServicesRoute?.array as! [BusServiceRoute]
                
                for service in (services)
                {
                    print("–––––––––––––––––––")
                    print(String(service.svcNo!))
                    print(String(service.routeNo))
                }
                print("printed " + String(services.count) + " services of bus stop " + name)
                
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
            //resetBusData()
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
            //resetBusData()
        }
    }
}

