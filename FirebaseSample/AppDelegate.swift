//
//  AppDelegate.swift
//  FirebaseSample
//
//  Created by Pavel H on 7/5/19.
//  Copyright © 2019 smartum.pro. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        FilesStorage.initialize()
        return true
    }

}
