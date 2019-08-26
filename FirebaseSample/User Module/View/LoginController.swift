//
//  LoginController.swift
//  FirebaseSample
//
//  Created by Pavel H on 7/5/19.
//  Copyright © 2019 smartum.pro. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginController: UIViewController {
    
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordLabel: UILabel!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func login(_ sender: UIButton) {
        guard isValidCredentials() else { return }
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error == nil {
                self.performSegue(withIdentifier: "editProfile", sender: nil)
            } else {
                self.showError(error?.localizedDescription)
            }
        }
    }
    
    @IBAction private func register(_ sender: UIButton) {
        guard isValidCredentials() else { return }
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if error == nil {
                self.performSegue(withIdentifier: "editProfile", sender: nil)
            } else {
                self.showError(error?.localizedDescription)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditProfileController {
            vc.state = .newProfile
        }
    }
    
    private func isValidCredentials() -> Bool {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return false }
        guard email.trimmingCharacters(in: .whitespacesAndNewlines).count > 0, password.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 else { return false }
        return true
    }
    
    @IBAction private func hideKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
}
