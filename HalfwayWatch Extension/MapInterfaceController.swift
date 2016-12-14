//
//  MapInterfaceController.swift
//  GonnaMeetYouHalfway
//
//  Created by Michal Karwanski on 14/12/2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import WatchKit
import Foundation

class MapInterfaceController: WKInterfaceController {

    @IBOutlet var map: WKInterfaceMap!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let mapLocation = CLLocationCoordinate2D(latitude: 52.25, longitude: 21.16)
        let coordinateSpan = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        map.addAnnotation(mapLocation, with: WKInterfaceMapPinColor.purple)
        map.setRegion(MKCoordinateRegion(center: mapLocation, span: coordinateSpan))
    }
}
