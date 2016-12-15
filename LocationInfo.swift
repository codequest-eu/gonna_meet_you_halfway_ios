import UIKit
import CoreLocation

struct LocationInfo {

    let time: TimeInterval
    let location: CLLocationCoordinate2D
    let distance: CLLocationDistance
    
    init(time: TimeInterval, location: CLLocationCoordinate2D, distance: CLLocationDistance) {
        self.time = time
        self.location = location
        self.distance = distance
    }
    
}

extension LocationInfo {
    
    init(dictionary: [String: Any]) {
        let time = dictionary["time"] as! TimeInterval
        let location = dictionary["location"] as! CLLocationCoordinate2D
        let distance = dictionary["distance"] as! CLLocationDistance
        self.init(time: time, location: location, distance: distance)
    }
    
    func toDictionary() -> [String: Any] {
        return ["time": time,
                "location": location,
                "distance": distance]
    }
    
}
