//
//  CLLocationCoordinate2D_Mappable.swift
//  GonnaMeetYouHalfway
//
//  Created by Michal Karwanski on 14/12/2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import UIKit
import CoreLocation
import ObjectMapper

extension CLLocationCoordinate2D: ImmutableMappable {
    
    public init(map: Map) throws {
        latitude = try map.value("latitude")
        longitude = try map.value("longitude")
    }
    
    public mutating func mapping(map: Map) {
        latitude >>> map["latitude"]
        longitude >>> map["longitude"]
    }
    
}
