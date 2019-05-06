//
//  Constants.swift
//  jChat
//
//  Created by Jeevan on 04/05/19.
//  Copyright © 2019 Jeevan. All rights reserved.
//

import Foundation
import FirebaseAuth

struct Constants {
    
}
struct UIElementTitles {
    static let kLoginText = "Login"
    static let kSignUpText = "Sign Up"
    static let kAdd = "Add"
}
struct AlertStrings {
    static let kAddNewContact = "Enter registered email of the contact"
    static let kAddContactPlaceHolder = "Registered Email"
    static let kNotRegisteredUser = "Not a Registered user"
    static let kAddSelfAsContactError = "Cannot add you as your contact"
}
struct AliasFor {
    static let kUserCollection = CollectionManager.shared.db.collection("Users")
    static let kCurrentUser = Auth.auth().currentUser
}
struct keyStrings {
    static let kEmail = "email"
    static let kUid = "uid"
    static let kDisplayName = "displayName"
    static let kCreatedOn = "createdOn"
    static let kPhotoURLString = "photoURLString"
    static let kContacts = "contacts"
}
