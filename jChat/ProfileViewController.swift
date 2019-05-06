//
//  ProfileViewController.swift
//  jChat
//
//  Created by Jeevan on 06/05/19.
//  Copyright © 2019 Jeevan. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: BaseViewController {
    
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let currentUser = Auth.auth().currentUser {
            displayName.text = currentUser.displayName ?? ""
            if let photoUrl = currentUser.photoURL {
                do {
                    let imageData = try Data(contentsOf: photoUrl)
                    self.contactImage.image = UIImage(data:imageData)
                }
                catch let error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func update(_ sender: Any) {
        if let newDisplayName = self.displayName.text {
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = newDisplayName
            self.activityIndicator.startAnimating()
            changeRequest?.commitChanges { (error) in
                // ...
                self.activityIndicator.stopAnimating()
                self.showMessageOnlyAlert(message: AlertStrings.kUserProfileUpdateSuccess, completion: nil)
            }
            self.updateCurrentUserDocument(field: keyStrings.kDisplayName, value: newDisplayName, completion: nil)
        }
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
