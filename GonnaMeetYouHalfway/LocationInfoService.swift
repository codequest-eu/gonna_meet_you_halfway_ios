import UIKit
import RxSwift
import CoreLocation
import MapKit

class LocationInfoService {
    
    private static let shared = LocationInfoService()
    
    static var `default`: LocationInfoService { return shared }
    
    private let locationManager: LocationManager
    private let client: GonnaMeetClient
    
    let meetingLocation: Variable<CLLocationCoordinate2D?> = Variable(nil)
    let meetingResponse: Variable<MeetingResponse?> = Variable(nil)
    
    var myLocationInfos: Observable<LocationInfo>!
    var otherLocationInfos: Observable<LocationInfo>!
    
    init(locationManager: LocationManager = LocationManager.sharedInstance, client: GonnaMeetClient = GonnaMeetClient.default) {
        self.locationManager = locationManager
        self.client = client
        setUpObservables()
    }
    
    private func setUpObservables() {
        print("LocationInfoService \(self)")
        let meetingLocations = meetingLocation.asObservable()
            .do(onNext: { print("Meeting location before filter \($0)") })
            .filterNil()
            .do(onNext: { print("Meeting location after filter \($0)") })
        let myLocations = locationManager.userLocation.asObservable()
            .do(onNext: { print("My location before filter \($0)") })
            .filterNil()
            .do(onNext: { print("My location after filter \($0)") })
        let otherLocations = meetingResponse.asObservable()
            .do(onNext: { print("Meeting response before filter \($0)") })
            .filterNil()
            .do(onNext: { print("Meeting response after filter \($0)") })
            .map { $0.otherLocationTopicName }
            .do(onNext: { print("Topic for getting locations \($0)") })
            .flatMap { self.client.otherLocations(from: $0) }
            .do(onNext: { print("Other location \($0)") })
        myLocationInfos = combine(userLocation: myLocations, meetingLocation: meetingLocations)
        otherLocationInfos = combine(userLocation: otherLocations, meetingLocation: meetingLocations)
    }
    
    private func locationInfo(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) -> Observable<LocationInfo?> {
        return Observable.create { observer in
            print("Computing directions")
            let request = self.directionsRequest(with: start, end)
            let directions = MKDirections(request: request)
            directions.calculate { (response, error) in
                defer {
                    observer.onCompleted()
                }
                guard error == nil else {
                    print(error!)
                    observer.onNext(nil)
                    return
                }
                guard let route = response?.routes.first else {
                    observer.onNext(nil)
                    return
                }
                let info = LocationInfo(time: route.expectedTravelTime, location: start, distance: route.distance)
                observer.onNext(info)
            }
            return Disposables.create()
        }
    }
    
    private func directionsRequest(with start: CLLocationCoordinate2D, _ end: CLLocationCoordinate2D) -> MKDirectionsRequest {
        let start = MKPlacemark(coordinate: start)
        let destination = MKPlacemark(coordinate: end)
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: start)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = MKDirectionsTransportType.automobile
        return request
    }
    
    private func combine(userLocation: Observable<CLLocationCoordinate2D>, meetingLocation: Observable<CLLocationCoordinate2D>) -> Observable<LocationInfo> {
        return Observable.combineLatest(userLocation, meetingLocation) { ($0, $1) }
            .flatMap { [weak self] (start, end) in
                self?.locationInfo(start: start, end: end) ?? Observable.just(nil)
            }.filterNil().shareReplay(1)
    }
    
}
