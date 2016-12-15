//
//  AlertHandler.swift
//  GonnaMeetYouHalfway
//
//  Created by mdziubich on 14.12.2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import UIKit

protocol AlertHandler {
    func showLocationSettingsAlert()
    func showError()
}

extension AlertHandler where Self: UIViewController {

    func showError() {
        showAlert(title: "Error", message: "Sorry, an error occured. Please try again.")
    }
    
    func showLocationSettingsAlert() {
        let okAction = UIAlertAction(title: "Go to Settings", style: .default) {
            UIAlertAction in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        }
        
        showAlert(title: "Error",
                  message: "We need your location. Do you want to change your settings now?",
                  cancelButtonTitle: "Cancel",
                  action: okAction)
    }
}
