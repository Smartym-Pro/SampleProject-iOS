//
//  DataManager.swift
//  FirebaseSample
//
//  Created by Pavel H on 7/10/19.
//  Copyright © 2019 smartum.pro. All rights reserved.
//

import Foundation
let k_userId = "userId"
let k_nickname = "nickname"
let k_avatar = "avatar"

class DataManager: NSObject {
    
    static let shared = DataManager()
    func setCurrentUser(_ user: User) {
        userId = user.userId
        nickname = user.userName
        avatar = user.image
        
    }
    func getCurrentUser() -> User {
        return User(userName: nickname!, userId: userId!, image: avatar)
    }
    var userId: String? {
        get {
            return UserDefaults.standard.value(forKey: k_userId) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: k_userId)
            UserDefaults.standard.synchronize()
        }
    }
    
    var nickname: String? {
        get {
            return UserDefaults.standard.value(forKey: k_nickname) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: k_nickname)
            UserDefaults.standard.synchronize()
        }
    }
    var avatar: URL? {
        get {
            return UserDefaults.standard.value(forKey: k_avatar) as? URL
        }
        set {
            UserDefaults.standard.set(newValue, forKey: k_avatar)
            UserDefaults.standard.synchronize()
        }
    }
    
    func signOut() {
        UserDefaults.standard.removeObject(forKey: k_userId)
        UserDefaults.standard.removeObject(forKey: k_nickname)
        UserDefaults.standard.removeObject(forKey: k_avatar)
        UserDefaults.standard.synchronize()
    }
    
}
