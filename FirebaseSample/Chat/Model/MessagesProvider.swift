//
//  MessagesProvider.swift
//  FirebaseSample
//
//  Created by Pavel H on 7/10/19.
//  Copyright © 2019 smartum.pro. All rights reserved.
//

import Foundation
import Firebase

protocol MessagesProviderDelegate: class {
    func messagesDidStartFetching()
    func messagesDidFinishFetching(messages: [Message]?)
}

class MessagesProvider {
    
    weak var delegate: MessagesProviderDelegate?
    fileprivate var messagesReference: DatabaseReference!
    fileprivate var currentUserConversationsReference: DatabaseReference!

    init(delegate: MessagesProviderDelegate) {
        self.delegate = delegate
        messagesReference = Database.database().reference().child("messages")
        currentUserConversationsReference = Database.database().reference().child("conversations")
    }
    
    func observeMessages(for conversation: Conversation) {
        messagesReference.child(conversation.roomToken).queryOrdered(byChild: "timestamp").observe(.value) { (snapshot) in
            if snapshot.exists() {
                guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
                    return
                }
                var messages = [Message]()
                for child in children {
                    guard let dictionary = child.value as? [String: AnyHashable] else {
                        return
                    }
                    let message = Message(dictionary: dictionary)
                    messages.append(message)
                }
                messages.reverse()
                self.delegate?.messagesDidFinishFetching(messages: messages)
            } else {
                self.delegate?.messagesDidFinishFetching(messages: nil)
            }
        }
    }

    func sendMessage(_ message: Message, in conversation: Conversation, with user: User, completion: @escaping (Bool) -> ()) {
        messagesReference.child(conversation.roomToken).updateChildValues([UUID().uuidString:message.convertToServer()]) {
            (error:Error?, ref:DatabaseReference) in
            if error == nil {
                self.updateLastMessage(message, in: conversation, with: user, completion: completion)
            } else {
                completion(false)
            }
        }
    }
    
    func updateLastMessage(_ message: Message, in conversation: Conversation, with user: User, completion: @escaping (Bool) -> ()) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        let timestamp = 0 - message.timestamp.millisecondsSince1970
        currentUserConversationsReference.child(currentUserId).child(conversation.roomToken).updateChildValues(["last_message": message.convertToServer(), "timestamp": timestamp]) {
            (error:Error?, ref:DatabaseReference) in
            if error == nil {
                self.currentUserConversationsReference.child(user.userId).child(conversation.roomToken).updateChildValues(["last_message": message.convertToServer(), "timestamp": timestamp]) {
                    (error:Error?, ref:DatabaseReference) in
                     if error == nil {
                         completion(true)
                     } else {
                         completion(false)
                    }
                   
                }
            } else {
                completion(false)

            }
        }

            
    }
    
}


