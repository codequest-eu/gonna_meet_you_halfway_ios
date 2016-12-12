import ObjectMapper

struct MeetingResponse {

    var suggestionsTopicName: String
    var myLocationTopicName: String
    var otherLocationTopicName: String
    var meetingLocationTopicName: String
    
}

extension MeetingResponse: ImmutableMappable {
    
    init(map: Map) throws {
        suggestionsTopicName = try map.value("suggestionsTopicName")
        myLocationTopicName = try map.value("myLocationTopicName")
        otherLocationTopicName = try map.value("otherLocationTopicName")
        meetingLocationTopicName = try map.value("meetingLocationTopicName")
    }
    
}
