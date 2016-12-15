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
        gradient.colors = [Globals.darkGreen.cgColor, Globals.darkGreen1.cgColor]
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
    
    func showAlert(title: String, message: String, cancelButtonTitle: String, action: UIAlertAction) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: cancelButtonTitle, style: .default) { (action) -> Void in }
        
        alertController.addAction(dismissAction)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String, action: UIAlertAction) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    func displayActionSheet(_ buttonOneTitle: String?, buttonOneAction: ((UIAlertAction)->Void)?, buttonTwoTitle: String?, buttonTwoAction: ((UIAlertAction)->Void)?, cancelAction: ((UIAlertAction)->Void)?) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let buttonOneTitle = buttonOneTitle {
            let actionOne = UIAlertAction(title: buttonOneTitle, style: .default, handler: buttonOneAction)
            alertController.addAction(actionOne)
        }
        
        if let buttonTwoTitle = buttonTwoTitle {
            let actionTwo = UIAlertAction(title: buttonTwoTitle, style: .default, handler: buttonTwoAction)
            alertController.addAction(actionTwo)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
