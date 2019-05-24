//
//  AddCommentViewController.swift
//  FinalProject
//
//  Created by Zholdas on 4/3/19.
//  Copyright © 2019 Zholdas. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class AddCommentViewController: UIViewController , UITextViewDelegate , UINavigationControllerDelegate, KeyboardObserving{
    
    let messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let darkView: UIView = {
        let view = UIView()
        view.backgroundColor = .black

        view.alpha = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var sendMessageButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "sendButtonImage") as UIImage?
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        return button
    }()
    
    lazy var playVideoButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "play-image") as UIImage?
        button.setImage(image, for: .normal)
        button.layer.cornerRadius = 35
        button.layer.masksToBounds = true
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(videoOpen), for: .touchUpInside)
        return button
    }()
    
    lazy var messageTextView: UITextView = {
        let textView = UITextView()
        textView.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 12
        textView.text = "Enter message..."
        textView.textColor = UIColor.lightGray
        textView.sizeToFit()
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 18)
        textView.delegate = self
        return textView
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "x") as UIImage?
        let tintedImage = image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapCancelButton(_:)), for: .touchUpInside)
        return button
    }()
    
    var bottomConstraint: NSLayoutConstraint?
    
    let viewModel = ViewModel()

    var getVideoUrl: NSURL?

    override func viewDidLoad() {
        super.viewDidLoad()
        
            if getVideoUrl != nil {
                playVideoButton.isHidden = false
            }
            else{
                playVideoButton.isHidden = true
            }
        setupView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        addObservers()
        
        bottomConstraintForContainerView()
    }
    
    @objc func videoOpen(){
        let player = AVPlayer(url: getVideoUrl! as URL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }
    
    private func setupView(){
        
        view.addSubview(messageImageView)
        view.addSubview(playVideoButton)
        view.addSubview(containerView)
        view.addSubview(cancelButton)
        
        view.backgroundColor = .black
        
        navigationController?.isNavigationBarHidden = true
        
        messageImageView.addSubview(darkView)
        

        containerView.addSubview(sendMessageButton)
        containerView.addSubview(messageTextView)
        
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.left.equalTo(view.safeAreaLayoutGuide).offset(15)
            make.width.height.equalTo(20)
        }
        
        darkView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        playVideoButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(70)
            make.centerX.centerY.equalToSuperview()
            
        }
        
        messageImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        containerView.snp.makeConstraints { (make) in
            make.top.equalTo(messageTextView.snp.top).offset(-5)
            
            make.width.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        sendMessageButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.bottom.equalTo(containerView.snp.bottom).offset(-10)
            make.right.equalTo(containerView.snp.right).offset(-8)
        }
        
        messageTextView.snp.makeConstraints { (make) in
            make.bottom.equalTo(containerView.snp.bottom).offset(-5)
            make.left.equalTo(containerView.snp.left).offset(20)
            make.right.equalTo(sendMessageButton.snp.left).offset(-8)
            make.height.equalTo(38)
        }
        
        
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    @objc private func didTapCancelButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    @objc func bottomConstraintForContainerView() {

        bottomConstraint = NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: -10)

        view.addConstraint(bottomConstraint!)
    }

    
    func keyboardWillShow(withHeight height: CGFloat) {
        bottomConstraint?.constant = height
        darkView.alpha = 0.5
        cancelButton.tintColor =  UIColor(white: 0.75, alpha: 1)

        UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                            self.view.layoutIfNeeded()
                        })
    }
    
    func keyboardWillHide() {
        bottomConstraint?.constant = 0
        darkView.alpha = 0.1
        playVideoButton.tintColor =  .white
        cancelButton.tintColor =  .white

        UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func textViewDidChange(_ textView: UITextView) {

        sendMessageButton.isEnabled = !textView.text.isEmpty || (textView.text == "Enter message...")

        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)

        // MARK: set maximum line to textview for scroll
        
        let numLines = (Int(textView.contentSize.height) / Int((textView.font?.lineHeight)!))
        
        if numLines < 5{

            textView.isScrollEnabled = false
            textView.constraints.forEach { (constraint) in
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height}
            }
        }
        else{
            textView.isScrollEnabled = true
        }
    }
    
    
    // MARK: textview placeholder
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter message..."
            textView.textColor = UIColor.lightGray
        }
    }

    @objc func sendMessage(){
        var messageText = ""
        
        if messageTextView.text == "Enter message..."{
            messageText = ""
        }
        else {
            messageText = messageTextView.text
        }
        
        
        let image = messageImageView.image
        let imageData = image!.jpegData(compressionQuality: 1)
        
        do{
            
            let directoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            
            let imageName = Date().description + "--image"
            
            let path = directoryURL.appendingPathComponent(imageName)
            
            let videoUrl = getVideoUrl?.path
            
            if videoUrl != nil {
                viewModel.sendMessageWithText(text: messageText, isSender: true, imageURL: nil, videoURL: videoUrl)
            }
            else {
                try imageData?.write(to: path)
                viewModel.sendMessageWithText(text: messageText, isSender: true, imageURL: imageName, videoURL: nil)
            }
        }
        catch {
            print(error)
        }
        let vc  = ChatViewController.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

