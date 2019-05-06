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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addContactAction(_ sender: Any) {
        showTextFieldAlert(message: AlertStrings.kAddNewContact, placeholder: AlertStrings.kAddContactPlaceHolder, constructiveButtonTitle: UIElementTitles.kAdd) { (emailId) in
            if let currentUserEmail = Auth.auth().currentUser?.email {
                if currentUserEmail == emailId {
                    self.showMessageOnlyAlert(message: AlertStrings.kAddSelfAsContactError, completion: nil)
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
                        
                    }else {
                        //invalid
                        self.showMessageOnlyAlert(message: AlertStrings.kNotRegisteredUser, completion: nil)
                    }
                }
            })
        }
    }
}
