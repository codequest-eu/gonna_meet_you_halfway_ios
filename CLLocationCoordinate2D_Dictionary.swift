import UIKit
import CoreLocation

extension CLLocationCoordinate2D {

    public init(dictionary: [String: Any]) {
        let latitude = dictionary["latitude"] as! CLLocationDegrees
        let longitude = dictionary["longitude"] as! CLLocationDegrees
        self.init(latitude: latitude, longitude: longitude)
    }
    
    func toDictionary() -> [String: Any] {
        return ["latitude": latitude,
                "longitude": longitude]
    }
    
}
