//
//  ViewController.swift
//  MojiChat
//
//  Created by Jake Saferstein on 9/17/16.
//  Copyright © 2016 Jake Saferstein. All rights reserved.
//

import UIKit

class ChatsListViewController: UIViewController {
    
    //Views
    private let tableView = UITableView()
    
    //Data
    
    //TODO: these aren't strings!
    private let recentsArr: [String] = []
    private let friendsArr: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.redColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

