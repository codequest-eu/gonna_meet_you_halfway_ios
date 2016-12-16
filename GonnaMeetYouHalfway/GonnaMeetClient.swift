import UIKit
import Moya
import RxSwift
import RxOptional
import CoreLocation
import ObjectMapper
import Moya_ObjectMapper

class GonnaMeetClient {

    private static let shared = GonnaMeetClient()
    static var `default`: GonnaMeetClient { return shared }
    
    private let provider: RxMoyaProvider<GonnaMeetAPI>
    private let mqttClient: RxMqttClient
    
    init(provider: RxMoyaProvider<GonnaMeetAPI> = GonnaMeetClient.defaultProvider(),
         mqttClient: RxMqttClient = GonnaMeetClient.defaultMqttClient()) {
        self.provider = provider
        self.mqttClient = mqttClient
    }
    
    private static func defaultProvider() -> RxMoyaProvider<GonnaMeetAPI> {
        return RxMoyaProvider<GonnaMeetAPI>(endpointClosure: GonnaMeetClient.endpointClosure)
    }
    
    private static let endpointClosure = { (target: GonnaMeetAPI) -> Endpoint<GonnaMeetAPI> in
        let defaultEndpoint = MoyaProvider.defaultEndpointMapping(target)
        return defaultEndpoint.adding(parameterEncoding: JSONEncoding.default)
    }

    private static func defaultMqttClient() -> RxMqttClient {
        return RxMqttClient()
    }
    
    func requestMeeting(name: String, email: String, otherEmail: String, location: CLLocationCoordinate2D) -> Observable<MeetingResponse> {
        let request = MeetingRequest(name: name, email: email, otherEmail: otherEmail, position: location)
        return provider.request(.createMeeting(request: request))
            .mapObject(MeetingResponse.self)
    }

    func acceptMeeting(name: String, meetingIdentifier: String, location: CLLocationCoordinate2D) -> Observable<MeetingResponse> {
        let request = AcceptMeetingRequest(name: name, meetingIdentifier: meetingIdentifier, position: location)
        return provider.request(.acceptMeeting(request: request))
            .mapObject(MeetingResponse.self)
    }
    
    func suggest(meetingIdentifier: String, coordinate: CLLocationCoordinate2D,
                 name: String? = nil, description: String? = nil) -> Observable<Void> {
        let suggestion = SuggestionRequest(meetingIdentifier: meetingIdentifier,
                                           position: coordinate,
                                           name: name,
                                           description: description)
        return provider.request(.suggest(suggestion: suggestion)).map { _ in }
    }
    
    // accept friend place suggestion for meeting
    func accept(suggestionIdentifier: String) -> Observable<Void> {
        return provider.request(.accept(suggestionIdentifier: suggestionIdentifier)).map { _ in }
    }
    
    // get place suggestions from server
    func placeSuggestions(from topic: String) -> Observable<[PlaceSuggestion]> {
        return mqttClient.subscribe(to: topic)
            .map { (try? Mapper<PlaceSuggestion>().mapArray(JSONString: $0)) ?? [] }
    }

    //listen for meeting suggest from friend
    func meetingSuggestions(from topic: String) -> Observable<MeetingSuggestion> {
        return mqttClient.subscribe(to: topic)
            .map { try? MeetingSuggestion(JSONString: $0) }
            .filterNil()
    }
    
    // send user location constantly
    func send(location: CLLocationCoordinate2D, to topic: String) {
        let jsonLocation = location.toJSONString()!
        mqttClient.publish(to: topic, message: jsonLocation)
    }
    
    // fetch friend location constantly
    func otherLocations(from topic: String) -> Observable<CLLocationCoordinate2D> {
        return Observable<Int>.interval(5, scheduler: MainScheduler.asyncInstance).map({ index in
            CLLocationCoordinate2D(latitude: CLLocationDegrees(index), longitude: CLLocationDegrees(index+1))
        })
//        return mqttClient.subscribe(to: topic)
//            .map { try? CLLocationCoordinate2D(JSONString: $0) }
//            .filterNil()
    }
    
}
