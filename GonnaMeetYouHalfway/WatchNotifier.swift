import UIKit
import WatchConnectivity
import RxSwift
import CoreLocation

class WatchNotifier: NSObject {
    
    var identifier: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    var started: Bool = false
    let client: GonnaMeetClient
    let locationsTopicName: String
    var disposeBag = DisposeBag()
    var session: WCSession? = nil
    
    init(client: GonnaMeetClient = GonnaMeetClient.default, locationsTopicName: String) {
        self.client = client
        self.locationsTopicName = locationsTopicName
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
            client.otherLocations(from: locationsTopicName).subscribe(onNext: { location in
                let meetingInfo = MeetingInfo(myTime: Int(location.latitude),
                                                otherTime: Int(location.longitude),
                                                myLocation: location,
                                                otherLocation: location)
                do {
                    try session.updateApplicationContext(["meetingInfo": meetingInfo.toDictionary()])
                } catch {
                    print(error)
                }
            }, onError: { error in
                print(error)
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
        identifier = UIApplication.shared.beginBackgroundTask(withName: "startWatchNotification") {
            self.started = false
            self.disposeBag = DisposeBag()
            UIApplication.shared.endBackgroundTask(self.identifier)
        }
        startNotification(with: session)
        DispatchQueue.main.async {
            replyHandler(["backgroundTimeRemaining": UIApplication.shared.backgroundTimeRemaining])
        }
    }
    
}
