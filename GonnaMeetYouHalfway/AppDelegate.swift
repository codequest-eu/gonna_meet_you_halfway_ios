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
	var navigationController: UINavigationController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        application.statusBarStyle = UIStatusBarStyle.lightContent
        UINavigationBar.appearance().tintColor = UIColor.white
		window = UIWindow.init(frame: UIScreen.main.bounds)
		navigationController = UINavigationController()
		showLocationView(in: navigationController, id: nil)
		window?.rootViewController = navigationController
		window?.makeKeyAndVisible()
        return true
    }
    
//    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
//        
//        // Handle universal links
//        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
//            let url = userActivity.webpageURL,
//            let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
//                return false
//        }
//        print(components)
//        // If universal link contains the proper path url for rebooking, trigger an action
////        if components.path.range(of: "/rebooking/appointment_request/") != nil {
////            showLocationView()
//            return true
////        }
////                return false
//    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if url.scheme == "halfway" {
            let meetingId = url.lastPathComponent
            showLocationView(in: navigationController, id: meetingId)
			return true
        }
        
        return false
    }
    
	private func showLocationView(in navController: UINavigationController, id: String?) {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		var mainController: UIViewController
		if let id = id {
			mainController = storyboard.instantiateViewController(withIdentifier: "LocationViewController")
				as! LocationViewController
			(mainController as! LocationViewController).meetingId = id
		} else {
			mainController = storyboard.instantiateViewController(withIdentifier: "ContactViewController")
				as! ContactViewController
		}
        navController.pushViewController(mainController, animated: true)
    }
}

