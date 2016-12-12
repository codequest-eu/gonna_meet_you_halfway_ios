import UIKit
import Moya
import RxSwift
import CoreLocation

class GonnaMeetProvider {

    private static let shared = GonnaMeetProvider()
    static var `default`: GonnaMeetProvider { return shared }
    
    private let provider: RxMoyaProvider<GonnaMeetAPI>
    
    init(provider: RxMoyaProvider<GonnaMeetAPI> = GonnaMeetProvider.defaultProvider()) {
        self.provider = provider
    }
    
    private class func defaultProvider() -> RxMoyaProvider<GonnaMeetAPI> {
        return RxMoyaProvider<GonnaMeetAPI>(endpointClosure: GonnaMeetProvider.endpointClosure)
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
