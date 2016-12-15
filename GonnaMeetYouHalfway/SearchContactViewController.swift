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

class SearchContactViewController: UIViewController {

    var contacts = [CNContact]()
    var inviteContact = Variable(CNContact())
    var inviteEmailOutsideAddressbook = Variable("")
    fileprivate var filteredContacts = Variable([CNContact]())
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    private let disposeBag = DisposeBag()

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search email"
        searchController.searchBar.delegate = self
        searchController.searchBar.returnKeyType = .done
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        filteredContacts.value = contacts
        setupCellConfiguration()
        setupCellTapHandling()
        setupSearchFilter()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
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
    
    private func setupCellTapHandling() {
        tableView
            .rx
            .modelSelected(CNContact.self)
            .subscribe(onNext: {
                contact in
                self.view.endEditing(true)
                self.searchController.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: {
                    self.inviteContact.value = contact
                })
                
                if let selectedRowIndexPath = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    private func setupSearchFilter() {
        searchController.searchBar
            .rx
            .text
            .throttle(throttleInterval, scheduler: MainScheduler.instance)
            .map(toFilteredContacts)
            .bindTo(self.filteredContacts)
            .addDisposableTo(disposeBag)
    }
    
    private func toFilteredContacts(searchText: String?) -> [CNContact] {
        if searchText == "" {
            return self.contacts
        }
        return self.contacts.filter{ contact in
            let email = contact.emailAddresses.map{ "\($0.value)" }.joined(separator: ", ")
            return email.lowercased().contains(searchText!.lowercased())
        }
    }
}

extension SearchContactViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)  {
        if searchBar.text != "" {
            inviteEmailOutsideAddressbook.value = searchBar.text!.lowercased()
        }
        
        self.searchController.dismiss(animated: true, completion: nil)
        dismiss(animated: true, completion: nil)
    }
}
