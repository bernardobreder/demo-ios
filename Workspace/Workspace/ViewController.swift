//
//  ViewController.swift
//  Workspace
//
//  Created by Bernardo Breder on 14/02/16.
//  Copyright © 2016 breder. All rights reserved.
//

import UIKit

struct Node {
    
}

class ViewController: UIViewController {
    
    var menuView: UIView!
    
    var listView: UIView!
    
    override func loadView() {
        
        let code: String = "int a(1) = 1;"

        let size: CGSize = UIScreen.main.bounds.size
        view = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        view.backgroundColor = UIColor.black
        
        menuView = UIView(frame: rectMenuView());
        menuView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        view.addSubview(menuView);
        
        listView = UIView(frame: rectListView());
        listView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        view.addSubview(listView);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if let menuView: UIView = self.menuView {
            menuView.frame = self.rectMenuView()
        }
        if let listView: UIView = self.listView {
            listView.frame = self.rectListView()
        }
    }
    
    func rectMenuView() -> CGRect {
        let size: CGSize = UIScreen.main.bounds.size
        if size.width > size.height {
            return CGRect(x: 0, y: 0, width: 100, height: size.height)
        } else {
            return CGRect(x: 0, y: 0, width: 0, height: size.height)
        }
    }
    
    func rectListView() -> CGRect {
        let size: CGSize = UIScreen.main.bounds.size
        if size.width > size.height {
            return CGRect(x: 100, y: 0, width: 400, height: size.height)
        } else {
            return CGRect(x: 0, y: 0, width: 0, height: size.height)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
}

