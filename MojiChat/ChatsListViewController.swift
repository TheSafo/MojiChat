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



//        // For more complex open graph stories, use `FBSDKShareAPI`
//        // with `FBSDKShareOpenGraphContent`
//        /* make the API call */
//        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
//            initWithGraphPath:@"/{user-id}/friends"
//        parameters:params
//        HTTPMethod:@"GET"];
//        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
//        id result,
//        NSError *error) {
//        // Handle the result
//        }];

class ChatsListViewController: UIViewController {
    
    //Views
    private let tableView = UITableView()
    
    //Data
    
    //TODO: these aren't strings!
    private let recentsArr: [String] = []
    private let friendsArr: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        //Handle data
//        guard let curUsr = FIRAuth.auth()?.currentUser else {
//            
//            print("❗️❗️❗️ERROR: Could not get user data for chatlistcontroller")
//            return
//        }
//        
//        guard let fbdata = FBSDKAccessToken.currentAccessToken() else {
//            
//            print("❗️❗️❗️ERROR: facebook login issues")
//            return
//        }
        

        
        
        //Config
        view.backgroundColor = UIColor.redColor()
        
        //Add subviews
        
        //Constraints


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

