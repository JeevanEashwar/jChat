//
//  ViewController.swift
//  jChat
//
//  Created by Jeevan on 04/05/19.
//  Copyright © 2019 Jeevan. All rights reserved.
//

import UIKit
import FirebaseAuth

enum PageFunction : String {
    case LOGIN
    case SIGNUP
}
class LoginAndSignUpViewController: BaseViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    
    var pageFunction : PageFunction = .LOGIN {
        didSet {
            updatePageElementsAccordingToPageFunction()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.emailField.text = "jeevan@gmail.com"
        self.passwordField.text = "password"
    }

    private func updatePageElementsAccordingToPageFunction() {
        self.passwordField.text = ""
        switch self.pageFunction {
        case .LOGIN:
            firstButton.setTitle(UIElementTitles.kLoginText, for: .normal)
            secondButton.setTitle(UIElementTitles.kSignUpText, for: .normal)
        case .SIGNUP:
            firstButton.setTitle(UIElementTitles.kSignUpText, for: .normal)
            secondButton.setTitle(UIElementTitles.kLoginText, for: .normal)
        }
    }
    @IBAction func firstButtonAction(_ sender: UIButton) {
        guard let email = emailField.text else {
            return
        }
        guard let password = passwordField.text else {
            return
        }
        switch self.pageFunction {
        case .LOGIN:
            login(email: email, password: password)
        case .SIGNUP:
            signUp(email: email, password: password)
        }
    }
    @IBAction func secondButtonAction(_ sender: UIButton) {
        switch self.pageFunction {
        case .LOGIN:
            self.pageFunction = .SIGNUP
        case .SIGNUP:
            self.pageFunction = .LOGIN
        }
    }
    private func signUp(email: String, password: String) {
        self.activityIndicator.startAnimating()
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            self.activityIndicator.stopAnimating()
            // ...
            if let errorObj = error {
                self.showMessageOnlyAlert(message: errorObj.localizedDescription, completion: nil)
            }else {
                if let user = authResult?.user {
                    let message = "\(user.email ?? "") user sign up successful. Please Login with your credentials"
                    //Add user to USERS collection
                    if let userEmail = user.email {
                        
                        let documentDataDictionary = [keyStrings.kEmail: userEmail,
                                                      keyStrings.kUid:user.uid,
                                                      keyStrings.kDisplayName: String(userEmail.split(separator: "@").first ?? ""),
                                                      keyStrings.kPhotoURL: user.photoURL,
                                                      keyStrings.kContacts:[]
                            ] as [String : Any]
                        AliasFor.kUserCollection.document(userEmail).setData(documentDataDictionary)
                    }
                    //Turn the page into login
                    self.showMessageOnlyAlert(message: message, completion: {
                        self.pageFunction = .LOGIN
                    })
                }
            }
        }
    }
    private func login(email: String, password: String) {
        guard let email = emailField.text else {
            return
        }
        guard let password = passwordField.text else {
            return
        }
        self.activityIndicator.startAnimating()
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            guard let strongSelf = self else { return }
            // ...
            strongSelf.activityIndicator.stopAnimating()
            if let errorObj = error {
                strongSelf.showMessageOnlyAlert(message: errorObj.localizedDescription, completion: nil)
            }else {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let tabbarVC = mainStoryboard.instantiateViewController(withIdentifier: "MainViewController") as! UITabBarController
                strongSelf.present(tabbarVC, animated: true, completion: nil)
            }
        }
    }
}

