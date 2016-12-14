import CoreLocation
import ObjectMapper

struct MeetingSuggestion {
    
    let suggestionIdentifier: String
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let name: String?
    let description: String?
    let accepted: Bool
    
}

extension MeetingSuggestion: ImmutableMappable {
    
    init(map: Map) throws {
        suggestionIdentifier = try map.value("identifier")
        latitude = try map.value("latitude")
        longitude = try map.value("longitude")
        name = try? map.value("name")
        description = try? map.value("description")
        accepted = try map.value("accepted")
    }
    
}
