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

class ChatsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //Views
    private let tableView = UITableView()
    
    //Data
    private var recentsArr: [String] = []
    private var friendsArr: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Handle data
        guard let curUsr = FIRAuth.auth()?.currentUser else {
            
            print("❗️❗️❗️ERROR: Could not get user data for chatlistcontroller")
            return
        }
        
        let serviceGroup = dispatch_group_create()
        
        dispatch_group_enter(serviceGroup)
        
        dispatch_group_notify(serviceGroup, dispatch_get_main_queue()) { 
            dispatch_async(dispatch_get_main_queue(), { 
                self.tableView.reloadData()
            })
        }
        
        let friendsListRef = FIRDatabase.database().reference().child("userData/\(curUsr.uid)/friends")
        friendsListRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            guard let friendIDs = snapshot.value as? [String] else {
                
                return
            }
            
            for id in friendIDs {
                
                dispatch_group_enter(serviceGroup)
                
                let idRef = FIRDatabase.database().reference().child("userData/\(id)")
                idRef.observeSingleEventOfType(.Value, withBlock: { (idSnap) in
                    
                    if let userInfo = idSnap.value as? [String:AnyObject] {
                        
                        let usr = User(userInfo: userInfo)
                        self.friendsArr.append(usr)
                    }
                    dispatch_group_leave(serviceGroup)
                })
            }
            
            dispatch_group_leave(serviceGroup)
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
            return cell
        }
    }
    
    //MARK: Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            
        }
        else {
            let usrPressed = self.friendsArr[indexPath.row]
            
            print("User pressed: \(usrPressed.name)")
            
            
        }
    }
}

