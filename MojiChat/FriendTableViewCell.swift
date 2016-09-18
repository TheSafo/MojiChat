//
//  FriendTableViewCell.swift
//  MojiChat
//
//  Created by Jake Saferstein on 9/17/16.
//  Copyright © 2016 Jake Saferstein. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage


struct User {
    var deviceToken: String
    var name: String
    var profURL: NSURL
    
    init(userInfo: [String:AnyObject]) {
        self.deviceToken = userInfo["deviceToken"] as! String
        self.name = userInfo["name"] as! String
        
        let urlStr = userInfo["profURL"] as! String
        self.profURL = NSURL(string: urlStr)!
    }
}

class FriendTableViewCell : UITableViewCell {
    
    var usr: User? = nil {
        didSet {
            self.nameLbl.text = usr?.name
            
            if let url = usr?.profURL {
                self.profVw.sd_setImageWithURL(url, completed: { (img, err, type, url) in
                    self.profVw.layer.cornerRadius = self.profVw.bounds.width/2.0
                })
            }
            else {
                self.profVw.image = nil
            }
        }
    }
    
    var profVw = UIImageView()
    var nameLbl = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        profVw.contentMode = .ScaleAspectFit
        profVw.clipsToBounds = true
        
        nameLbl.font = UIFont.boldSystemFontOfSize(18)
        
        contentView.addSubview(nameLbl)
        contentView.addSubview(profVw)
        
        profVw.snp_makeConstraints { (make) in
            make.top.bottom.left.equalTo(contentView).inset(10)
            make.width.equalTo(profVw.snp_height)
        }
        nameLbl.snp_makeConstraints { (make) in
            make.left.equalTo(profVw.snp_right).offset(10)
            make.centerY.equalTo(contentView)
            make.width.height.greaterThanOrEqualTo(20)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        usr = nil
    }
    
    
}