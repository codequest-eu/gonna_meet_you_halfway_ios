//
//  SearchContactViewController.swift
//  GonnaMeetYouHalfway
//
//  Created by mdziubich on 12.12.2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import UIKit
import Contacts
import RxSwift
import RxCocoa

protocol AddContactViewControllerDelegate: class {
    func didChooseContact(contact: CNContact)
}

class SearchContactViewController: UIViewController {

    weak var delegate: AddContactViewControllerDelegate!
    var contacts = [CNContact]()
    fileprivate var filteredContacts = Variable([CNContact]()) //[CNContact]()
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    private let disposeBag = DisposeBag()

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addEmailButton: UIButton!
    @IBOutlet weak var bottomButtonConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.delegate = self
//        tableView.dataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search email"
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        filteredContacts.value = contacts //= Variable(contacts)
        setKeyboardObservers()
        setupCellConfiguration()
        setupCellTapHandling()
        setupSearchChanges()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    fileprivate func currentContacts() -> [CNContact] {
//        if searchController.isActive && searchController.searchBar.text != "" {
//            return filteredContacts
//        }
        return contacts
    }
    
    func setKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(SearchContactViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchContactViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if let bottomButtonBottomConstraint = bottomButtonConstraint,
            let bottomButton = addEmailButton {
            bottomButtonBottomConstraint.constant = 0.0
            bottomButton.layoutIfNeeded()
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let bottomButtonBottomConstraint = bottomButtonConstraint,
            let bottomButton = addEmailButton {
            bottomButtonBottomConstraint.constant = keyboardSize.height
            bottomButton.layoutIfNeeded()
        }
    }
    
    //MARK: RxSetup
    
    private func setupCellConfiguration() {
        filteredContacts
            .asObservable()
            .bindTo(tableView
                .rx
                .items(cellIdentifier: "ContactCell", cellType: ContactCell.self)) {
                    row, contact, cell in
                    cell.setupLabels(contact: contact)
            }
            .addDisposableTo(disposeBag)
    }
    
    private func setupSearchChanges() {
        filteredContacts.asObservable()
            .subscribe { (contacts) in
                self.tableView.reloadData()
        }
        .addDisposableTo(disposeBag)
    }
    
    private func setupCellTapHandling() {
        tableView
            .rx
            .modelSelected(CNContact.self)
            .subscribe(onNext: {
                contact in
                self.view.endEditing(true)
                self.searchController.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: {
                    self.delegate?.didChooseContact(contact: contact)
                })
                
                if let selectedRowIndexPath = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
                }
            })
            .addDisposableTo(disposeBag)
    }
}

extension SearchContactViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(searchText: String, scope: String = "All") {
//        filteredContacts.removeAll()
        let filteredContacts = contacts.filter{ contact in
            let email = contact.emailAddresses.map{ "\($0.value)" }.joined(separator: ", ")
            return email.lowercased().contains(searchText.lowercased())
        }
        self.filteredContacts.value = filteredContacts //= Variable(filteredContacts)
        
//        tableView.reloadData()
    }
}

//extension SearchContactViewController: UITableViewDataSource {
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return currentContacts().count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
//        let contact = currentContacts()[indexPath.row]
//        cell.setupLabels(contact: contact)
//        
//        return cell
//    }
//}
//
//extension SearchContactViewController: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.view.endEditing(true)
//        searchController.dismiss(animated: true, completion: nil)
//        dismiss(animated: true, completion: {
//            self.delegate?.didChooseContact(contact: self.currentContacts()[indexPath.row])  
//        })
//    }
//}

extension SearchContactViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: nil)
    }
}
