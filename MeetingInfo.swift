import CoreLocation

struct MeetingInfo {
    
    let mine: LocationInfo
    let other: LocationInfo

    init(mine: LocationInfo, other: LocationInfo) {
        self.mine = mine
        self.other = other
    }
    
}

extension MeetingInfo {
    
    init(dictionary: [String: Any]) {
        let mine = LocationInfo(dictionary: dictionary["mine"] as! [String: Any])
        let other = LocationInfo(dictionary: dictionary["other"] as! [String: Any])
        self.init(mine: mine, other: other)
    }
    
    func toDictionary() -> [String: Any] {
        return ["mine": mine,
                "other": other]
    }
    
}
