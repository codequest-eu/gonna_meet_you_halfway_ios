import UIKit
import Moya
import RxSwift
import CoreLocation
import Moya_ObjectMapper

class GonnaMeetClient {

    private static let shared = GonnaMeetClient()
    static var `default`: GonnaMeetClient { return shared }
    
    private let provider: RxMoyaProvider<GonnaMeetAPI>
    
    init(provider: RxMoyaProvider<GonnaMeetAPI> = GonnaMeetClient.defaultProvider()) {
        self.provider = provider
    }
    
    private static func defaultProvider() -> RxMoyaProvider<GonnaMeetAPI> {
        return RxMoyaProvider<GonnaMeetAPI>(endpointClosure: GonnaMeetClient.endpointClosure)
    }
    
    private static let endpointClosure = { (target: GonnaMeetAPI) -> Endpoint<GonnaMeetAPI> in
        let defaultEndpoint = MoyaProvider.defaultEndpointMapping(target)
        return defaultEndpoint.adding(parameterEncoding: JSONEncoding.default)
    }
    
    func requestMeeting(name: String, email: String, otherEmail: String) -> Observable<MeetingResponse> {
        let request = MeetingRequest(name: name, email: email, otherEmail: otherEmail)
        return provider.request(.createMeeting(request: request))
            .mapObject(MeetingResponse.self)
    }

    func suggest(meetingIdentifier: String, coordinate: CLLocationCoordinate2D) -> Observable<Void> {
        let suggestion = SuggestionRequest(meetingIdentifier: meetingIdentifier,
                                           latitude: coordinate.latitude,
                                           longitude: coordinate.longitude)
        return provider.request(.suggest(suggestion: suggestion)).map { _ in }
    }
    
    func accept(suggestionIdentifier: String) -> Observable<Void> {
        return provider.request(.accept(suggestionIdentifier: suggestionIdentifier)).map { _ in }
    }
    
}
