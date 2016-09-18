//
//  BigImageVC.swift
//  MojiChat
//
//  Created by Jake Saferstein on 9/18/16.
//  Copyright © 2016 Jake Saferstein. All rights reserved.
//

import Foundation
import UIKit

protocol BigImageDelegate {
    
    func didReactWithEmotion(emote: EmojiType)
}

class BigImageVC : UIViewController {
    
    var delegate: BigImageDelegate? = nil
    
    let imageVw = UIImageView()
    
    init(imageURL: NSURL!) {
        super.init(nibName: nil, bundle: nil)
        
        imageVw.sd_setImageWithURL(imageURL)
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
        super.viewDidAppear(true)
        
        tmr = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(takeReaction), userInfo: nil, repeats: false)
    }
    
    func takeReaction() {
        
        NSEC_PER_SEC
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(5.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            //TODO: handle
            self.delegate?.didReactWithEmotion(.Neutral)
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}