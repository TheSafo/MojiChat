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


//https://mojichat-afe91.firebaseapp.com/__/auth/handler

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
    

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        guard error == nil else {
            print("\(error)")
            return
        }
        
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
        
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            // ...
            
            self.navigationController?.setViewControllers([ChatsListViewController()], animated: true)
        }
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
}