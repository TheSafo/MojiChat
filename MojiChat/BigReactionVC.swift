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
    case Unknown = "unknown"
    case Disgust = "disgust"
    case Fear = "fear"
    case Sadness = "sadness"
    case Surprise = "surprise"
    case Happiness = "happiness"
    case Happiness2 = "happiness-2"
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
        
        imageVw.contentMode = .ScaleAspectFit
        
        view.addSubview(imageVw)
        
        imageVw.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    private var tmr: NSTimer! = nil
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let imgName = (type.rawValue == "unknown") ? "happiness" : type.rawValue
        
        let images = (0..<60).map { (i) -> UIImage in
            let name = (i < 10) ? "\(imgName)_0000\(i)" : "\(imgName)_000\(i)"
            return UIImage(named: name)!
        }
        
        self.imageVw.animationImages = images
        imageVw.contentMode = .ScaleAspectFit
//        self.imageVw.animationDuration = 2.0
        self.imageVw.animationRepeatCount = 1
        
        self.imageVw.startAnimating()
        
        tmr = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(endImageViewing), userInfo: nil, repeats: false)
    }
    
    func endImageViewing() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}