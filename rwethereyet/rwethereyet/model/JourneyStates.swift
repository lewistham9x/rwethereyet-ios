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
    func changeStop(stop: BusStop)
    func notify()
    func updateView()
}

class SelectState: JourneyState{
    
    var myJourney : Journey

    required init(myJourney : Journey) {
        self.myJourney = myJourney
    }
    
    func changeStop(stop: BusStop) {
        //in other states, will change state, segue to new controller
        //gets all bus services based on prevStop
        
        
        
        //updates services available verytime prevStop updates during selection process to show bus destinations to choose from
        myJourney.setSvcRoutesForCurrentStop()

        
        
        //upon user selection will have to change bus service and rotue
        
        
        //update upper selection view
        

    }
    
    func notify() {
        
    }
    
    func updateView() {
        
    }
    
}
