//
//  UIViewControllerExtension.swift
//  GonnaMeetYouHalfway
//
//  Created by mdziubich on 12.12.2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func createGradient(view aView: UIView) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.colors = [Globals.basicBackgroundColor, Globals.basicDarkBackgroundColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        aView.layer.insertSublayer(gradient, at:0)
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
        }
        
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }

}
