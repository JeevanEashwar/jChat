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
    static let kGallery = "Pick from gallery"
    static let kCamera = "Take new picure from camera"
    static let kUploadProgress = "Upload in progress. "
}
struct AlertStrings {
    static let kAddNewContact = "Enter registered email of the contact"
    static let kAddContactPlaceHolder = "Registered Email"
    static let kNotRegisteredUser = "Not a Registered user"
    static let kAddSelfAsContactError = "Cannot add you as your contact"
    static let kAddExistingAsContactError = "Contact exists already"
    static let kUserProfileUpdateSuccess = "Profile updated successfully"
    static let kImagePickMessage = "Please choose an option to pick the new image"
    static let kNoCameraMessage = "Unable to access the camera. Please check the camera permissions and try again"
    static let kNoLibraryMessage = "Unable to access the Photo Library. Please check the permissions and try again"
    static let kUploadImageFailed = "Could not upload the picture. please try again"
}
struct AliasFor {
    static let kUserCollection = CollectionManager.shared.db.collection("Users")
    static let kCurrentUser = Auth.auth().currentUser
    static let kProfilePicStorageRef = CollectionManager.shared.storage.reference().child("UserProfilePics")
}
struct keyStrings {
    static let kEmail = "email"
    static let kUid = "uid"
    static let kDisplayName = "displayName"
    static let kCreatedOn = "createdOn"
    static let kPhotoURL = "photoURL"
    static let kContacts = "contacts"
}
