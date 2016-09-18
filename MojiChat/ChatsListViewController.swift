//
//  ViewController.swift
//  MojiChat
//
//  Created by Jake Saferstein on 9/17/16.
//  Copyright © 2016 Jake Saferstein. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import FirebaseMessaging

class ChatsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FriendTableViewCellDelegate {
    
    //Views
    private let tableView = UITableView(frame: CGRectZero, style: .Grouped)
    
    //Data
    private var recentsArr: [String] = []
    private var friendsArr: [User] = []
    
    private var expandedFriendRow: Int? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Handle data
        guard let curUsr = FIRAuth.auth()?.currentUser else {
            
            print("❗️❗️❗️ERROR: Could not get user data for chatlistcontroller")
            return
        }
        
        let friendsListRef = FIRDatabase.database().reference().child("userData/\(curUsr.uid)/friends")
        friendsListRef.observeEventType(.Value, withBlock: { (snapshot) in
            
            guard let friendIDs = snapshot.value as? [String] else {
                return
            }
            
            let loadingFriendsGroup = dispatch_group_create()
            dispatch_group_enter(loadingFriendsGroup)
            self.friendsArr = []
            
            dispatch_group_notify(loadingFriendsGroup, dispatch_get_main_queue()) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
            
            for id in friendIDs {
                
                dispatch_group_enter(loadingFriendsGroup)
                
                let idRef = FIRDatabase.database().reference().child("userData/\(id)")
                idRef.observeSingleEventOfType(.Value, withBlock: { (idSnap) in
                    
                    if let userInfo = idSnap.value as? [String:AnyObject] {
                        
                        let usr = User(userInfo: userInfo, uid: id)
                        self.friendsArr.append(usr)
                    }
                    dispatch_group_leave(loadingFriendsGroup)
                })
            }
            dispatch_group_leave(loadingFriendsGroup)
        })
        
        //Config
        view.backgroundColor = UIColor.redColor()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(FriendTableViewCell.self, forCellReuseIdentifier: "friend")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "test")
        tableView.rowHeight = 70

        //Add subviews
        view.addSubview(tableView)
        
        //Constraints
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    //MARK: - Table View Data Source methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 70
        }
        else {
            if expandedFriendRow == indexPath.row {
                return 140
            }
            else {
                return 70
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return recentsArr.count
        }
        else {
            return friendsArr.count
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("test", forIndexPath: indexPath)
            cell.backgroundColor = UIColor.greenColor()
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("friend", forIndexPath: indexPath) as! FriendTableViewCell
            cell.usr = self.friendsArr[indexPath.row]
            cell.delegate = self
            if expandedFriendRow == indexPath.row {
                cell.isExpanded = true
            }
            
            return cell
        }
    }
    
    //MARK: Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            expandedFriendRow = nil

        }
        else {
            let usrPressed = self.friendsArr[indexPath.row]
            print("User pressed: \(usrPressed.name)")
            
            if expandedFriendRow == indexPath.row {
                
                let curUsrId = FIRAuth.auth()!.currentUser!.uid
                let usrPressedID = self.friendsArr[indexPath.row].uid
                
                let messageId = Message.calculateMessageID(curUsrId, userId2: usrPressedID)
                let msgVc = DialogViewController(dialogID: messageId, showCamera: false, showLibrary: false)
                
                self.navigationController?.pushViewController(msgVc, animated: true)
                
                expandedFriendRow = nil
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            }
            else {
                expandedFriendRow = indexPath.row
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            }
        }
    }
    
    //MARK: Cell handling
    func libraryPressedFromUser(user: User) {
        
        let curUsrId = FIRAuth.auth()!.currentUser!.uid
        let usrPressedID = user.uid

        let messageId = Message.calculateMessageID(curUsrId, userId2: usrPressedID)
        let msgVc = DialogViewController(dialogID: messageId, showCamera: false, showLibrary: true)

        self.navigationController?.pushViewController(msgVc, animated: true)
    }
    func cameraPressedFromUser(user: User) {
        
        let curUsrId = FIRAuth.auth()!.currentUser!.uid
        let usrPressedID = user.uid
        
        let messageId = Message.calculateMessageID(curUsrId, userId2: usrPressedID)
        let msgVc = DialogViewController(dialogID: messageId, showCamera: true, showLibrary: false)
        
        self.navigationController?.pushViewController(msgVc, animated: true)
    }
}

