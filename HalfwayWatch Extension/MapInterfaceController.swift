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
            map.addAnnotation(meetingInfo.mine.location, with: WKInterfaceMapPinColor.green)
            map.addAnnotation(meetingInfo.meetingLocation, with: WKInterfaceMapPinColor.purple)
            map.addAnnotation(meetingInfo.other.location, with: WKInterfaceMapPinColor.red)
            map.setRegion(region(of: meetingInfo))
        }
    }
    
    private func region(of meetingInfo: MeetingInfo) -> MKCoordinateRegion {
        let myLocation = meetingInfo.mine.location
        let otherLocation = meetingInfo.other.location
        let maxLatitude = max(myLocation.latitude, otherLocation.latitude, meetingInfo.meetingLocation.latitude)
        let minLatitude = min(myLocation.latitude, otherLocation.latitude, meetingInfo.meetingLocation.latitude)
        let maxLongitude = max(myLocation.longitude, otherLocation.longitude, meetingInfo.meetingLocation.longitude)
        let minLongitude = max(myLocation.longitude, otherLocation.longitude, meetingInfo.meetingLocation.longitude)
        let latitudeDelta = maxLatitude - minLatitude
        let longitudeDelta = maxLongitude - minLongitude
        let delta = max(latitudeDelta, longitudeDelta) + 0.04
        let center = CLLocationCoordinate2D(latitude: (minLatitude+maxLatitude) / 2, longitude: (minLongitude+maxLongitude) / 2)
        return MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))
    }
    
}
