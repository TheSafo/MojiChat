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

enum MessageType {
    case Photo
    case Emoji
}

struct Message {
    var type: MessageType
    var text: String
    var url: NSURL?
    
    init(info: [String:AnyObject]) {
        
        if info["type"] as? String == "Emoji" {
            type = .Emoji
        }
        else {
            type = .Photo
            url = NSURL(string: info["url"] as! String)
        }
        
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
        }
    }
    
    let imgVw = UIImageView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imgVw.contentMode = .ScaleAspectFit
        
        contentView.addSubview(imgVw)
        
        imgVw.snp_remakeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.message = nil
    }
}