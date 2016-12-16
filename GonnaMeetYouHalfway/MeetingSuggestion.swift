import CoreLocation
import ObjectMapper

struct MeetingSuggestion {
    
    let suggestionIdentifier: String
    let position: CLLocationCoordinate2D
    let name: String?
    let description: String?
    let accepted: Bool
    let senderLocationTopicName: String
    
}

extension MeetingSuggestion: ImmutableMappable {
    
    init(map: Map) throws {
        suggestionIdentifier = try map.value("placeIdentifier")
        position = try map.value("position")
        name = try? map.value("name")
        description = try? map.value("description")
        accepted = try map.value("accepted")
        senderLocationTopicName = try map.value("senderLocationTopicName")
    }
    
}
