//
//  ViewController.swift
//  GonnaMeetYouHalfway
//
//  Created by Michal Karwanski on 12/12/2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import UIKit
import Contacts
import RxSwift
import RxCocoa

class ContactViewController: UIViewController {

    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var inviteEmailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var inviteButton: UIButton!

    var contactStore = CNContactStore()
    private let disposeBag = DisposeBag()
    private let throttleInterval = 0.1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inviteEmailTextField.delegate = self
        createGradient(view: self.view)
        setupTextChangeHandling()
    }
    
    func setupRxObservable() {
        let textField1Text = inviteEmailTextField
            .rx
            .text
            .throttle(throttleInterval, scheduler: MainScheduler.instance)
        
        textField1Text
            .subscribe()
            .addDisposableTo(disposeBag)
    }

    // Validate email format
    fileprivate func isValidEmail(mail: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: mail)
    }
    
    fileprivate func updateButtonState(active: Bool) {
        inviteButton.backgroundColor = active ? Globals.activeButtonColor : Globals.inactiveButtonColor
    }
    
    fileprivate func requestForAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        switch authorizationStatus {
        case .denied, .restricted, .notDetermined:
            self.contactStore.requestAccess(for: .contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(access)
                }
                else {
                    if authorizationStatus == .denied {
                        let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                        self.showAlert(title: "Warning!", message: message)
                        //TODO : Make user available option to go straight to settings
                    }
                }
            })
        case .authorized:
            completionHandler(true)
        }
    }
    
    //MARK: - Rx Setup
    
    func setupTextChangeHandling() {
        
        let userMailValid = userEmailTextField
            .rx
            .text
            .throttle(throttleInterval, scheduler: MainScheduler.instance)
            .map { self.isValidEmail(mail: $0!) }
        userMailValid
            .subscribe()
//            .subscribe(onNext: { self.userEmailTextField.isValidEmail = $0 })
            .addDisposableTo(disposeBag)
        
        let inviteMailValid = inviteEmailTextField
            .rx
            .text
            .throttle(throttleInterval, scheduler: MainScheduler.instance)
            .map { self.isValidEmail(mail: $0!) }
        
        inviteMailValid
            .subscribe()
//            .subscribe(onNext: { self.expirationDateTextField.valid = $0 })
            .addDisposableTo(disposeBag)
        
        let nameValid = nameTextField
            .rx
            .text
            .map { $0 != nil }
        
        nameValid
            .subscribe()
//            .subscribe(onNext: { self.cvvTextField.valid = $0 })
            .addDisposableTo(disposeBag)
        
        
        let everythingValid = Observable
            .combineLatest(userMailValid, inviteMailValid, nameValid) {
                $0 && $1 && $2 //All must be true
        }
        
//        everythingValid
//            .bindTo(inviteButton.rx.enabled)
//            .addDisposableTo(disposeBag)

    }
}

extension ContactViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField)  {
        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                let predicate = CNContact.predicateForContacts(matchingName: self.inviteEmailTextField.text!)
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactBirthdayKey]
                var filterContacts = [CNContact]()
                var message: String!
                
                let contactsStore = AppDelegate.getAppDelegate().contactStore
                do {
                    let contacts = try contactsStore.unifiedContacts(matching: predicate, keysToFetch: keys as [CNKeyDescriptor])
                    
                    if contacts.count == 0 {
                        message = "No contacts were found matching the given name."
                    }
                    filterContacts = contacts.filter { $0.emailAddresses.count > 0 }
                }
                catch {
                    message = "Unable to fetch contacts."
                }
                
                if message != nil {
                    self.showAlert(title: "Warning", message: message)
                } else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchControllerIdentifier") as! SearchContactViewController
                    vc.contacts = filterContacts
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
        return true
    }
}

extension ContactViewController: AddContactViewControllerDelegate {
    
    func didChooseContact(contact: CNContact) {
        //to do: Handle when contact has more than one available mail and send invite
    }
}


