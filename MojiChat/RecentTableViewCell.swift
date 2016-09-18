//
//  RecentTableViewCell.swift
//  MojiChat
//
//  Created by Jake Saferstein on 9/18/16.
//  Copyright © 2016 Jake Saferstein. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import FirebaseDatabase
import FirebaseAuth

//protocol RecentTableViewCellDelegate {
//    func cellPressedWithDialog(dialog: Dialog)
//}

class RecentTableViewCell : UITableViewCell {
    
//    var delegate:RecentTableViewCellDelegate? = nil
    
    var dialog: Dialog? = nil {
        didSet {
            
            if let usrId = dialog?.getNoncurrentUser() {
                
                let nameRef = FIRDatabase.database().reference().child("userData/\(usrId)/name")
                nameRef.observeSingleEventOfType(.Value, withBlock: { (snap) in
                    self.senderLbl.text = snap.value as? String
                })
            }
            
            if let state = dialog?.getRecentDialogState() {
                switch state {
                case .UnreadPicture:
                    self.imgPreview.image = UIImage(named: "mc-unread-picture")
                    self.textPreview.text = "New Image"
                case .UnreadEmoji:
                    self.imgPreview.image = UIImage(named: "mc-unread-emoji")
                    self.textPreview.text = "New Reaction"
                case .ReadEmoji:
                    
                    let emoji = dialog?.messages.last?.text ?? "unknown"
                    
                    self.imgPreview.image = UIImage(named: "mc-read-emoji-\(emoji)")
                    self.textPreview.text = "Last Reacted"
                case .YouReacted:
                    
                    let emoji = dialog?.messages.last?.text ?? "unknown"
                    
                    self.imgPreview.image = UIImage(named: "mc-you-reacted-\(emoji)")
                    self.textPreview.text = "You last reacted"
                case .OtherUnreadPicture:
                    self.imgPreview.image = UIImage(named: "mc-other-unread-picture")
                    self.textPreview.text = "Image Sent"
                }
            }
            else {
                imgPreview.image = nil
                textPreview.text = nil
            }
            
            if let timestamp = dialog?.messages.last?.timestamp {
                let date = NSDate(timeIntervalSinceReferenceDate: timestamp)
                
                let fmt = NSDateFormatter()
                fmt.timeStyle = .ShortStyle
                fmt.dateStyle = .NoStyle
                timestampLbl.text = fmt.stringFromDate(date)
            }
            else {
                timestampLbl.text = nil
            }
            
            self.imgPreview.layer.cornerRadius = self.imgPreview.bounds.width/2.0
        }
    }
    
    let imgPreview = UIImageView()
    let senderLbl = UILabel()
    let textPreview = UILabel()
    let timestampLbl = UILabel()
    let arrowLbl = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        senderLbl.font = UIFont.boldSystemFontOfSize(18)
        
        arrowLbl.text = ">"
        arrowLbl.textColor = UIColor.lightGrayColor()
        
        contentView.addSubview(imgPreview)
        contentView.addSubview(senderLbl)
        contentView.addSubview(textPreview)
        contentView.addSubview(timestampLbl)
        contentView.addSubview(arrowLbl)
        
        contentView.snp_remakeConstraints { (make) in
            make.left.right.equalTo(self)
            make.top.bottom.equalTo(self).inset(10)
        }

        imgPreview.snp_makeConstraints { (make) in
            make.top.left.bottom.equalTo(contentView).inset(10)
            make.width.equalTo(imgPreview.snp_height)
        }
        senderLbl.snp_makeConstraints { (make) in
            make.top.equalTo(imgPreview)
            make.left.equalTo(imgPreview.snp_right).offset(10)
            make.height.equalTo(22)
            make.width.lessThanOrEqualTo(contentView).offset(-20)
        }
        textPreview.snp_makeConstraints { (make) in
            make.top.greaterThanOrEqualTo(senderLbl.snp_bottom).offset(10)
            make.bottom.equalTo(contentView).inset(10)
            make.left.equalTo(senderLbl)
            make.width.lessThanOrEqualTo(contentView).offset(-20)
        }
        timestampLbl.snp_makeConstraints { (make) in
            make.bottom.equalTo(contentView).inset(3)
            make.right.equalTo(arrowLbl.snp_left).offset(4)
            make.height.equalTo(14)
//            make.width.equalTo(24)
        }
        arrowLbl.snp_makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.right.equalTo(contentView)
            make.width.height.equalTo(14)
        }
        
        self.imgPreview.layer.cornerRadius = self.imgPreview.bounds.width/2.0

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        dialog = nil
        self.imgPreview.layer.cornerRadius = self.imgPreview.bounds.width/2.0
    }
}