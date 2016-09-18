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

class DialogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //Table
    private let tableView = UITableView(frame: CGRectZero, style: .Grouped)
    private var messagesArray: [Message] = []
    
    //Other
    private var vcToShow: UIViewController? = nil
    
    private let dialogID: String
    
    init(dialogID: String, showCamera: Bool, showLibrary: Bool) {
        self.dialogID = dialogID

        super.init(nibName: nil, bundle: nil)
        
        if showCamera {
            if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                let ctrlr = UIImagePickerController()
                ctrlr.showsCameraControls = true
                ctrlr.sourceType = .Camera
                ctrlr.cameraCaptureMode = .Photo
                ctrlr.delegate = self
                
                vcToShow = ctrlr
            }
        }
        if showLibrary {
            let ctrlr = UIImagePickerController()
            ctrlr.sourceType = .SavedPhotosAlbum
            ctrlr.delegate = self
            
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
                    })
                }

                
                for obj in msgArray {
                    if let dict = obj as? [String:AnyObject] {
                        let msg = Message(info: dict)
                        self.messagesArray.append(msg)
                    }
                }
                
                dispatch_group_leave(loadingMsgsGroup)
            }
        })
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "test")
        
        view.addSubview(tableView)
        
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let vc = vcToShow {
            self.presentViewController(vc, animated: true, completion: { 
                self.vcToShow = nil
            })
        }
    }
    
    
    //MARK: - Table View Data Source methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("test", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.greenColor()
        return cell
    }
    
    //MARK: - IMage reception
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        print("got image")
        
        let asData = UIImagePNGRepresentation(image)!
  
        let storage = FIRStorage.storage()
        let fileName = "\(image.hash).png"
        let imgRef = storage.referenceForURL("gs://mojichat-afe91.appspot.com").child("images").child(fileName)

        let uploadTask = imgRef.putData(asData)
        
        // Add a progress observer to an upload task
        let observer = uploadTask.observeStatus(.Success) { snapshot in
            
            imgRef.downloadURLWithCompletion({ (url, err) in
                
                let dialogRef = FIRDatabase.database().reference().child("dialogs/\(self.dialogID)")
                let msgInfo = ["type":"Photo", "url":url!.absoluteString]
                dialogRef.setValue(["0":msgInfo])
            })
        }

        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}