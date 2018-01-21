//
//  JourneyStates.swift
//  rwethereyet
//
//  Created by Lewis Tham on 19/1/18.
//  Copyright © 2018 somethingwithc. All rights reserved.
//

import Foundation

protocol JourneyState{ //applying state pattern
    init(myJourney : Journey)
    func reachedGudStop() //checks if the stop the user is at is useful to the current state's progress
    func checkStopsLeft()
}

class SelectState: JourneyState
{
    var myJourney : Journey

    required init(myJourney : Journey) {
        self.myJourney = myJourney
    }
    
    func reachedGudStop()
    {
        let currStop = myJourney.getCurrStop()
        let reachedStop = myJourney.getReachedStop()
        
        //sends nil if not at a particular bus stop
        if (currStop != nil && currStop != reachedStop) //if stop is eligible  (is within the correct route or
        {
            print("Bus is at a new stop")
            myJourney.updateReachedStop(stop: currStop!)
            myJourney.selectSvc(svcInt: 0)
        }
        else
        {
            print("Bus is not at new stop")
        }
    }
    
    func checkStopsLeft() {
        //do nothing, not in journey yet
    }
}

class InJourneyState: JourneyState
{
    var myJourney : Journey
    
    required init(myJourney: Journey) {
        self.myJourney = myJourney
    }
    
    func reachedGudStop() {
        myJourney.reachStop()
    }
    
    func checkStopsLeft()
    {
        if myJourney.stopsLeft() == myJourney.stopsToAlert
        {
            myJourney.toAlertState()
        }
    }
}

class AlertState: JourneyState
{
    var myJourney : Journey
    
    required init(myJourney: Journey) {
        self.myJourney = myJourney
    }
    
    func reachedGudStop(){
        myJourney.reachStop()
    }
    
    func checkStopsLeft() {
        if myJourney.stopsLeft() > 0
        {
            //post notif to alert ––> VC should change image and pop notification, maybe alarm
            myJourney.postJourneyAlert()
        }
        else if myJourney.stopsLeft() == 0
        {
            //post notif to end ––> VC should segue to final screen, maybe alarm, maybe kill location service or journey object
            myJourney.postJourneyEnd()

            myJourney.toReachedState()
        }

    }
}

class ReachedState: JourneyState
{
    var myJourney : Journey
    
    required init(myJourney: Journey) {
        self.myJourney = myJourney
    }
    
    func reachedGudStop(){
        //do nothing
    }
    
    func checkStopsLeft() {
        //do nothing l0l0l0
    }
}

