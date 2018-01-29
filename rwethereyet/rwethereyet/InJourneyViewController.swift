//
//  InJourney.swift
//  rwethereyet
//
//  Created by Lewis Tham on 23/1/18.
//  Copyright © 2018 somethingwithc. All rights reserved.
//

import UIKit
class InJourneyViewController : UIViewController{
    var journey = Journey()
    
    @IBOutlet weak var lblReachedStop: UILabel!
    @IBOutlet weak var lblStopsLeft: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        journey.getUpdatedPost()
        
        //observer to update stop when reached
        NotificationCenter.default.addObserver(forName: Notification.Name("postJourneyReach"), object: nil, queue: nil, using: reachStop(notif: ))
        
        //observer to alert if needed
        NotificationCenter.default.addObserver(forName: Notification.Name("postJourneyAlert"), object: nil, queue: nil, using: alert(notif: ))
        
        //observer to check if journey ended
        NotificationCenter.default.addObserver(forName: Notification.Name("postJourneyEnd"), object: nil, queue: nil, using: finish(notif: ))
    }
    
    private func reachStop(notif: Notification) -> Void //what happens when u find a stop OR select a bus service
    {
        
        //get journey info
        guard let userInfo = notif.userInfo, //grab all passed values
            let reachedStop = userInfo["reach"] as? BusStop,
            let stopsLeft = userInfo["left"] as? Int
            else{
                return
        }
        
        lblReachedStop.text = reachedStop.name! + " (" + reachedStop.stopNo! + ")"
        
        lblStopsLeft.text = String(stopsLeft) + "Stops Left"
        
        if (stopsLeft > 1) //to improve using state pattern, if more than one stop
        {
            lblStatus.text = "No"
        }
        else if (stopsLeft == 0)
        {
            lblStatus.text = "Reaching..."
        }
        else
        {
            lblStatus.text = "Yes"
        }
        
    }
    
    private func alert(notif: Notification) -> Void
    {
        //placeholder to for alert actions
    }
    
    private func finish(notif: Notification) -> Void
    {
        //placeholder for finish actions
    }
}
