//
//  FilesStorage.swift
//  FirebaseSample
//
//  Created by Pavel H on 7/8/19.
//  Copyright © 2019 smartum.pro. All rights reserved.
//

import Foundation
import Firebase
import UIKit
import FirebaseStorage
import FirebaseAuth

//enum ImagesPath: String {
//    case avatar = "images/avatars/"
//    case conversation = "images/conversation/"
//}

struct ImagesPath {
    static func avatarPath() -> String {
        return "images/avatars/"
    }
    static func conversationPath(_ conversationId: String ) -> String {
        return "images/conversation/\(conversationId)/"
    }
}
class FilesStorage {
    
    static let shared = FilesStorage()
    var ref: DatabaseReference!
    
    var storage: Storage!
    
    static func initialize() {
        FilesStorage.shared.ref = Database.database().reference()
        FilesStorage.shared.storage = Storage.storage()
    }
    
    func uploadImage(image: UIImage, path: String, name: String, progress: ((Double) -> Void)? = nil, completion: @escaping (URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            completion(nil)
            return
        }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let storageRef = storage.reference()
        let avatarRef = storageRef.child(path + "\(name).jpg")
        let uploadTask = avatarRef.putData(imageData, metadata: metadata) { (metadata, error) in
            guard metadata != nil else {
                completion(nil)
                return
            }
            avatarRef.downloadURL { (url, _) in
                guard let downloadURL = url else {
                    completion(nil)
                    return
                }
                completion(downloadURL)
            }
        }
        
        uploadTask.observe(.resume) { snapshot in
            
        }
        
        uploadTask.observe(.pause) { snapshot in
            
        }
        
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            progress?(percentComplete)
        }
        
        uploadTask.observe(.success) { snapshot in
            
        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as NSError? {
                switch (StorageErrorCode(rawValue: error.code)) {
                case .objectNotFound?:
                    // File doesn't exist
                    completion(nil)
                case .unauthorized?:
                    // User doesn't have permission to access file
                    completion(nil)
                case .cancelled?:
                    // User canceled the upload
                    completion(nil)
                    
                    /* ... */
                    
                case .unknown?:
                    // Unknown error occurred, inspect the server response
                    completion(nil)
                default:
                    // A separate error occurred. This is a good place to retry the upload.
                    completion(nil)
                }
            }
        }
    }
}
