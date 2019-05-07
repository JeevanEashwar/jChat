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
    static let kPlaceHolderImageURL = "https://firebasestorage.googleapis.com/v0/b/jchat-6758c.appspot.com/o/profile-placeholder.jpg?alt=media&token=2eb20716-52b3-4dc1-8be9-fe2c2cecb331"
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
    static let kAddExistingAsContactError = "Contact exists already"
    static let kUserProfileUpdateSuccess = "Profile updated successfully"
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
    static let kPhotoURL = "photoURL"
    static let kContacts = "contacts"
}
