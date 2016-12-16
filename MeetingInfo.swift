import CoreLocation

struct MeetingInfo {
    
    let mine: LocationInfo
    let other: LocationInfo
    let meetingLocation: CLLocationCoordinate2D

    init(mine: LocationInfo, other: LocationInfo, meetingLocation: CLLocationCoordinate2D) {
        self.mine = mine
        self.other = other
        self.meetingLocation = meetingLocation
    }
    
}

extension MeetingInfo {
    
    init(dictionary: [String: Any]) {
        let mine = LocationInfo(dictionary: dictionary["mine"] as! [String: Any])
        let other = LocationInfo(dictionary: dictionary["other"] as! [String: Any])
        let meetingLocation = CLLocationCoordinate2D(dictionary: dictionary["meetingLocation"] as! [String: Any])
        self.init(mine: mine, other: other, meetingLocation: meetingLocation)
    }
    
    func toDictionary() -> [String: Any] {
        return ["mine": mine.toDictionary(),
                "other": other.toDictionary(),
                "meetingLocation": meetingLocation.toDictionary()]
    }
    
}
