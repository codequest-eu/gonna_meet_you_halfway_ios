//
//  AppDelegate.swift
//  GonnaMeetYouHalfway
//
//  Created by Michal Karwanski on 12/12/2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import UIKit
import Contacts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var contactStore = CNContactStore()
    
    let watchNotifier = WatchNotifier(locationsTopicName: "test/karwer/locations")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       
        watchNotifier.initialize()
        application.statusBarStyle = UIStatusBarStyle.lightContent
        UINavigationBar.appearance().tintColor = UIColor.white
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        // Handle universal links
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return false
        }
        print(components)
        // If universal link contains the proper path url for rebooking, trigger an action
//        if components.path.range(of: "/rebooking/appointment_request/") != nil {
            showLocationView()
            return true
//        }
//                return false
    }
    
    private func showLocationView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let detailVC = storyboard.instantiateViewController(withIdentifier: "NavigationController")
            as! LocationViewController
        
        let navigationVC = storyboard.instantiateViewController(withIdentifier: "LocationViewController")
            as! UINavigationController
        navigationVC.modalPresentationStyle = .formSheet
        
        navigationVC.pushViewController(detailVC, animated: true)
    }
}

