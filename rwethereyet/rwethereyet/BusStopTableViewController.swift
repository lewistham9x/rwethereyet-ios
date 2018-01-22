//
//  BusServiceTableViewController.swift
//  rwethereyet
//
//  Created by Lewis Tham on 22/1/18.
//  Copyright © 2018 somethingwithc. All rights reserved.
//

import UIKit

class BusStopTableViewCell: UITableViewCell{
    
    @IBOutlet weak var lblCellBusStopName: UILabel!
}

class BusStopTableViewController : UITableViewController{
    var svcList = [] as! [BusServiceRoute]
    var stopList = [] as! [BusStop]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //observer to get selection possibilities based on current stop
        NotificationCenter.default.addObserver(forName: Notification.Name("postSelectionInfo"), object: nil, queue: nil, using: updateSelectionInfo(notif: ))

    }
    
    func updateSelectionInfo(notif: Notification) -> Void
    {
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
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stopList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BusStopTableViewCell
        cell.lblCellBusStopName.text = stopList[indexPath.row].name
        return cell
    }
}
