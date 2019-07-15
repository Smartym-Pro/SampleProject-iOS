//
//  ChatListViewModel.swift
//  FirebaseSample
//
//  Created by Pavel H on 7/12/19.
//  Copyright © 2019 smartum.pro. All rights reserved.
//

import Foundation

protocol ChatListViewModelDelegate: class {
    func conversationsDidStartUpdating()
    func conversationsDidReceived()
    func usersDidFinishFetching()
}

class ChatListViewModel {
    
    weak var delegate: ChatListViewModelDelegate?
    var conversations = [Conversation]()
    var users = [String: User]()
    
    fileprivate var provider: ConversationsProvider!
    
    init(delegate: ChatListViewModelDelegate) {
        self.delegate = delegate
        provider = ConversationsProvider(delegate: self)
    }
    func getConversations() {
        provider.getConversations()
    }
}

extension ChatListViewModel: ConversationsProviderDelegate {
    func conversationsDidStartFetching() {
        delegate?.conversationsDidStartUpdating()
        
    }
    func conversationsDidFinishFetching(conversations: [Conversation]) {
        self.conversations = conversations
        delegate?.conversationsDidReceived()
        let usersIds = conversations.compactMap{ $0.userId }
        fetchUsers(ids: usersIds)
    }
}

extension ChatListViewModel {
    func fetchUsers(ids: [String]) {
        UsersProvider.shared.getUsers(for: ids) { (users) in
            _ = users.map{ self.users[$0.userId] = $0 }
            self.delegate?.usersDidFinishFetching()
        }
    }
}
