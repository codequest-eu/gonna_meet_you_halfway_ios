import UIKit
import CoreLocation
import ObjectMapper

struct PlaceSuggestion {

    let name: String
    let description: String?
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    
}

extension PlaceSuggestion: ImmutableMappable {
    
    init(map: Map) throws {
        name = try map.value("name")
        description = try? map.value("description")
        latitude = try map.value("latitude")
        longitude = try map.value("longitude")
    }
    
}
