import CoreLocation

struct LocationInfo {
    
    let myTime: Int
    let otherTime: Int
    let myLocation: CLLocationCoordinate2D
    let otherLocation: CLLocationCoordinate2D

    init(myTime: Int, otherTime: Int, myLocation: CLLocationCoordinate2D, otherLocation: CLLocationCoordinate2D) {
        self.myTime = myTime
        self.otherTime = otherTime
        self.myLocation = myLocation
        self.otherLocation = otherLocation
    }
    
}

extension LocationInfo {
    
    init(dictionary: [String: Any]) {
        let myTime = dictionary["myTime"] as! Int
        let otherTime = dictionary["otherTime"] as! Int
        let myLatitude = dictionary["myLatitude"] as! CLLocationDegrees
        let myLongitude = dictionary["myLongitude"] as! CLLocationDegrees
        let myLocation = CLLocationCoordinate2D(latitude: myLatitude, longitude: myLongitude)
        let otherLatitude = dictionary["otherLatitude"] as! CLLocationDegrees
        let otherLongitude = dictionary["otherLongitude"] as! CLLocationDegrees
        let otherLocation = CLLocationCoordinate2D(latitude: otherLatitude, longitude: otherLongitude)
        self.init(myTime: myTime, otherTime: otherTime, myLocation: myLocation, otherLocation: otherLocation)
    }
    
    func toDictionary() -> [String: Any] {
        return ["myTime": myTime,
                "otherTime": otherTime,
                "myLatitude": myLocation.latitude,
                "myLongitude": myLocation.longitude,
                "otherLatitude": otherLocation.latitude,
                "otherLongitude": otherLocation.longitude]
    }
    
}
