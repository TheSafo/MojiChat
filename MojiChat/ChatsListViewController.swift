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
    private var recentsArr: [Dialog] = []
    private var friendsArr: [User] = []
    
    private var expandedFriendRow: Int? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.extendedLayoutIncludesOpaqueBars = false
        
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
        
        let messageListRef = FIRDatabase.database().reference().child("dialogs")
        messageListRef.observeEventType(.Value, withBlock: { (snapshot) in
            
            guard let dialogDicts = snapshot.value as? [String:AnyObject] else {
                return
            }
            
            let loadingMessagesGroup = dispatch_group_create()
            dispatch_group_enter(loadingMessagesGroup)
            self.friendsArr = []
            
            dispatch_group_notify(loadingMessagesGroup, dispatch_get_main_queue()) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
            
            let curUsrID = curUsr.uid
            
            var recents: [Dialog] = []
            
            for (key, value) in dialogDicts {
                let firstUser = (key as NSString).substringToIndex(28)
                let secondUser = (key as NSString).substringFromIndex(28)
                
                if firstUser == curUsrID || secondUser == curUsrID {
                    if let arr = value as? [[String:AnyObject]] {
                        let dialog = Dialog(user1: firstUser, user2: secondUser, messageArr: arr)
                        recents.append(dialog)
                    }
                }
            }
            
            recents.sortInPlace({ (di1, di2) -> Bool in
                let lastMsgTS1 = di1.messages.last?.timestamp ?? 0.0
                let lastMsgTS2 = di2.messages.last?.timestamp ?? 0.0
                
                return lastMsgTS1 < lastMsgTS2
            })
            
            self.recentsArr = recents
            
            dispatch_group_leave(loadingMessagesGroup)
        })
        
        //Config
        view.backgroundColor = UIColor.whiteColor()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(FriendTableViewCell.self, forCellReuseIdentifier: "friend")
        tableView.registerClass(RecentTableViewCell.self, forCellReuseIdentifier: "recent")
        tableView.rowHeight = 70
//        tableView.contentOffset = CGPointMake(0, 20) //status bar
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.separatorStyle = .None

        //Add subviews
        view.addSubview(tableView)
        
        //Constraints
        tableView.snp_makeConstraints { (make) in
            make.left.bottom.right.equalTo(view)
            make.top.equalTo(view).inset(0)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.hidden = true
    }
    
    //MARK: - Table View Data Source methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 90
        }
        else {
            if expandedFriendRow == indexPath.row {
                return 160
            }
            else {
                return 90
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 100
        }
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            let vw = UIView()
            vw.backgroundColor = UIColor.redColor()
            return vw
        }
        return nil
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
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
            let cell = tableView.dequeueReusableCellWithIdentifier("recent", forIndexPath: indexPath) as! RecentTableViewCell
//            cell.backgroundColor = UIColor.greenColor()
            cell.dialog = self.recentsArr[indexPath.row]
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

