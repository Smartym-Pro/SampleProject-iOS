//
//  UsersProvider.swift
//  FirebaseSample
//
//  Created by Pavel H on 7/8/19.
//  Copyright © 2019 smartum.pro. All rights reserved.
//

import Foundation
import Firebase

protocol UsersProviderDelegate: class {
    func getUsers(with nickName: String)
}
class UsersProvider {
    
    weak var delegate: UsersProviderDelegate?
    var userReference: DatabaseReference!
    var nicknameReference: DatabaseReference!
    static let shared = UsersProvider()
    init() {
        userReference = Database.database().reference().child("users")
        nicknameReference = Database.database().reference().child("nicknames")
    }
    
    func getUserWith(id: String, completion: @escaping (User?) -> Void) {
        userReference.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
                var nickname: String?
                var imageURL: URL?
                for child in children {
                    guard let string = child.value as? String else {
                        completion(nil)
                        return
                    }
                        if child.key == "image" {
                            imageURL = URL(string: string)
                        } else if child.key == "nickname" {
                            nickname = string
                        }
                }
                guard nickname != nil else {
                    completion(nil)
                    return
                }
                let user = User(userName: nickname!, userId: id, image: imageURL)
                completion(user)
            } else {
                completion(nil)
            }
        }
    }
    
    func getUserWith(nickName: String, completion: @escaping (User?) -> Void) {
        let userQuery = userReference.queryOrdered(byChild: "nickname")
        userQuery.queryEqual(toValue: nickName).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
                guard let child = children.first else { return }
                guard let dictionary = child.value as? [String: AnyHashable], let nickname = dictionary["nickname"] as? String else {
                    completion(nil)
                    return
                }
                var image: URL?
                if let stringURL = dictionary["image"] as? String {
                    image = URL(string: stringURL)
                }
                completion(User(userName: nickname, userId: child.key, image: image))
            } else {
                completion(nil)
            }
        }
    }
    
    func getUsers(for ids: [String], completion: @escaping ([User]) -> Void) {
        var users = [User]()
        var totalCount = ids.count
        for identifier in ids {
            getUserWith(id: identifier) { (user) in
                if user != nil {
                    users.append(user!)
                    if users.count == totalCount {
                        completion(users)
                    }
                } else {
                    totalCount -= 1
                }
            }
        }
    }
    
    func updateNickname(nickname: String, previousNickname: String?, completion: @escaping (Bool) -> Void) {
        nicknameReference.child(nickname).setValue(true) { (error: Error?, ref: DatabaseReference) in
            if error != nil {
                completion(false)
            } else if previousNickname != nil {
                self.removeNickname(nickname: previousNickname!, completion: completion)
            } else {
                completion(true)
            }
        }
    }
    
    func removeNickname(nickname: String, completion: @escaping (Bool) -> Void) {
        nicknameReference.child(nickname).removeValue() { (error: Error?, ref: DatabaseReference) in
            completion(true)
        }
    }
    
    func updateUser(user: User, completion: @escaping (Error?) -> Void) {
        var userDictionary = ["nickname": user.userName]
        if let image = user.image?.absoluteString {
            userDictionary["image"] = image
        }
        userReference.child(user.userId).setValue(userDictionary) { (error: Error?, ref: DatabaseReference) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
}
