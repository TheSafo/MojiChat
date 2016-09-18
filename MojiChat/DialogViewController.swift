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



class DialogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //Table
    private let dialogID: String
    private let tableView = UITableView(frame: CGRectZero, style: .Grouped)
    private var messagesArray: [Message] = []
    
    //Other
    private var vcToShow: UIViewController? = nil
    private var currentIndex: Int? = nil
    
    private let libraryBtn = UIButton(type: .System)
    
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
        
        libraryBtn.backgroundColor = UIColor.redColor()
        libraryBtn.setTitle("Lib", forState: .Normal)
        libraryBtn.addTarget(self, action: #selector(libraryBtnPressed), forControlEvents: .TouchUpInside)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(DialogTableViewCell.self, forCellReuseIdentifier: "test")
        tableView.rowHeight = 150
        
        view.addSubview(tableView)
        view.addSubview(libraryBtn)
        
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        libraryBtn.snp_makeConstraints { (make) in
            make.bottom.right.equalTo(view).inset(20)
            make.left.equalTo(view.snp_centerY).offset(10)
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
    
    //MARK: - Buttons
    func libraryBtnPressed() {
        let ctrlr = UIImagePickerController()
        ctrlr.sourceType = .SavedPhotosAlbum
        ctrlr.delegate = self
        
        self.navigationController?.presentViewController(ctrlr, animated: true, completion: {
            
        })
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
                let msgInfo = ["type":"Photo", "url":url!.absoluteString]
                dialogRef.updateChildValues(["\(curInd)":msgInfo])
                self.currentIndex! += 1
            })
        }

        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}