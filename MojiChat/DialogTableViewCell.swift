//
//  DialogTableViewCell.swift
//  MojiChat
//
//  Created by Jake Saferstein on 9/18/16.
//  Copyright © 2016 Jake Saferstein. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import FirebaseDatabase

enum MessageType {
    case Photo
    case Emoji
}

struct Message {
    var type: MessageType
    var text: String
    var sender: String
    var url: NSURL?
    
    init(info: [String:AnyObject]) {
        
        if info["type"] as? String == "Emoji" {
            type = .Emoji
        }
        else {
            type = .Photo
            url = NSURL(string: info["url"] as! String)
        }
        
        sender = (info["sender"] as? String) ?? "dno5M31uO1h6Rf1ht8GAO3wWAaR2"
        
        text = (info["text"] as? String) ?? ""
    }
    
    static func calculateMessageID(userId1: String, userId2: String) -> String {
        
        if userId1 < userId2 {
            return userId1 + userId2
        }
        else {
            return userId2 + userId1
        }
    }
}

class DialogTableViewCell : UITableViewCell {
    
    var message: Message? = nil {
        didSet {
            if let url = message?.url {
                imgVw.sd_setImageWithURL(url)
            }
            else {
               imgVw.image = nil
            }
            
            if let senderId = message?.sender {
                
                let ref = FIRDatabase.database().reference().child("userData/\(senderId)/profURL")
                ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    if let urlStr = snapshot.value as? String {
                        if let url = NSURL(string: urlStr) {
                            self.senderVw.sd_setImageWithURL(url)
                        }
                    }
                })
            }
        }
    }
    
    let senderVw = UIImageView()
    let imgVw = UIImageView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        senderVw.contentMode = .ScaleAspectFill
        senderVw.clipsToBounds = true
        
        imgVw.contentMode = .ScaleAspectFill
        imgVw.clipsToBounds = true
        
        contentView.addSubview(senderVw)
        contentView.addSubview(imgVw)
        
        senderVw.snp_makeConstraints { (make) in
            make.top.left.equalTo(contentView).inset(10)
            make.width.height.equalTo(40)
        }
        imgVw.snp_remakeConstraints { (make) in
            make.right.bottom.equalTo(contentView).inset(10)
            make.left.equalTo(senderVw.snp_right).offset(10)
            make.top.equalTo(contentView).inset(25)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.senderVw.layer.cornerRadius = self.senderVw.bounds.width/2.0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.message = nil
    }
}