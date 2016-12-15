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
            let mapLocation = meetingInfo.meetingLocation
            let span = coordinateSpan(of: meetingInfo)
            map.addAnnotation(meetingInfo.mine.location, with: WKInterfaceMapPinColor.green)
            map.addAnnotation(meetingInfo.meetingLocation, with: WKInterfaceMapPinColor.purple)
            map.addAnnotation(meetingInfo.other.location, with: WKInterfaceMapPinColor.red)
            map.setRegion(MKCoordinateRegion(center: mapLocation, span: span))
        }
    }
    
    private func coordinateSpan(of meetingInfo: MeetingInfo) -> MKCoordinateSpan {
        let myLocation = meetingInfo.mine.location
        let otherLocation = meetingInfo.other.location
        let latitudeDelta = abs(myLocation.latitude - otherLocation.longitude)
        let longitudeDelta = abs(myLocation.latitude - otherLocation.longitude)
        let delta = max(latitudeDelta, longitudeDelta) + 0.02
        return MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
    }
    
}
