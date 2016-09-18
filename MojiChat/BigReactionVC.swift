//
//  BigReactionVC.swift
//  MojiChat
//
//  Created by Jake Saferstein on 9/18/16.
//  Copyright © 2016 Jake Saferstein. All rights reserved.
//

import Foundation
import UIKit

enum EmojiType: String {
    case Anger = "anger"
    case Neutral = "neutral"
//    case
}

class BigReactionVC : UIViewController {
    
    let type: EmojiType
    
    let imageVw = UIImageView()
    
    init(emojiName: String) {
        
        type = EmojiType(rawValue: emojiName) ?? .Neutral
        
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageVw)
        
        imageVw.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    private var tmr: NSTimer! = nil
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        tmr = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(endImageViewing), userInfo: nil, repeats: false)
    }
    
    func endImageViewing() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}