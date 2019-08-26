//
//  ChatCell.swift
//  FirebaseSample
//
//  Created by Pavel H on 7/12/19.
//  Copyright © 2019 smartum.pro. All rights reserved.
//

import UIKit

protocol ChatCellDelegate: class {
    func didSelectMessage(message: Message, cell: ChatCell?)
}

class ChatCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageTextContainer: UIView!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var messageImageViewContainer: UIView!
    @IBOutlet weak var alignmentStackView: UIStackView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var dateLabel: UILabel!
    weak var delegate: ChatCellDelegate?
    var message: Message!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if message.isOutgoing() {
            contentView.layoutMargins.right = 16
            contentView.layoutMargins.left = 100
        } else {
            contentView.layoutMargins.right = 100
            contentView.layoutMargins.left = 16
        }
    }
    
    @IBAction func showImage(_ sender: Any) {
        delegate?.didSelectMessage(message: message, cell: self)
    }
    
    func setOutgoing(_ outgoing: Bool) {
        if outgoing {
            alignmentStackView.alignment = .trailing
            contentStackView.alignment = .trailing
            messageLabel.textAlignment = .right
        } else {
            alignmentStackView.alignment = .leading
            contentStackView.alignment = .leading
            messageLabel.textAlignment = .left
        }
    }
}
