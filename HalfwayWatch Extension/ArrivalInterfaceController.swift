//
//  ArrivalInterfaceController.swift
//  GonnaMeetYouHalfway
//
//  Created by Michal Karwanski on 14/12/2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import WatchKit
import Foundation


class ArrivalInterfaceController: LocationInfoInterfaceController {
    
    @IBOutlet var myTimeLabel: WKInterfaceLabel!
    @IBOutlet var otherTimeLabel: WKInterfaceLabel!
    
    override var locationInfo: LocationInfo? {
        didSet {
            guard let locationInfo = locationInfo else { return }
            myTimeLabel.setText("\(locationInfo.myTime) min")
            otherTimeLabel.setText("\(locationInfo.otherTime) min")
        }
    }
    
}
