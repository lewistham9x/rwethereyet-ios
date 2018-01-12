//
//  ViewController.swift
//  rwethereyet
//
//  Created by Lewis Tham on 8/1/18.
//  Copyright © 2018 somethingwithc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    func initBusData(){ //must change to run somewhereinside appdelegate thing to update or save all bus api data into coredata
        let context = self.appDelegate.persistentContainer.viewContext
        //grab all bus service numbers
        //query each bus service
        //for each route
        //for each bus stop number in the service
        //query again for the bus stop object with said number
        //create a bus stop object if it does not exist, and then add the bus stop object to the bus service route's list
        //save into core data
        //using relationships, should be able to view the route of bus stops for a particular service
        //should be able to view the bus services of a particular bus stop
        
        
        
        //need to clear all data temporarily so no duplicates will be saved
        
    }
}

