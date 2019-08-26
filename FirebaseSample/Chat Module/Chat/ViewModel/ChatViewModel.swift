//
//  ChatViewModel.swift
//  FirebaseSample
//
//  Created by Pavel H on 7/12/19.
//  Copyright © 2019 smartum.pro. All rights reserved.
//

import UIKit

protocol ChatViewModelDelegate: class {
    func messagesDidStartUpdating()
    func messagesDidReceived()
    func messageDidSend(success: Bool)
}

class ChatViewModel {
    
    weak var delegate: ChatViewModelDelegate?
   
    var messages = [Message]()
    var conversation: Conversation!
    var user: User!
    var messagesProvider: MessagesProvider!
    
    init(delegate: ChatViewModelDelegate) {
        self.delegate = delegate
        messagesProvider = MessagesProvider(delegate: self)
    }
    
    func getMessages() {
        messagesProvider.observeMessages(for: conversation)
    }
    func sendMessage(_ message: Message) {
        messagesProvider.sendMessage(message, in: conversation, with: user) { (success) in
            self.delegate?.messageDidSend(success: true)
        }
    }
    
    func uploadImage(_ image: UIImage, completion: @escaping (URL?) -> Void) {
        FilesStorage.shared.uploadImage(image: image, path: ImagesPath.conversationPath(conversation!.roomToken), name: UUID().uuidString) { (url) in
            completion(url)
        }
    }
    
}
extension ChatViewModel: MessagesProviderDelegate {
    func messagesDidStartFetching() {
        delegate?.messagesDidStartUpdating()
    }
    
    func messagesDidFinishFetching(messages: [Message]?) {
        guard let messages = messages else { return }
        self.messages = messages
        delegate?.messagesDidReceived()
    }

}
