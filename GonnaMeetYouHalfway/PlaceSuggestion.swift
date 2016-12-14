import UIKit
import CoreLocation
import ObjectMapper

struct PlaceSuggestion {

    let name: String
    let description: String?
    let position: CLLocationCoordinate2D
    
}

extension PlaceSuggestion: ImmutableMappable {
    
    init(map: Map) throws {
        name = try map.value("name")
        description = try? map.value("description")
        position = try map.value("position")
    }
    
}
