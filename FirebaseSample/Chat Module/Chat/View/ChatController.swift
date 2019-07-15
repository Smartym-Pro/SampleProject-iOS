//
//  ChatController.swift
//  FirebaseSample
//
//  Created by Pavel H on 7/10/19.
//  Copyright © 2019 smartum.pro. All rights reserved.
//

import UIKit
import SimpleImageViewer
extension UIButton {
    func setEnabled(_ enabled: Bool) {
        alpha = enabled ? 1 : 0.5
        isEnabled = enabled
    }
}

class ChatController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var placeholderTextView: UITextView!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var inputViewHeight: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    private let dateFormatter = DateFormatter()
    private let maxNumberOfInputLines = CGFloat(7)

    lazy var viewModel: ChatViewModel = {
        return ChatViewModel(delegate: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputTextView.textContainerInset = .init(top: 12, left: 20, bottom: 12, right: 20)
        inputTextView.scrollIndicatorInsets = .init(top: 12, left: 0, bottom: 12, right: 0)
        placeholderTextView.textContainerInset = inputTextView.textContainerInset
        sendButton.setEnabled(false)
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "dd MMMM HH:mm", options: 0, locale: Locale.current)
        self.title = viewModel.user.userName
        tableView.estimatedRowHeight = ceil((tableView.bounds.width - 16 - 100) * 9/16)
        tableView.rowHeight = UITableView.automaticDimension
        addKeyboardObserverse()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getMessages()
    }
    
    private func addKeyboardObserverse() {
        NotificationCenter.default.addObserver(self, selector: #selector(animateWithKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(animateWithKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @IBAction func addAttachment(_ sender: Any) {
        self.view.endEditing(false)
        let vc = UIAlertController(title: "Add photo", message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Take photo", style: .default) { (action) in
            self.choosePhoto(.camera)
        }
        let galery = UIAlertAction(title: "Gallery", style: .default) { (action) in
            self.choosePhoto(.photoLibrary)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        vc.addAction(camera)
        vc.addAction(galery)
        vc.addAction(cancel)
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func sendAction(_ sender: Any) {
        let message = Message(author: DataManager.shared.userId!, timestamp: Date(), text: inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines), image: nil)
        self.inputTextView.text = ""
        self.sendButton.setEnabled(false)
        viewModel.sendMessage(message)
        _ = self.textView(inputTextView, shouldChangeTextIn: .init(location: 0, length: 0), replacementText: "")
    }
    
    @IBAction func hideKeyboard(_ sender: Any) {
        self.view.endEditing(false)
    }
    
    func choosePhoto(_ type: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController.init()
        picker.sourceType = type
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func uploadImageAndSend(_ image: UIImage) {
        self.showProgressHUD()
        viewModel.uploadImage(image) { (url) in
            self.hideProgressHUD()
            if url != nil {
                let message = Message(author: DataManager.shared.userId!, timestamp: Date(), text: nil, image: url!.absoluteString)
                self.viewModel.sendMessage(message)
            }
        }
    }
    
    func scrollToBottom(animate: Bool) {
        DispatchQueue.main.async {
            if self.viewModel.messages.isEmpty == false {
                let indexPath = IndexPath(item: self.tableView.numberOfRows(inSection: 0) - 1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animate)
            }
        }
    }
    
    private var keyboardIsShown = false
    
    @objc func animateWithKeyboard(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let moveUp = (notification.name == UIResponder.keyboardWillShowNotification)
        
        let distance = moveUp ? keyboardHeight : 0
        guard keyboardIsShown != moveUp else { return }
        UIView.performWithoutAnimation {
            self.view.layoutMargins.bottom = distance
        }
        let currentOffset = tableView.contentOffset
        let keyboardOffset = (keyboardHeight - self.view.safeAreaInsets.bottom)*(moveUp ? 1: -1)
        var resultOffset = currentOffset.y + keyboardOffset < 0 ? 0 : currentOffset.y + keyboardOffset
        if tableView.contentSize.height <= resultOffset{
            resultOffset = 0
        } else if tableView.contentSize.height <= tableView.bounds.height && moveUp{
            resultOffset = keyboardOffset - (tableView.bounds.height - tableView.contentSize.height)
        }
        let options = UIView.AnimationOptions(rawValue: curve << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.keyboardIsShown = moveUp
            self.view.layoutIfNeeded()
            self.tableView.setContentOffset(CGPoint(x: 0, y: resultOffset), animated: false)
        }, completion: nil)
    }

    

}
extension ChatController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = viewModel.messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatCell
        cell.message = message
        cell.delegate = self
        cell.messageLabel.text = message.text
        if let text = message.text {
            cell.messageTextContainer.isHidden = false
            cell.messageLabel.text = text
        } else {
            cell.messageTextContainer.isHidden = true
        }
        if let image = message.image, let url = URL(string: image) {
            cell.messageImageViewContainer.isHidden = false
            cell.messageImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "imagePlaceholder"), options: .highPriority, context: nil)
        } else {
            cell.messageImageViewContainer.isHidden = true
        }
        cell.dateLabel.text = dateFormatter.string(from: message.timestamp)
        cell.setOutgoing(message.isOutgoing())
        return cell
    }
}

extension ChatController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var string = (textView.text as NSString).replacingCharacters(in: range, with: text)
        placeholderTextView.isHidden = string.count > 0
        let maxTextViewHeight = maxNumberOfInputLines * textView.font!.lineHeight + textView.textContainerInset.top + textView.textContainerInset.bottom
        let currentHeight = string.height(withConstrainedWidth: textView.textContainer.size.width - (textView.textContainer.lineFragmentPadding * 2), font: textView.font!) + textView.textContainerInset.top + textView.textContainerInset.bottom
        if ceil(currentHeight) > ceil(maxTextViewHeight) {
            textView.isScrollEnabled = true
            inputViewHeight.constant = maxTextViewHeight
        } else {
            textView.isScrollEnabled = false
            inputViewHeight.constant = currentHeight
        }
        string = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if string.isEmpty {
            sendButton.setEnabled(false)
        } else {
            sendButton.setEnabled(true)
        }
        return true
    }
}
extension ChatController: ChatViewModelDelegate {
    func messageDidSend(success: Bool) {
        if !success {
            self.showError("Something became wrong")
        }
    }
    
    func messagesDidStartUpdating() { }
    
    func messagesDidReceived() {
        tableView.reloadData()
        scrollToBottom(animate: false)
    }
}


extension ChatController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        uploadImageAndSend(image)
        
    }
}
extension ChatController: ChatCellDelegate {
    func didSelectMessage(message: Message, cell: ChatCell?) {
        guard let cell = cell else { return }
        let configuration = ImageViewerConfiguration { config in
            config.imageView = cell.messageImageView
        }
        let imageViewerController = ImageViewerController(configuration: configuration)
        present(imageViewerController, animated: true)
    }
}

extension ChatController: UINavigationControllerDelegate { }


