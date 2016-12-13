import CoreLocation
import ObjectMapper

struct Location {
    
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees

}

extension Location: ImmutableMappable {
    
    init(map: Map) throws {
        latitude = try map.value("latitude")
        longitude = try map.value("longitude")
    }
    
    mutating func mapping(map: Map) {
        latitude >>> map["latitude"]
        longitude >>> map["longitude"]
    }
    
}
