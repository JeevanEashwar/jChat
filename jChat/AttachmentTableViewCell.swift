//
//  AttachmentTableViewCell.swift
//  jChat
//
//  Created by Jeevan on 15/05/19.
//  Copyright © 2019 Jeevan. All rights reserved.
//

import UIKit
protocol FullScreenImageDelegate {
    func showImageWithDataOnFullScreen(data: Data)
}
class AttachmentTableViewCell: UITableViewCell {
    @IBOutlet weak var cellBackGroundView: UIView!
    @IBOutlet weak var attachedImageView: UIImageView!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var downloadImageView: UIImageView!
    @IBOutlet weak var imageLabelStackView: UIStackView!
    
    var photoURLString : String = ""
    var delegate : FullScreenImageDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        downloadImageView.dropShadowWithCornerRadius(cornerRadius: 5)
        attachedImageView.layer.masksToBounds = true
    }

    @IBAction func downloadImageClicked(_ sender: Any) {
        if let imageData = CollectionManager.shared.imagesCollection[self.photoURLString] {
            delegate?.showImageWithDataOnFullScreen(data: imageData)
        }
        else {
            self.downloadImageView.isHidden = true
            attachedImageView.downloadImageWithURLString(urlString: photoURLString) { (imageData) in
                CollectionManager.shared.imagesCollection[self.photoURLString] = imageData
            }
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureUI(imageURL: String, time: String, messageType : MessageType) {
        timeStampLabel.text = time
        photoURLString = imageURL
        if let imageData = CollectionManager.shared.imagesCollection[imageURL] {
            self.attachedImageView.image = UIImage(data: imageData)
            downloadImageView.isHidden = true
        }
        else {
            downloadImageView.isHidden = false
        }
        switch messageType {
        case .OTHER:
            leadingConstraint.constant = 10
            trailingConstraint.constant = 50
            cellBackGroundView.backgroundColor = UIColor.white
        case .ME:
            leadingConstraint.constant = 50
            trailingConstraint.constant = 10
            cellBackGroundView.backgroundColor = Colors.kChatGreen
        }
        cellBackGroundView.dropShadowWithCornerRadius(cornerRadius: 8)
        layoutIfNeeded()
    }
    
}
