//
//  ChatTableViewCell.swift
//  iOSTest
//
//  Created by D & A Technologies on 1/22/18.
//  Copyright © 2018 D & A Technologies. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    /**
     * =========================================================================================
     * INSTRUCTIONS
     * =========================================================================================
     * 1) Setup cell to match mockup
     *
     * 2) Include user's avatar image
     **/
    
    // MARK: - Outlets
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var body: EdgeInsetLabel!
    @IBOutlet weak var avatar: UIImageView!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Public
    func setCellData(message: Message) {
        header.text = message.username
        body.text = message.text
        
        // Custom Properties For Text Bubble Appearance, and Edge Insets
        body.layer.borderWidth = 1.0
        body.layer.borderColor = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.0).cgColor
        body.layer.backgroundColor = UIColor.white.cgColor
        body.textInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        avatar.layer.cornerRadius = avatar.frame.height/2
        
        // Assigning and Checking Avatar Images Asynchronously to Prevent Blocking UI
        DispatchQueue.main.async {
            do {
                let avImage = try Data(contentsOf: message.avatarURL)
                self.avatar.image = UIImage(data: avImage)
            }
            catch let error {
                print(error)
            }
        }
    }
}

// MARK: - Custom Class From UILabel To Add Label Insets
class EdgeInsetLabel: UILabel {
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    // Overriding Ncessary Functions To Create And Draw Custom CGRects
    // NOTE: Number of lines in .xib MUST be set to 0
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = UIEdgeInsetsInsetRect(bounds, textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return UIEdgeInsetsInsetRect(textRect, invertedInsets)
    }
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, textInsets))
    }
}
