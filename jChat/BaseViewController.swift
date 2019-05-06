//
//  AlertControllerProtocol.swift
//  jChat
//
//  Created by Jeevan on 04/05/19.
//  Copyright © 2019 Jeevan. All rights reserved.
//

import Foundation
import UIKit

class BaseViewController : UIViewController {
    public var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        self.addActivityIndicator()
    }
    func showMessageOnlyAlert(message: String, completion: (()->())?) {
        let alert = UIAlertController(title: "jChat", message: message, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
            print("User click Dismiss button")
        }))
        
        self.present(alert, animated: true, completion: {
            if let completion = completion {
                completion()
            }
            print("completion block")
        })
    }
    func showTextFieldAlert(message: String, placeholder: String, constructiveButtonTitle : String, completion: @escaping ((String)->())) {
        let alert = UIAlertController(title: "jChat", message: message, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = placeholder
        })
        
        alert.addAction(UIAlertAction(title: constructiveButtonTitle, style: .default, handler: { (_) in
            let firstTextField = alert.textFields![0] as UITextField
            if let textFieldText = firstTextField.text {
                completion(textFieldText)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
            print("User click Dismiss button")
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    // MARK: - General Methods
    func addActivityIndicator() {
        // Set activity indicator properties and start animating for first time load
        activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        var centerPoint = self.view.center
        centerPoint.x = UIScreen.main.bounds.width / 2
        activityIndicator.center = centerPoint
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
    }
}
