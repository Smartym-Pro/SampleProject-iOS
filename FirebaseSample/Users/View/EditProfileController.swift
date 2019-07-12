//
//  EditProfileController.swift
//  FirebaseSample
//
//  Created by Pavel H on 7/8/19.
//  Copyright © 2019 smartum.pro. All rights reserved.
//

import UIKit
import FirebaseAuth
import SDWebImage
enum EditState {
    case editProfile
    case newProfile
}

class EditProfileController: UIViewController {

    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    var user: User?
    var state: EditState = .newProfile
    override func viewDidLoad() {
        super.viewDidLoad()
        getCurrentUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    func updateUI() {
        if let image = user?.image{
             avatarImageView.sd_setImage(with: image, placeholderImage: UIImage(named: "empty_photo"), options: .highPriority, context: nil)
        } else {
            avatarImageView.image = UIImage(named: "empty_photo")
        }
        userNameTextField.text =  user?.userName
        switch state {
        case .newProfile:
            confirmButton.setTitle("Strart messaging", for: .normal)
            signOutButton.isHidden = true
        case .editProfile:
            confirmButton.setTitle("Confirm", for: .normal)
            signOutButton.isHidden = false
        }
    }
    
    func getCurrentUser() {
        showProgressHUD()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UsersProvider.shared.getUserWith(id: uid) { (user) in
            DispatchQueue.main.async {
                self.hideProgressHUD()
                if user != nil {
                    self.user = user!
                    self.updateUI()
                } else {
                    self.user = User(userName: "", userId: uid, image: nil)
                }
            }
        }
    }
    
    @IBAction func avatarAction(_ sender: Any) {
        let picker = UIImagePickerController.init()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.cameraDevice = .front
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func startAction(_ sender: Any) {
        let userName = userNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard userName != nil, userName!.count > 0 else { return }
        if userName! == user?.userName {
            self.showProgressHUD()
            updateUser()
        } else {
            updateNickname(userName!)
        }
        return
    }
    
    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            DataManager.shared.signOut()
            self.performSegue(withIdentifier: "unwindLogin", sender: nil)
        } catch {
            self.showError("Something became wrong. Please try again")
            self.performSegue(withIdentifier: "unwindLogin", sender: nil)
        }
    }
    
    func updateUser() {
        guard let user = self.user else {
            self.hideProgressHUD()
            return
        }
        UsersProvider.shared.updateUser(user: user) { (error) in
            self.hideProgressHUD()
            if error != nil {
                self.showError("Something became wrong. Please try again")
            } else {
                DataManager.shared.setCurrentUser(user)
                self.performSegue(withIdentifier: "unwindLogin", sender: nil)
            }
        }
    }
    
    func updateNickname(_ nickname: String) {
        self.showProgressHUD()
        let previousName = user?.userName != "" ? user?.userName : nil
        UsersProvider.shared.updateNickname(nickname: nickname, previousNickname: previousName ) { (success) in
            DispatchQueue.main.async {
                if !success {
                    self.hideProgressHUD()
                    self.showError("This nickname appears to be already taken. Try to use another one")
                } else {
                    self.user?.userName = nickname
                    self.updateUser()
                }
            }
        }
    }

    func uploadAvatar(avatar: UIImage) {
        avatarImageView.image = avatar
        avatarImageView.alpha = 0.5
        self.showProgressHUD()
        FilesStorage.shared.uploadImage(image: avatar, path: ImagesPath.avatarPath(), name: UUID().uuidString) { (url) in
            self.hideProgressHUD()
            guard let url = url else {
                self.avatarImageView.image = nil
                return
            }
            self.avatarImageView.alpha = 1
            self.user?.image = url
            self.updateUI()
        }
    }
}

extension EditProfileController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        uploadAvatar(avatar: image)
        
    }
}
extension EditProfileController: UINavigationControllerDelegate { }
