//
//  ChatListController.swift
//  FirebaseSample
//
//  Created by Pavel H on 7/5/19.
//  Copyright © 2019 smartum.pro. All rights reserved.
//

import UIKit
import FirebaseAuth
import SDWebImage

class ChatListCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
}

class ChatListController: UITableViewController {

    @IBOutlet weak var settingsButton: UIBarButtonItem!
    private let dateFormatter = DateFormatter()
    private lazy var viewModel: ChatListViewModel = {
        return ChatListViewModel(delegate: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Conversations"
        tableView.tableFooterView = UIView()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "dd MMMM HH:mm", options: 0, locale: Locale.current)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getConversations()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.conversations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell") as! ChatListCell
        let conversation = viewModel.conversations[indexPath.row]
        if let url = viewModel.users[conversation.userId]?.image {
            cell.avatarImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "empty_photo"), options: .highPriority, context: nil)
        } else {
            cell.avatarImageView.image = UIImage(named: "empty_photo")
        }
        cell.nameLabel.text =  conversation.nickname
        cell.dateLabel.text = dateFormatter.string(from: conversation.timestamp)
        if let lastMessage = conversation.lastMessage {
            cell.messageLabel.isHidden = false
            if let text = lastMessage.text {
                cell.messageLabel.text = text
            } else if lastMessage.image != nil {
                cell.messageLabel.text = "🖼"
            }
        } else {
            cell.messageLabel.isHidden = true
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 77
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = viewModel.conversations[indexPath.row]
        guard let user = viewModel.users[conversation.userId] else {
            return
        }
        performSegue(withIdentifier: "openChat", sender: (conversation, user))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ChatController, let data = sender as? (Conversation, User) {
            vc.viewModel.conversation = data.0
            vc.viewModel.user = data.1
        } else if let vc = segue.destination as? EditProfileController {
            vc.state = .editProfile
        }
    }

}

extension ChatListController: ChatListViewModelDelegate {
    func conversationsDidStartUpdating() {
        self.title = "Updating..."
//        self.showProgressHUD()
    }
    
    func conversationsDidReceived() {
        self.title = "Conversations"
        self.hideProgressHUD()
        tableView.reloadData()
    }
    
    func usersDidFinishFetching() {
        tableView.reloadData()
    }
}
