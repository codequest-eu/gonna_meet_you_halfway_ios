//
//  ExtensionDelegate.swift
//  HalfwayWatch Extension
//
//  Created by Michal Karwanski on 14/12/2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, LocationInfoInterfaceControllerDelegate {

    private var session: WCSession?
    fileprivate var controllers: [LocationInfoInterfaceController] = []
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
    
        if WCSession.isSupported() {
            session = WCSession.default()
            session?.delegate = self
            session?.activate()
        }
        
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        WKInterfaceController.reloadRootControllers(withNames: ["Arrival", "Map"], contexts: [self, self])
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompleted()
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompleted()
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompleted()
            default:
                // make sure to complete unhandled task types
                task.setTaskCompleted()
            }
        }
    }

    func locationInfoInterfaceControllerDidWakeUp(_ controller: LocationInfoInterfaceController) {
        if !controllers.contains(controller) {
            controllers.append(controller)
        }
    }
    
    func startNotification(with session: WCSession) {
        session.sendMessage(["startWatchNotification": true],
                            replyHandler: { [weak self] map in
                                let backgroundTimeRemaining = map["backgroundTimeRemaining"] as! TimeInterval
                                let seconds = Int(backgroundTimeRemaining) + 5
                                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds)) {
                                    self?.startNotification(with: session)
                                }
        },
                            errorHandler: { error in
                                print(error)
        })
    }
    
}

extension ExtensionDelegate: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if error == nil && activationState == .activated {
            startNotification(with: session)
        } else {
            print(error ?? "Unknown error occured on watch session activation \(activationState.rawValue)")
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        guard let locationInfoDictionary = applicationContext["locationInfo"] as? [String: Any] else { return }
        let locationInfo = LocationInfo(dictionary: locationInfoDictionary)
        controllers.forEach { controller in
            controller.locationInfo = locationInfo
        }
    }
        
}
