//
//  ConversationsProvider.swift
//  FirebaseSample
//
//  Created by Pavel H on 7/8/19.
//  Copyright © 2019 smartum.pro. All rights reserved.
//

import Foundation
import Firebase


protocol ConversationsProviderDelegate: class {
    func conversationsDidStartFetching()
    func conversationsDidFinishFetching(conversations: [Conversation])
}

class ConversationsProvider {
    weak var delegate: ConversationsProviderDelegate?
    
    fileprivate var provider: ConversationsProvider!
    fileprivate var currentUserConversationsReference: DatabaseReference!
    
    init(delegate: ConversationsProviderDelegate? = nil) {
        self.delegate = delegate
        currentUserConversationsReference = Database.database().reference().child("conversations")
    }

    func getConversations() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        delegate?.conversationsDidStartFetching()
        currentUserConversationsReference.child(currentUserID).queryOrdered(byChild: "timestamp").observe(.value) { (snapshot) in
            if snapshot.exists() {
              
                guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
                var conversations = [Conversation]()
                for child in children {
                    guard let dictionary = child.value as? [String: AnyHashable] else {
                        continue
                    }
                    let conversation = Conversation(dictionary: dictionary, roomToken: child.key)
                    conversations.append(conversation)
                }
                self.delegate?.conversationsDidFinishFetching(conversations: conversations)
            } else {
                self.delegate?.conversationsDidFinishFetching(conversations: [Conversation]())
            }
        }
    }
    
    func getOrCreateConversation(with user: User, completion: @escaping (Conversation?) -> ()) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        let conversationId = self.conversationId(with: currentUserId, recipientId: user.userId)
        currentUserConversationsReference.child(currentUserId).child(conversationId).queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value) { (snapshot) in
             if snapshot.exists() {
                guard let dictionary = snapshot.value as? [String : AnyHashable] else {
                    completion(nil)
                    return
                }
                completion(Conversation(dictionary: dictionary, roomToken: conversationId))
             } else {
                self.createConversation(with: DataManager.shared.getCurrentUser(), recipient: user, completion: completion)
            }
        }
    }
    
    
    func createConversation(with currentUser: User, recipient: User, completion: @escaping (Conversation?) -> ()) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        let startConversationDate = Date()
        let conversationId = self.conversationId(with: currentUserId, recipientId: recipient.userId)
        let conversationForCurrentUser = Conversation.convertToServer(sender: recipient, timestamp: startConversationDate, lastMessage: nil)
        let conversationForRecipient = Conversation.convertToServer(sender: currentUser, timestamp: startConversationDate, lastMessage: nil)
        currentUserConversationsReference.child(currentUserId).updateChildValues([conversationId: conversationForCurrentUser]) {
            (error:Error?, ref:DatabaseReference) in
            if error == nil {
                self.currentUserConversationsReference.child(recipient.userId).updateChildValues([conversationId: conversationForRecipient]) {
                    (error:Error?, ref:DatabaseReference) in
                    if error == nil {
                        let conversation = Conversation(dictionary: conversationForCurrentUser as! [String : AnyHashable], roomToken: conversationId)
                        completion(conversation)
                    } else {
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
    }
}


extension ConversationsProvider {
    func conversationId(with currentUId: String, recipientId: String) -> String {
        let ids = [currentUId, recipientId].sorted()
        return ids.joined(separator: "_")
    }
}
