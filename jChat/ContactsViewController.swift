//
//  ContactsViewController.swift
//  jChat
//
//  Created by Jeevan on 04/05/19.
//  Copyright © 2019 Jeevan. All rights reserved.
//

import UIKit
import FirebaseAuth
class ContactsViewController: BaseViewController {

    @IBOutlet weak var contactsTableView: UITableView!
    var currentUserDocumentData : [String:Any] = [:] {
        didSet {
            if let currentContacts = currentUserDocumentData[keyStrings.kContacts] as? [String] {
                self.userContacts = currentContacts
            }
        }
    }
    var userContacts : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchAllUsersDocuments()
    }
    
    fileprivate func updateCurrentUserDocument(field: String, value : Any, completion : (()->())?) {
        self.activityIndicator.startAnimating()
        if let currentUser = AliasFor.kCurrentUser?.email {
            AliasFor.kUserCollection.document(currentUser).updateData([
                field : value
            ]) { (error) in
                self.activityIndicator.stopAnimating()
                if let error = error {
                    print(error.localizedDescription)
                }
                if let completion = completion {
                    completion()
                }
            }
        }
    }
    
    fileprivate func fetchAllUsersDocuments() {
        // Do any additional setup after loading the view.
        activityIndicator.startAnimating()
        if let currentUser = AliasFor.kCurrentUser?.email {
            AliasFor.kUserCollection.document(currentUser).getDocument { (documentSnapshot, error) in
                self.activityIndicator.stopAnimating()
                if let error = error {
                    print(error.localizedDescription)
                }else if let documentSnapshot = documentSnapshot {
                    if let documentData = documentSnapshot.data() {
                        self.currentUserDocumentData = documentData
                        self.contactsTableView.reloadData()
                    }
                }
            }
        }
    }
    @IBAction func addContactAction(_ sender: Any) {
        showTextFieldAlert(message: AlertStrings.kAddNewContact, placeholder: AlertStrings.kAddContactPlaceHolder, constructiveButtonTitle: UIElementTitles.kAdd) { (emailId) in
            if let currentUserEmail = Auth.auth().currentUser?.email {
                if currentUserEmail == emailId {
                    self.showMessageOnlyAlert(message: AlertStrings.kAddSelfAsContactError, completion: nil)
                    return
                }else if self.userContacts.contains(emailId) {
                    self.showMessageOnlyAlert(message: AlertStrings.kAddExistingAsContactError, completion: nil)
                    return
                }
            }
            self.activityIndicator.startAnimating()
            Auth.auth().fetchSignInMethods(forEmail: emailId, completion: { (arrayOfMethods, error) in
                self.activityIndicator.stopAnimating()
                if let error = error {
                    self.showMessageOnlyAlert(message: error.localizedDescription, completion: nil)
                }else {
                    if let arrayOfLoginMethods = arrayOfMethods {
                        //valid user
                        guard let currentContacts = self.currentUserDocumentData[keyStrings.kContacts] as? [String] else {
                            self.updateCurrentUserDocument(field: keyStrings.kContacts, value:
                                [emailId], completion: {
                                    self.fetchAllUsersDocuments()
                            })
                            return
                        }
                        let updatedContacts = currentContacts + [emailId]
                        self.updateCurrentUserDocument(field: keyStrings.kContacts, value:
                            updatedContacts, completion: {
                                self.fetchAllUsersDocuments()
                        })
                        
                    }else {
                        //invalid
                        self.showMessageOnlyAlert(message: AlertStrings.kNotRegisteredUser, completion: nil)
                    }
                }
            })
        }
    }
}
extension ContactsViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userContacts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath) as! ContactTableViewCell
        cell.contactNameLabel.text = userContacts[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chatVC = ChatViewController()
        chatVC.contactId = userContacts[indexPath.row]
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
}
