//
//  MapInterfaceController.swift
//  GonnaMeetYouHalfway
//
//  Created by Michal Karwanski on 14/12/2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import WatchKit
import Foundation

class MapInterfaceController: MeetingInfoInterfaceController {

    @IBOutlet var map: WKInterfaceMap!
    
    override var meetingInfo: MeetingInfo? {
        didSet {
            guard let meetingInfo = meetingInfo else { return }
            map.removeAllAnnotations()
            let mapLocation = meetingInfo.myLocation
            let coordinateSpan = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
            map.addAnnotation(mapLocation, with: WKInterfaceMapPinColor.purple)
            map.setRegion(MKCoordinateRegion(center: mapLocation, span: coordinateSpan))
        }
    }
    
}
