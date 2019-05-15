//
//  ChatViewController.swift
//  jChat
//
//  Created by Jeevan on 14/05/19.
//  Copyright © 2019 Jeevan. All rights reserved.
//

import UIKit
import FirebaseAuth

struct MessageModel {
    var message : String
    var timeStamp : String
    var attachmentPhotoURL : String?
    var messageType : MessageType
    var threadId : String
}
class ChatViewController: BaseViewController {

    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var draftTextView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var messagesList : [MessageModel] = []
    var contactId : String = ""
    var imagePicker : UIImagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fetchAllChatMessages()
        registerNibs()
        keyboardHandling()
        addTapGesture()
        draftTextView.sizeToFit()
        draftTextView.isScrollEnabled = false
        draftTextView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.title = contactId
        self.navigationController!.navigationBar.topItem?.title = ""
        imagePicker.delegate = self
    }
    
    fileprivate func reloadMessageTableAndScrollToLastRow() {
        self.messagesTableView.reloadData()
        let lastIndex = self.messagesTableView.numberOfRows(inSection: 0)
        if lastIndex > 0 {
            let lastIndexPath = IndexPath(row: lastIndex - 1, section: 0)
            self.messagesTableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
        }
        
    }
    
    private func fetchAllChatMessages() {
        self.activityIndicator.startAnimating()
        if let currentUser = AliasFor.kCurrentUser?.email {
            let threadId = currentUser < self.contactId ? (currentUser + "_" + self.contactId) : (self.contactId + "_" + currentUser)
            AliasFor.kMessagesCollection.whereField(keyStrings.kThreadId, isEqualTo: threadId).order(by: keyStrings.kTimeStamp).getDocuments { (snapShot, error) in
                self.activityIndicator.stopAnimating()
                if let error = error {
                    self.showMessageOnlyAlert(message: error.localizedDescription, completion: nil)
                }
                else if let snapShot = snapShot {
                    self.messagesList.removeAll()
                    for document in snapShot.documents {
                        var messageModel = MessageModel(message: "", timeStamp: "", attachmentPhotoURL: nil, messageType: .ME, threadId: "")
                        if let fromEmail = document[keyStrings.kFromEmail] as? String {
                            messageModel.messageType = (fromEmail == self.contactId) ? .OTHER : .ME
                        }
                        if let message = document[keyStrings.kMessageString] as? String {
                            messageModel.message = message
                        }
                        if let timeStamp = document[keyStrings.kTimeStamp] as? String {
                            messageModel.timeStamp = timeStamp
                        }
                        if let threadId = document[keyStrings.kThreadId] as? String {
                            messageModel.threadId = threadId
                        }
                        if let photoURL = document[keyStrings.kPhotoURL] as? String {
                            messageModel.attachmentPhotoURL = photoURL
                        }
                        self.messagesList.append(messageModel)
                    }
                    self.reloadMessageTableAndScrollToLastRow()
                }
            }
        }
        
    }

    private func registerNibs() {
        messagesTableView.dataSource = self
        messagesTableView.delegate = self
        
        let nib1 = UINib(nibName: Nibname.kChatMessageCell, bundle: nil)
        messagesTableView.register(nib1, forCellReuseIdentifier: Nibname.kChatMessageCell)
        
        let nib2 = UINib(nibName: Nibname.kAttachmentTableViewCell, bundle: nil)
        messagesTableView.register(nib2, forCellReuseIdentifier: Nibname.kAttachmentTableViewCell)
        
        
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
        self.bottomConstraint.constant = 10
        self.view.layoutIfNeeded()
        
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y < 0{
            self.view.frame.origin.y += keyboardFrame.height
        }
        self.bottomConstraint.constant = 90
        self.view.layoutIfNeeded()
    }
    
    @IBAction func addAttachmentButtonClicked(_ sender: Any) {
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
    fileprivate func addDocumentToMessagesCollection(_ currentUser: String, _ timeStampString: String, _ messageText: String, _ threadId: String, photoURL : String?) {
        var messageDictionary : [String: Any] = [:]
        messageDictionary[keyStrings.kFromEmail] = currentUser
        messageDictionary[keyStrings.kToEmail] = contactId
        messageDictionary[keyStrings.kTimeStamp] = timeStampString
        messageDictionary[keyStrings.kMessageString] = messageText
        messageDictionary[keyStrings.kThreadId] = threadId
        if let photoURLString = photoURL {
            messageDictionary[keyStrings.kPhotoURL] = photoURLString
        }
        self.activityIndicator.startAnimating()
        AliasFor.kMessagesCollection.addDocument(data: messageDictionary) { (error) in
            self.activityIndicator.stopAnimating()
            if let error = error {
                self.showMessageOnlyAlert(message: error.localizedDescription, completion: nil)
            }else {
                
                let messageModel = MessageModel(message: messageText, timeStamp: timeStampString, attachmentPhotoURL: photoURL, messageType: .ME, threadId: threadId)
                self.messageSentSuccessfully(messageModel)
            }
        }
    }
    
    @IBAction func sendClicked(_ sender: Any) {
        self.dismissKeyboard()
        let messageText = draftTextView.text!
        let timeNow = Date(timeIntervalSinceNow: 0)
        let timeStampString = Constants.kCommonDateFormatter().string(from: timeNow)
        if let currentUser = AliasFor.kCurrentUser?.email {
            let threadId = currentUser < self.contactId ? (currentUser + "_" + self.contactId) : (self.contactId + "_" + currentUser)
            addDocumentToMessagesCollection(currentUser, timeStampString, messageText, threadId, photoURL: nil)
        }
        
    }
    private func messageSentSuccessfully(_ message:MessageModel) {
        draftTextView.text = ""
        self.messagesList.append(message)
        self.reloadMessageTableAndScrollToLastRow()
    }
    fileprivate func uploadSelectedImageToFirebaseStorage(chosenImage: UIImage) {
        if let currentUser = Auth.auth().currentUser {
            let picName = "UploadBy" + currentUser.uid + Date(timeIntervalSinceNow: 0).description + ".png"
            let otherPicsFolderRef = AliasFor.kOtherPicsStorageRef.child(picName)
            guard let imageData = chosenImage.pngData() else {
                return
            }
            // Start Upload
            self.activityIndicator.startAnimating()
            let uploadTask = otherPicsFolderRef.putData(imageData, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    //self.uploadFailed()
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                let size = metadata.size
                // You can also access to download URL after upload.
                otherPicsFolderRef.downloadURL { (url, error) in
                    self.activityIndicator.stopAnimating()
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        //self.uploadFailed()
                        return
                    }
                    if let  currentUserEmail = currentUser.email {
                        let threadId = currentUserEmail < self.contactId ? (currentUserEmail + "_" + self.contactId) : (self.contactId + "_" + currentUserEmail)
                        let timeNow = Date(timeIntervalSinceNow: 0)
                        let timeStampString = Constants.kCommonDateFormatter().string(from: timeNow)
                        self.addDocumentToMessagesCollection(currentUserEmail, timeStampString, "", threadId, photoURL: downloadURL.absoluteString)
                    }
                    
                }
                
            }
        }
    }
    
}
extension ChatViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messagesList[indexPath.row]
        if let messageHasAttachment = message.attachmentPhotoURL {
            let cell = tableView.dequeueReusableCell(withIdentifier: Nibname.kAttachmentTableViewCell, for: indexPath) as! AttachmentTableViewCell
            cell.configureUI(imageURL: messageHasAttachment, time: message.timeStamp, messageType: message.messageType)
            cell.delegate = self
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Nibname.kChatMessageCell, for: indexPath) as! ChatMessageTableViewCell
            cell.configureUI(message: message.message, time: message.timeStamp, messageType: message.messageType)
            return cell
        }
    }
    
}
extension ChatViewController : FullScreenImageDelegate {
    func showImageWithDataOnFullScreen(data: Data) {
        let fullScreenImageVC = FullScreenImageViewController()
        fullScreenImageVC.fullImageData = data
        self.navigationController?.pushViewController(fullScreenImageVC, animated: true)
    }
}
extension ChatViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let chosenImage = info[.editedImage] as? UIImage else {
            dismiss(animated: true, completion: nil)
            return
        }
        dismiss(animated: true) {
            self.uploadSelectedImageToFirebaseStorage(chosenImage:chosenImage)
            
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
