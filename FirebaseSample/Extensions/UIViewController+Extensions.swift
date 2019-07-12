//
//  UIViewController+Extensions.swift
//  FirebaseSample
//
//  Created by Pavel H on 7/8/19.
//  Copyright © 2019 smartum.pro. All rights reserved.
//

import UIKit
import PKHUD

extension UIViewController {
    func showProgressHUD(animated: Bool = true, onView: UIView? = nil) {
        view.endEditing(true)
        HUD.show(.systemActivity, onView: onView)
    }
    func hideProgressHUD(animated: Bool = true) {
        HUD.hide(animated: true)
    }
    
    func showError(_ message: String?) {
        let message = message ?? NSLocalizedString("Unknown error", comment: "")
        let title = NSLocalizedString("Error", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = NSLocalizedString("Ok", comment: "Alert button")
        alert.addAction(UIAlertAction(title: ok, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
