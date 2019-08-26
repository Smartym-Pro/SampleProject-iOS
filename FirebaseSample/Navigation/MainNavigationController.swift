//
//  MainNavigationController.swift
//  FirebaseSample
//
//  Created by Pavel H on 7/5/19.
//  Copyright © 2019 smartum.pro. All rights reserved.
//

import UIKit
import FirebaseAuth

class MainNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        autentificate()
    }
    
    private func autentificate() {
        if Auth.auth().currentUser != nil && DataManager.shared.userId != nil {
            showChat()
        } else {
            showLogIn()
        }
    }
    
    private func showLogIn() {
        viewControllers = [storyboard?.instantiateViewController(withIdentifier: "LoginController") as! LoginController]
    }
    
    private func showChat() {
        viewControllers = [UIStoryboard.init(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatListController") as! ChatListController]
    }
    
    @IBAction private  func unwindLogin(_ sender: UIStoryboardSegue) {
        autentificate()
    }
}
