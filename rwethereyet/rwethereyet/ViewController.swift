//
//  ViewController.swift
//  rwethereyet
//
//  Created by Lewis Tham on 8/1/18.
//  Copyright © 2018 somethingwithc. All rights reserved.
//

import UIKit
import SwiftyGif
import SwiftLocation
import SwiftOverlays

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    //Control definition
    
    @IBOutlet weak var lblBusStopName: UILabel!
    @IBOutlet weak var lblInstruction: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!
    var previousIndex : Int = 0

    //setter for collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return svcList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectioncell", for: indexPath) as! BusServiceCollectionViewCell
        cell.lblCellBusServiceNumber.text = svcList[indexPath.row].svcNo
        return cell
    }
    
    //set title to amke sense
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        newJourney.selectSvc(svcInt: indexPath.row)
        let lastStopName = newJourney.routeDestinations![(newJourney.routeDestinations?.count)!-1].name!
        let svcNo = svcList[indexPath.row].svcNo!
        self.title = svcNo + " towards " + lastStopName
    }
    
    // change background color when user touches cell
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.blue
    }
    
    // change back
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.cyan
    }
    
    var svcList = [] as! [BusServiceRoute]
    var stopList = [] as! [BusStop]
    
    //setter for table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stopList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BusStopTableViewCell
        cell.lblCellBusStopName.text = stopList[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //calculate number of stops user is away
        let stopcount = indexPath.row+1
        
        if stopcount>1
        {
            lblInstruction.text = "You are "+String(stopcount)+" stops away"
        }
        else
        {
            lblInstruction.text = "You are "+String(stopcount)+" stop away"
        }
    }
    
    /* Feature to be implemented in the future
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //bring out main storyboard
        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        //initialise viewcontroller from main storyboard<<<<<<<<<<<<<<<<
        let jc = mainstoryboard.instantiateViewController(withIdentifier:"inJourney") as! InJourneyViewController
        
        //or within instnatiation:
        navigationController?.pushViewController(jc,animated: true)
        newJourney.selectBusRoute(end: Int16(indexPath.row))
        jc.journey = newJourney
    }
 */
    
    //functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // A UIImageView with async loading
        let gifmanager = SwiftyGifManager(memoryLimit:20)
        let gif = UIImage(gifName: "thinking3d.gif")
        self.imageView.setGifImage(gif, manager: gifmanager)
        
        //newJourney.getUpdatedPost()
        
        //observer to get initstop loading status
        NotificationCenter.default.addObserver(forName: Notification.Name("loading"), object: nil, queue: nil, using: checkLoading(notif: ))
        // Do any additional setup after loading the view, typically from a nib.
        initData()
        
        //observer to get selection possibilities based on current stop
        NotificationCenter.default.addObserver(forName: Notification.Name("postSelectionInfo"), object: nil, queue: nil, using: updateSelectionInfo(notif: ))
    }
    
    
    
    
    func updateSelectionInfo(notif: Notification) -> Void //what happens when u find a stop OR select a bus service
    {
        //set the datasource for both the table and collection
        
        //update tvc
        //guard helps deal with optionals
        guard let userInfo = notif.userInfo, //grab all passed values
            let lastStop = userInfo["reach"] as? BusStop,
            let destinations = userInfo["dest"] as? [BusStop]!
            else{
                return
        }
        svcList = availSvcs(stop: lastStop)
        //TO DO: populate collection view
        stopList = destinations
        lblBusStopName.text = lastStop.name
        
        tableView.reloadData()
        collectionView.reloadData()
        tableView.isHidden = false
        collectionView.isHidden = false
        imageView.isHidden = true
        lblInstruction.isHidden = false
    }
    
    let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
    
    var newJourney = Journey()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("Memory warning received")
    }
    
    func checkLoading(notif: Notification) -> Void{
        //guard helps deal with optionals
        guard let userInfo = notif.userInfo, //grab all passed values
            let loading = userInfo["loading"] as? Bool
            else{
                return
        }
        
        if (loading)
        {
            //show updating message overlay
            self.showWaitOverlayWithText("Performing First Time Setup\nPlease wait a minute.")
        }
        else
        {
            //remove overlays
            self.removeAllOverlays()
            
            //only update journey info if data is loaded
            
            //observer to get initstop loading status
            newJourney.startLoc()
        }
    }   
}

