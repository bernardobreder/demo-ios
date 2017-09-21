//
//  ViewController.swift
//  BluetoothTransferData
//
//  Created by Bernardo Breder on 02/07/15.
//  Copyright (c) 2015 Bernardo Breder. All rights reserved.
//

import UIKit
import GameKit

class ViewController: UIViewController {
    
    var hostSession: MCSession?;

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSession()
        
        let notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("createSession"), name: "UIApplicationWillEnterForegroundNotification", object: nil)
        notificationCenter.addObserver(self, selector: Selector("endSession"), name: "UIApplicationDidEnterBackgroundNotification", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createSession() {
        hostSession = GKSession()
    }
    
    func endSession() {
        
    }


}

