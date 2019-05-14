//
//  ProfileViewController.swift
//  jChat
//
//  Created by Jeevan on 06/05/19.
//  Copyright © 2019 Jeevan. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class ProfileViewController: BaseViewController {
    
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressIndicatorBar: UIProgressView!
    @IBOutlet weak var progressMessage: UILabel!
    
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    
    var imagePicker : UIImagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.isHidden = true
        imagePicker.delegate = self
        setupContactImageView()
        keyboardHandling()
        addTapGesture()
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
    
}
extension ProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let chosenImage = info[.editedImage] as? UIImage else {
            dismiss(animated: true, completion: nil)
            return
        }
        self.contactImage.image = chosenImage
        dismiss(animated: true) {
            self.uploadSelectedImageToFirebaseStorage(chosenImage:chosenImage)
            
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
extension ProfileViewController {
    //MARK: HelperMethods
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
    fileprivate func setupContactImageView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showImagePickOptions))
        tapGesture.cancelsTouchesInView = false
        contactImage.addGestureRecognizer(tapGesture)
        contactImage.isUserInteractionEnabled = true
        contactImage.layer.cornerRadius = contactImage.frame.height/2
        contactImage.layer.masksToBounds = true
        // Do any additional setup after loading the view.
        if let currentUser = Auth.auth().currentUser {
            displayName.text = currentUser.displayName ?? ""
            if let photoUrl = currentUser.photoURL {
                self.contactImage.load(url: photoUrl)
            }else if let placeHolderURL = URL(string: Constants.kPlaceHolderImageURL) {
                self.contactImage.load(url: placeHolderURL)
            }
        }
    }
    @objc func showImagePickOptions() {
        showTwoOptionsAlert(message: AlertStrings.kImagePickMessage, text1: UIElementTitles.kGallery, text2: UIElementTitles.kCamera, selection1: {
            //Gallery
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .photoLibrary
                self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            else {
                self.showMessageOnlyAlert(message: AlertStrings.kNoLibraryMessage, completion: nil)
            }
        }) {
            //Camera
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .camera
                self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
                self.present(self.imagePicker, animated: true, completion: nil)
            }else {
                self.showMessageOnlyAlert(message: AlertStrings.kNoCameraMessage, completion: nil)
            }
        }
    }
    fileprivate func addObservers(_ uploadTask: StorageUploadTask) {
        uploadTask.observe(.progress) { (snapshot) in
            let percentComplete = Float(snapshot.progress!.completedUnitCount)
                / Float(snapshot.progress!.totalUnitCount)
            self.updateProgressBar(percentage: percentComplete)
        }
        uploadTask.observe(.success) { (snapshot) in
            // Upload completed successfully
            self.progressView.isHidden = true
            self.activityIndicator.stopAnimating()
            uploadTask.removeAllObservers()
        }
        uploadTask.observe(.failure) { (snapshot) in
            // Upload Failed
            self.uploadFailed()
            self.showMessageOnlyAlert(message: AlertStrings.kUploadImageFailed, completion: nil)
            uploadTask.removeAllObservers()
        }
    }
    
    fileprivate func uploadSelectedImageToFirebaseStorage(chosenImage: UIImage) {
        if let currentUser = Auth.auth().currentUser {
            let picName = currentUser.uid + (currentUser.displayName ?? "DisplayName") + Date(timeIntervalSinceNow: 0).description + ".png"
            let profilePicFolderRef = AliasFor.kProfilePicStorageRef.child(picName)
            guard let imageData = chosenImage.pngData() else {
                return
            }
            // Start Upload
            self.activityIndicator.startAnimating()
            let uploadTask = profilePicFolderRef.putData(imageData, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    self.uploadFailed()
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                let size = metadata.size
                // You can also access to download URL after upload.
                profilePicFolderRef.downloadURL { (url, error) in
                    self.activityIndicator.stopAnimating()
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        self.uploadFailed()
                        return
                    }
                    self.progressView.isHidden = true
                    self.setNewlyUploadedImageAsProfilePicture(downloadURL: downloadURL)
                }
                
            }
            self.addObservers(uploadTask)
            
        }
    }
    func setNewlyUploadedImageAsProfilePicture(downloadURL: URL) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.photoURL = downloadURL
        self.activityIndicator.startAnimating()
        changeRequest?.commitChanges { (error) in
            // ...
            self.activityIndicator.stopAnimating()
            self.showMessageOnlyAlert(message: AlertStrings.kUserProfileUpdateSuccess, completion: nil)
        }
        self.updateCurrentUserDocument(field: keyStrings.kPhotoURL, value: downloadURL.absoluteString, completion: nil)
    }
    func uploadFailed() {
        self.progressView.isHidden = true
        self.activityIndicator.stopAnimating()
        print("Could not upload")
    }
    func updateProgressBar(percentage: Float) {
        if percentage > 0.0 && percentage <= 1.0 {
            DispatchQueue.main.async {
                self.progressView.isHidden = false
                self.progressIndicatorBar.setProgress(percentage, animated: true)
                self.progressMessage.text = UIElementTitles.kUploadProgress
            }
        }
        
    }
    private func keyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y >= 0 {
            self.view.frame.origin.y -= keyboardFrame.height
        }
        self.view.layoutIfNeeded()
        
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y < 0{
            self.view.frame.origin.y += keyboardFrame.height
        }
        self.view.layoutIfNeeded()
    }
}

extension UIImageView {
    func load(url: URL) {
        let activityIndicatorRef = self.startActivityIndicator()
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        activityIndicatorRef.stopAnimating()
                        self?.image = image
                    }
                }
            }else {
                DispatchQueue.main.async {
                    activityIndicatorRef.stopAnimating()
                }
            }
        }
    }
    func startActivityIndicator() -> UIActivityIndicatorView {
        var activityIndicator: UIActivityIndicatorView!
        activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        var centerPoint = self.center
        centerPoint.x = self.bounds.width / 2
        centerPoint.y = self.bounds.height / 2
        activityIndicator.center = centerPoint
        activityIndicator.hidesWhenStopped = true
        self.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        return activityIndicator
    }
}
