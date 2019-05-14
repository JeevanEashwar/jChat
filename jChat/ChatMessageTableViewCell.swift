//
//  ChatMessageTableViewCell.swift
//  jChat
//
//  Created by Jeevan on 14/05/19.
//  Copyright © 2019 Jeevan. All rights reserved.
//

import UIKit
enum MessageType {
    case OTHER
    case ME
}
class ChatMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var cellBackGroundView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureUI(message: String, time: String, messageType : MessageType) {
        messageLabel.text = message
        timeStampLabel.text = time
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
