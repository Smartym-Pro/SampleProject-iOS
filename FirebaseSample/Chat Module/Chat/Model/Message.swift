//
//  Message.swift
//  FirebaseSample
//
//  Created by Pavel H on 7/8/19.
//  Copyright © 2019 smartum.pro. All rights reserved.
//

import Foundation

struct Message {
    let author: String
    let timestamp: Date
    let text: String?
    let image: String?
    init(dictionary: [String: AnyHashable]) {
        self.author = dictionary["author_id"] as! String
        let timestampInt = dictionary["timestamp"] as! Int64
        self.timestamp = Date.init(milliseconds: abs(timestampInt))
        self.text = dictionary["text"] as? String
        self.image = dictionary["image"] as? String
    }
    
    init(author: String, timestamp: Date, text: String?, image: String?) {
        self.author = author
        self.timestamp = timestamp
        self.text = text
        self.image = image
    }
}

extension Message {
    func isOutgoing() -> Bool {
        return DataManager.shared.userId == author
    }
    func convertToServer() -> [String: Any] {
        let message: [String: Any?] = ["author_id": author, "text": text, "image": image, "timestamp": 0 - timestamp.millisecondsSince1970]
        return message as [String: Any]
    }
}
