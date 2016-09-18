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
    var uid: String
    
    init(userInfo: [String:AnyObject], uid: String) {
        self.deviceToken = userInfo["deviceToken"] as! String
        self.name = userInfo["name"] as! String
        
        let urlStr = userInfo["profURL"] as! String
        self.profURL = NSURL(string: urlStr)!
        
        self.uid = uid
    }
}

protocol FriendTableViewCellDelegate {
    func libraryPressedFromUser(user: User)
    func cameraPressedFromUser(user: User)
}

class FriendTableViewCell : UITableViewCell {
    
    var delegate: FriendTableViewCellDelegate? = nil
    
    var usr: User? = nil {
        didSet {
            self.nameLbl.text = usr?.name
            
            if let url = usr?.profURL {
                self.profVw.sd_setImageWithURL(url, completed: { (img, err, type, url) in
                })
            }
            else {
                self.profVw.image = nil
            }
            
            self.profVw.layer.cornerRadius = self.profVw.bounds.width/2.0
        }
    }
    
    var isExpanded: Bool = false {
        didSet {
            if isExpanded {
                
                contentView.addSubview(libraryBtn)
                contentView.addSubview(cameraBtn)
                
                profVw.snp_remakeConstraints { (make) in
                    make.top.left.equalTo(contentView).inset(10)
                    make.bottom.equalTo(contentView.snp_centerY).offset(-10)
                    make.width.equalTo(profVw.snp_height)
                }
//                nameLbl.snp_remakeConstraints { (make) in
//                    make.left.equalTo(profVw.snp_right).offset(10)
//                    make.centerY.equalTo(profVw)
//                    make.width.height.greaterThanOrEqualTo(20)
//                }
                
                cameraBtn.snp_remakeConstraints { (make) in
                    make.left.bottom.equalTo(contentView).inset(10)
                    make.top.equalTo(contentView.snp_centerY).offset(5)
                    make.right.equalTo(contentView.snp_centerX).inset(-5)
                }
                libraryBtn.snp_remakeConstraints { (make) in
                    make.right.bottom.equalTo(contentView).inset(10)
                    make.top.equalTo(contentView.snp_centerY).offset(5)
                    make.left.equalTo(contentView.snp_centerX).offset(5)
                }
            }
            else {
                profVw.snp_remakeConstraints { (make) in
                    make.top.bottom.left.equalTo(contentView).inset(10)
                    make.width.equalTo(profVw.snp_height)
                }
//                nameLbl.snp_remakeConstraints { (make) in
//                    make.left.equalTo(profVw.snp_right).offset(10)
//                    make.centerY.equalTo(contentView)
//                    make.width.height.greaterThanOrEqualTo(20)
//                }
                
                cameraBtn.removeFromSuperview()
                libraryBtn.removeFromSuperview()
            }
            self.profVw.layer.cornerRadius = self.profVw.bounds.width/2.0
        }
    }
    
    let profVw      = UIImageView()
    let nameLbl     = UILabel()
    let libraryBtn  = UIButton(type: .System)
    let cameraBtn   = UIButton(type: .System)

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        profVw.contentMode = .ScaleAspectFill
        profVw.clipsToBounds = true
        
        nameLbl.font = UIFont.boldSystemFontOfSize(18)
        
        cameraBtn.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        cameraBtn.setTitle("Cam", forState: .Normal)
        cameraBtn.layer.cornerRadius = 9
        cameraBtn.addTarget(self, action: #selector(self.cameraBtnPressed), forControlEvents: .TouchUpInside)
        
        libraryBtn.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        libraryBtn.setTitle("LIb", forState: .Normal)
        libraryBtn.layer.cornerRadius = 9
        libraryBtn.addTarget(self, action: #selector(self.libraryBtnPressed), forControlEvents: .TouchUpInside)

        contentView.addSubview(nameLbl)
        contentView.addSubview(profVw)

        contentView.snp_remakeConstraints { (make) in
            make.left.right.equalTo(self)
            make.top.bottom.equalTo(self).inset(10)
        }
        
        profVw.snp_makeConstraints { (make) in
            make.top.bottom.left.equalTo(contentView).inset(10)
            make.width.equalTo(profVw.snp_height)
        }
        nameLbl.snp_makeConstraints { (make) in
            make.left.equalTo(profVw.snp_right).offset(10)
            make.centerY.equalTo(profVw)
            make.width.height.greaterThanOrEqualTo(20)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.profVw.layer.cornerRadius = self.profVw.bounds.width/2.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        usr = nil
        isExpanded = false
        delegate = nil
        
    }
    
    func cameraBtnPressed() {
        delegate?.cameraPressedFromUser(usr!)
    }
    
    func libraryBtnPressed() {
        delegate?.libraryPressedFromUser(usr!)
    }
}