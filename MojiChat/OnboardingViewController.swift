//
//  OnboardingViewController.swift
//  MojiChat
//
//  Created by Jake Saferstein on 9/17/16.
//  Copyright © 2016 Jake Saferstein. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class OnboardingViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    private let fbLoginBtn = FBSDKLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configure
        view.backgroundColor = UIColor.yellowColor()
        
        fbLoginBtn.delegate = self
        fbLoginBtn.readPermissions = ["public_profile", "email", "user_friends"]
        
        //Add subviews
        view.addSubview(fbLoginBtn)
        
        //Constraints
        fbLoginBtn.snp_makeConstraints { (make) in
            make.center.equalTo(view)
        }
    }
    
    class func updateFacebookFriends() {
        
        let request = FBSDKGraphRequest(graphPath: "me/friends", parameters: [:], HTTPMethod: "GET")
        
        request.startWithCompletionHandler { (connection, result, err) in
            guard err == nil else {
                return
            }
            
            let usrArr = result["data"] as! [AnyObject]
            
            let fbids = usrArr.map({ (usr) -> String in
                return usr["id"] as! String
            })
            
            print("ids: \(fbids)")
            
            let ref = FIRDatabase.database().reference().child("fbidToUID")
            ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in

                if let allPairs = snapshot.value as? NSDictionary {
                    
                    print("all pairs: \(allPairs)")
                    
                    var arrayOfUIDs = [String]()

                    for (key, val) in allPairs {
                        
                        if fbids.contains(key as! String) {
                            arrayOfUIDs.append(val as! String)
                        }
                    }
                    let uid = FIRAuth.auth()?.currentUser?.uid ?? "error"
                    let ref = FIRDatabase.database().reference().child("userData/\(uid)/friends")
                    ref.setValue(arrayOfUIDs)
                }
            })
        }
    }
    

    //MARK: - FB login shit
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        guard error == nil else {
            print("\(error)")
            return
        }
        

        
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
        
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            
            if let uid = FIRAuth.auth()?.currentUser?.uid {
                
                let ref = FIRDatabase.database().reference().child("fbidToUID/\(FBSDKAccessToken.currentAccessToken().userID)")
                let value = uid
                ref.setValue(value)
                
                let request = FBSDKGraphRequest.init(graphPath: "me", parameters: [:], HTTPMethod: "GET")
                
                request.startWithCompletionHandler { (connection, result, err) in
                    guard err == nil else{
                        return
                    }
                    
                    let userRef = FIRDatabase.database().reference().child("userData/\(uid)")
                    
                    let name = result["name"] as? String ?? "error"
                    
                    let id = result["id"] as? String ?? "err"
                    let profURL = "https://graph.facebook.com/\(id)/picture?type=large"
                    let token = FIRInstanceID.instanceID().token()!
                    
                    let updated: [String: AnyObject] = ["name":name, "profURL":profURL, "deviceToken":token]
                    userRef.updateChildValues(updated)
                }
            }
        
            
            OnboardingViewController.updateFacebookFriends()
            
            self.navigationController?.setViewControllers([ChatsListViewController()], animated: true)
        }
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
}