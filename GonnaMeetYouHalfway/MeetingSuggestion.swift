import CoreLocation
import ObjectMapper

struct MeetingSuggestion {
    
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let accepted: Bool
    
}

extension MeetingSuggestion: ImmutableMappable {
    
    init(map: Map) throws {
        latitude = try map.value("latitude")
        longitude = try map.value("longitude")
        accepted = try map.value("accepted")
    }
    
}
