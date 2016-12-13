import ObjectMapper

struct MeetingResponse {
    
    let meetingIdentifier: String
    let suggestionsTopicName: String
    let myLocationTopicName: String
    let otherLocationTopicName: String
    let meetingLocationTopicName: String
    
}

extension MeetingResponse: ImmutableMappable {
    
    init(map: Map) throws {
        meetingIdentifier = try map.value("meetingIdentifier")
        suggestionsTopicName = try map.value("topics.suggestionsTopicName")
        myLocationTopicName = try map.value("topics.myLocationTopicName")
        otherLocationTopicName = try map.value("topics.otherLocationTopicName")
        meetingLocationTopicName = try map.value("topics.meetingLocationTopicName")
    }
    
}
