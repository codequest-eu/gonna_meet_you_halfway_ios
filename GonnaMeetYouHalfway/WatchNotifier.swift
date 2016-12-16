import UIKit
import WatchConnectivity
import RxSwift
import CoreLocation

class WatchNotifier: NSObject {
    
    var identifier: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    let locationInfoService: LocationInfoService
    var started: Bool = false
    var disposeBag = DisposeBag()
    var session: WCSession? = nil
    
    init(locationInfoService: LocationInfoService = LocationInfoService.default) {
        self.locationInfoService = locationInfoService
    }

    func initialize() {        
        if WCSession.isSupported() {
            session = WCSession.default()
            session?.delegate = self
            session?.activate()
        }
    }
    
    func startNotification(with session: WCSession) {
        if !started {
            Observable.combineLatest(locationInfoService.myLocationInfos,
                                     locationInfoService.otherLocationInfos,
                                     locationInfoService.meetingLocation.asObservable().filterNil()) {
                MeetingInfo(mine: $0, other: $1, meetingLocation: $2)
            }.subscribe(onNext: {
                try? session.updateApplicationContext(["meetingInfo": $0.toDictionary()])
            }, onError: {
                print($0)
            }).addDisposableTo(disposeBag)
        }
    }
    
}

extension WatchNotifier: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState != .activated || error != nil {
            print(error ?? "Error on watch session activation \(activationState.rawValue)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Swift.Void) {
        if identifier == UIBackgroundTaskInvalid {
            identifier = UIApplication.shared.beginBackgroundTask(withName: "startWatchNotification") {
                self.started = false
                self.disposeBag = DisposeBag()
                UIApplication.shared.endBackgroundTask(self.identifier)
                self.identifier = UIBackgroundTaskInvalid
            }
        startNotification(with: session)
        }
        DispatchQueue.main.async {
            replyHandler(["backgroundTimeRemaining": UIApplication.shared.backgroundTimeRemaining])
        }
    }
    
}
