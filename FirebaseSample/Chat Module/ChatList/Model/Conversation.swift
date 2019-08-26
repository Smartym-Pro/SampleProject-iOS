//
//  Conversation.swift
//  FirebaseSample
//
//  Created by Pavel H on 7/12/19.
//  Copyright © 2019 smartum.pro. All rights reserved.
//

import Foundation
class Conversation {
    let nickname: String!
    let userId: String!
    let roomToken: String!
    let timestamp: Date!
    var lastMessage: Message?
    var user: User?
    init(dictionary: [String: AnyHashable], roomToken: String) {
        let interlocutor = dictionary["interlocutor"] as? [String: String]
        let timestamp = dictionary["timestamp"] as? Int64
        self.timestamp = Date.init(milliseconds: abs(timestamp ?? 0))
        self.nickname = interlocutor?["nickname"] ?? ""
        self.userId = interlocutor?["user_id"] ?? ""
        
        if let messageDictionary = dictionary["last_message"] as? [String: AnyHashable] {
            self.lastMessage = Message.init(dictionary: messageDictionary)
        }
        self.roomToken = roomToken
    }
}

extension Conversation {
    static func convertToServer(sender: User, timestamp: Date, lastMessage: Message?) -> [String: Any] {
        var dictionary: [String: Any] = ["timestamp": (0 - timestamp.millisecondsSince1970)]
        let interlocutor = ["nickname": sender.userName, "user_id": sender.userId]
        dictionary["interlocutor"] = interlocutor
        if let message = lastMessage {
            var messageDictionary: [String: Any] = ["author_id": message.author, "timestamp": (0 - message.timestamp.millisecondsSince1970)]
            if let text = message.text {
                messageDictionary["text"] = text
            }
            if let image = message.image {
                messageDictionary["image"] = image
            }
            dictionary["last_message"] = messageDictionary
        }
        return dictionary
    }
}
