//
//  LocationInfoInterfaceController.swift
//  GonnaMeetYouHalfway
//
//  Created by Michal Karwanski on 15/12/2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import WatchKit
import Foundation

class LocationInfoInterfaceController: WKInterfaceController {

    var locationInfo: LocationInfo?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        guard let delegate = context as? LocationInfoInterfaceControllerDelegate else { return }
        delegate.locationInfoInterfaceControllerDidWakeUp(self)
    }
    
}

protocol LocationInfoInterfaceControllerDelegate {
    
    func locationInfoInterfaceControllerDidWakeUp(_ controller: LocationInfoInterfaceController)
    
}
