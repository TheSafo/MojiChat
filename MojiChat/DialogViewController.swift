//
//  DialogViewController.swift
//  MojiChat
//
//  Created by Jake Saferstein on 9/17/16.
//  Copyright © 2016 Jake Saferstein. All rights reserved.
//

import Foundation
import UIKit
import Firebase



class DialogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, BigImageDelegate {

    //Table
    private let dialogID: String
    private let tableView = UITableView(frame: CGRectZero, style: .Grouped)
    private var messagesArray: [Message] = []
    
    //Other
    private var vcToShow: UIViewController? = nil
    private var currentIndex: Int? = nil
    
    private let libraryBtn = UIButton(type: .System)
    
    init(dialog: Dialog, shouldShowBigReaction: Bool, shouldShowImageAndTakeReaction: Bool) {
        self.dialogID = dialog.user1 + dialog.user2
        
        super.init(nibName: nil, bundle: nil)
        
        self.messagesArray = dialog.messages
        self.currentIndex = dialog.messages.count
        
        for i in 0..<messagesArray.count {
            
            let msg = messagesArray[i]
            if msg.sender == FIRAuth.auth()!.currentUser!.uid {
                continue
            }
            let ref = FIRDatabase.database().reference().child("dialogs/\(dialogID)/\(i)/wasRead")
            ref.setValue(true)
        }
        
        if shouldShowBigReaction {
            let vc = BigReactionVC(emojiName: messagesArray.last!.text)
            vcToShow = vc
        }
        if shouldShowImageAndTakeReaction {
            let vc = BigImageVC(imageURL: messagesArray.last!.url)
            vc.delegate = self
            vcToShow = vc
        }
        
        let dialogRef = FIRDatabase.database().reference().child("dialogs/\(dialogID)")
        dialogRef.observeEventType(.Value, withBlock: { (snapshot) in
            
            if let msgArray = snapshot.value as? [AnyObject] {
                
                let loadingMsgsGroup = dispatch_group_create()
                dispatch_group_enter(loadingMsgsGroup)
                self.messagesArray = []
                
                dispatch_group_notify(loadingMsgsGroup, dispatch_get_main_queue()) {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messagesArray.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
                    })
                }
                
                
                for obj in msgArray {
                    if let dict = obj as? [String:AnyObject] {
                        let msg = Message(info: dict)
                        self.messagesArray.append(msg)
                    }
                }
                self.currentIndex = msgArray.count
                
                dispatch_group_leave(loadingMsgsGroup)
            }
        })
    }
    
    init(dialogID: String, showCamera: Bool, showLibrary: Bool) {
        self.dialogID = dialogID

        super.init(nibName: nil, bundle: nil)
        
        if showCamera {
            if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                let ctrlr = UIImagePickerController()
                ctrlr.sourceType = .Camera
                ctrlr.cameraCaptureMode = .Photo
                ctrlr.showsCameraControls = true
                ctrlr.delegate = self
                
                currentIndex = 0
                
                vcToShow = ctrlr
            }
        }
        if showLibrary {
            let ctrlr = UIImagePickerController()
            ctrlr.sourceType = .SavedPhotosAlbum
            ctrlr.delegate = self
            
            currentIndex = 0

            vcToShow = ctrlr
        }
        
        let dialogRef = FIRDatabase.database().reference().child("dialogs/\(dialogID)")
        dialogRef.observeEventType(.Value, withBlock: { (snapshot) in
            
            if let msgArray = snapshot.value as? [AnyObject] {
                
                let loadingMsgsGroup = dispatch_group_create()
                dispatch_group_enter(loadingMsgsGroup)
                self.messagesArray = []
                
                dispatch_group_notify(loadingMsgsGroup, dispatch_get_main_queue()) {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messagesArray.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
                    })
                }

                
                for obj in msgArray {
                    if let dict = obj as? [String:AnyObject] {
                        let msg = Message(info: dict)
                        self.messagesArray.append(msg)
                    }
                }
                self.currentIndex = msgArray.count
                
                dispatch_group_leave(loadingMsgsGroup)
            }
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        libraryBtn.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        libraryBtn.setTitle("Library", forState: .Normal)
        libraryBtn.layer.cornerRadius = 9
        libraryBtn.addTarget(self, action: #selector(libraryBtnPressed), forControlEvents: .TouchUpInside)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(DialogTableViewCell.self, forCellReuseIdentifier: "test")
//        tableView.rowHeight = 150
        
        view.addSubview(tableView)
        view.addSubview(libraryBtn)
        
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        libraryBtn.snp_makeConstraints { (make) in
            make.bottom.right.equalTo(view).inset(20)
            make.left.equalTo(view.snp_centerX).offset(10)
            make.height.equalTo(40)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let vc = vcToShow {
            self.navigationController?.presentViewController(vc, animated: true, completion: {
                self.vcToShow = nil
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.hidden = false
    }
    
    //MARK: - Buttons
    func libraryBtnPressed() {
        let ctrlr = UIImagePickerController()
        ctrlr.sourceType = .SavedPhotosAlbum
        ctrlr.delegate = self
        
        self.navigationController?.presentViewController(ctrlr, animated: true, completion: {
            
        })
    }
    
    //MARK: - Delegate
    func didReactWithEmotion(emote: EmojiType) {
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        
        guard let curInd = currentIndex else {
            print("got reaction but hard to deal with this case")
            return
        }
        
        let dialogRef = FIRDatabase.database().reference().child("dialogs/\(self.dialogID)")
        let msgInfo = ["type":"Emoji", "text":emote.rawValue, "sender":FIRAuth.auth()!.currentUser!.uid, "timestamp":NSDate().timeIntervalSinceReferenceDate, "wasRead":false]
        dialogRef.updateChildValues(["\(curInd)":msgInfo])
        self.currentIndex! += 1
    }
    
    
    //MARK: - Table View Data Source methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("test", forIndexPath: indexPath) as! DialogTableViewCell
        cell.message = self.messagesArray[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let msg = self.messagesArray[indexPath.row]
        
        if msg.type == .Emoji {
            return 150
        }
        else {
            return 250
        }
    }
    
    //MARK: - IMage reception
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        guard let curInd = currentIndex else {
            
            print("got image but hard to deal with this case")
            return
        }
        
        print("got image")
        
        let asData = UIImagePNGRepresentation(image)!
  
        let storage = FIRStorage.storage()
        let fileName = "\(image.hash).png"
        let imgRef = storage.referenceForURL("gs://mojichat-afe91.appspot.com").child("images").child(fileName)

        let uploadTask = imgRef.putData(asData)
        
        // Add a progress observer to an upload task
        let _ = uploadTask.observeStatus(.Success) { snapshot in
            
            imgRef.downloadURLWithCompletion({ (url, err) in
                
                let dialogRef = FIRDatabase.database().reference().child("dialogs/\(self.dialogID)")
                let msgInfo = ["type":"Photo", "url":url!.absoluteString, "sender":FIRAuth.auth()!.currentUser!.uid, "timestamp":NSDate().timeIntervalSinceReferenceDate, "wasRead":false]
                dialogRef.updateChildValues(["\(curInd)":msgInfo])
                self.currentIndex! += 1
            })
        }

        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}