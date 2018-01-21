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
    func stopIsGud() -> Bool //checks if the stop the user is at is useful to the current state's progress
    func checkStopsLeft()
}

class SelectState: JourneyState
{
    var myJourney : Journey

    required init(myJourney : Journey) {
        self.myJourney = myJourney
    }
    
    func stopIsGud() -> Bool
    {
        let currStop = myJourney.getCurrStop()
        let reachedStop = myJourney.getReachedStop()
        
        //sends nil if not at a particular bus stop
        if (currStop != nil && currStop != reachedStop) //if stop is eligible  (is within the correct route or
        {
            print("Bus is at a new stop")
            return true
        }
        else
        {
            print("Bus is not at new stop")
            return false
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
    
    func stopIsGud() -> Bool {
        <#code#>
    }
    
    func checkStopsLeft() {
        <#code#>
    }
}

class AlertState: JourneyState
{
    var myJourney : Journey
    
    required init(myJourney: Journey) {
        self.myJourney = myJourney
    }
    
    func stopIsGud() -> Bool {
        <#code#>
    }
    
    func checkStopsLeft() {
        <#code#>
    }
}

class ReachedState: JourneyState
{
    var myJourney : Journey
    
    required init(myJourney: Journey) {
        self.myJourney = myJourney
    }
    
    func stopIsGud() -> Bool {
        <#code#>
    }
    
    func checkStopsLeft() {
        <#code#>
    }
}

