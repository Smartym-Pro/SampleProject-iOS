//
//  CreateConversationController.swift
//  FirebaseSample
//
//  Created by Pavel H on 7/9/19.
//  Copyright © 2019 smartum.pro. All rights reserved.
//

import UIKit

class CreateConversationController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    weak var provider: ConversationsProvider?
 
    @IBAction func createConversation(_ sender: Any) {
        let userName = userNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard userName != nil, userName!.count > 0 else { return }
        self.showProgressHUD()
        UsersProvider.shared.getUserWith(nickName: userName!) { (user) in
            self.hideProgressHUD()
            if user != nil {
                self.createConversation(with: user!)
            } else {
                self.showError("Seems that there is no user with such nickname")
            }
        }
    }
    
    func createConversation(with user: User) {
        ConversationsProvider().getOrCreateConversation(with: user, completion: { (conversation) in
            if conversation != nil {
                self.performSegue(withIdentifier: "openChat", sender: (conversation, user))
            } else {
                 self.showError("Something became wrong. Please try again")
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ChatController, let data = sender as? (Conversation,User) {
            vc.viewModel.conversation = data.0
            vc.viewModel.user = data.1
        }
    }
}
