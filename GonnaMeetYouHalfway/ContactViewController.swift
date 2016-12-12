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
//        setupTextChangeHandling()
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
        searchContact()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func searchContact() {
        requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                let store = CNContactStore()
                store.requestAccess(for: .contacts) { granted, error in
                    guard granted else {
                        return
                    }
                    
                    // get the contacts
                    var filterContacts = [CNContact]()
                    var contacts = [CNContact]()
                    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey]
                    var message: String!

                    let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                    do {
                        try store.enumerateContacts(with: request) { contact, stop in
                            contacts.append(contact)
                        }
                        filterContacts = contacts.filter { $0.emailAddresses.count > 0 }
                        if filterContacts.count == 0 {
                            message = "No contacts were found."
                        }
                    } catch {
                        print(error)
                    }
                    
                    if message != nil {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Warning", message: message)
                        }
                    } else {
                        OperationQueue.main.addOperation {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchControllerIdentifier") as! SearchContactViewController
                            vc.contacts = filterContacts
                            vc.delegate = self
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
}

extension ContactViewController: AddContactViewControllerDelegate {
    
    func didChooseContact(contact: CNContact) {
        //if chosen user has more that one email display alert 
        
        guard contact.emailAddresses.count == 1 else {
            DispatchQueue.main.async {
                self.displayAlertForMoreThanOneEmail(with: contact)
            }
            return
        }
        inviteEmailTextField.text = contact.emailAddresses[0].value as String
    }
    
    private func displayAlertForMoreThanOneEmail(with contact: CNContact) {
        let email1 = contact.emailAddresses[0].value as String
        let email2 = contact.emailAddresses[1].value as String
        displayActionSheet(email1, buttonOneAction: { _ in
            self.inviteEmailTextField.text = contact.emailAddresses[0].value as String
        }, buttonTwoTitle: email2, buttonTwoAction: { _ in
            self.inviteEmailTextField.text = contact.emailAddresses[1].value as String
        }, cancelAction: nil)
    }
}
