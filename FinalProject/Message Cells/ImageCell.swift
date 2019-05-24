//
//  ImageCell.swift
//  FinalProject
//
//  Created by Zholdas on 4/3/19.
//  Copyright © 2019 Zholdas. All rights reserved.
//

import UIKit

protocol ImageCellDelegate: class{
    func getRemoteURL(_ cell: ImageCell) -> (String?, Bool)
    func didFinishDownloading(withLocalURL url: String?, in cell: ImageCell)
}

class ImageCell: BaseCell , CanSetTime{
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.text = "Sample Message"
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isScrollEnabled = false
        return textView
    }()
    
    let messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    let textBubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var messageTime: UILabel = {
        let textView = UILabel()
        textView.font = UIFont.italicSystemFont(ofSize: 12)
        textView.text = "00:00 pm"
        textView.textAlignment = .right
        textView.backgroundColor = .clear
        return textView
    }()
    
//    lazy var loadImageButton: UIButton = {
//        let button = UIButton()
//        button.backgroundColor = .white
//        button.layer.cornerRadius = 25
//        button.layer.masksToBounds = true
//        button.clipsToBounds = true
//        button.addTarget(self, action: #selector(openFile), for: .touchUpInside)
//        return button
//    }()
    
    lazy var loadButtonBackgroudView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 25
        let tap = UITapGestureRecognizer(target: self, action: #selector(openFile))
        tap.numberOfTapsRequired = 1
        view.addGestureRecognizer(tap)
        return view
    }()
    
    lazy var loadImageButton: IconAnimation = {
        let view = IconAnimation()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    let progressView: ProgressAnimationView = {
        let view = ProgressAnimationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()
    
    var startDownloading = true
    
    static let grayBubbleImage = UIImage(named: "bubble_gray")!.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    
    static let blueBubbleImage = UIImage(named: "bubble_blue")!.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    
    let bubbleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = TextCell.grayBubbleImage
        imageView.tintColor = UIColor(white: 0.90, alpha: 1)
        return imageView
    }()
    
    weak var delegate: ImageCellDelegate?
    
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    let downloader = FileDownloader()
    
    @objc func openFile(){
        downloader.delegate = self
        guard let remoteURL = delegate?.getRemoteURL(self) else { return }
        
        if !remoteURL.1{
            if startDownloading{
                startDownloading = !startDownloading
                progressView.progressLayer.isHidden = false
                downloader.beginDownloadingFile(isDownloading: true, randomRemoteUrl: remoteURL.0)
                progressView.startCurvedCircleAnimation()
                loadImageButton.animateTopToBottom()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.loadImageButton.frame.size.width = 0
                    self.loadImageButton.frame.size.height = 0
                    UIView.animate(withDuration: 0.3, animations: {
                        self.loadImageButton.frame.size.width += 20
                        self.loadImageButton.frame.size.height += 20
                        self.loadImageButton.resetToTop()
                    })
                    self.loadImageButton.shapeView.image = UIImage(named: "stop")
                }
                
            }
            else{
                startDownloading = !startDownloading
                DispatchQueue.main.async {
                    self.progressView.stopRotating()
                    self.downloader.beginDownloadingFile(isDownloading: false, randomRemoteUrl: nil)
                    self.progressView.updateProgress(0)
                    self.progressView.progressLayer.strokeEnd = 0.0
                    self.progressView.progressLayer.strokeStart = 0.0
                }
                progressView.progressLayer.isHidden = true
                self.loadImageButton.animateBottomToTop()
                loadImageButton.shapeView.image = UIImage(named: "load")
            }
        }
    }
    
    override func setupViews() {
        super.setupViews()

        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(textBubbleView)
        addSubview(messageTextView)
        addSubview(messageImageView)
        addSubview(profileImageView)
        
        textBubbleView.addSubview(bubbleImageView)
        textBubbleView.addSubview(messageTime)
        messageImageView.addSubview(blurEffectView)

        addSubview(loadButtonBackgroudView)
        addSubview(loadImageButton)
        addSubview(progressView)
        
        blurEffectView.snp.makeConstraints { (make) in
            make.edges.equalTo(messageImageView)
        }
        
        progressView.snp.makeConstraints { (make) in
            make.height.width.equalTo(45)
            make.centerX.equalTo(loadImageButton)
            make.centerY.equalTo(loadImageButton)

        }
        
        loadImageButton.snp.makeConstraints { (make) in
            make.height.width.equalTo(20)
            make.centerX.equalTo(messageImageView)
            make.centerY.equalTo(messageImageView)
        }
        
        loadButtonBackgroudView.snp.makeConstraints { (make) in
            make.height.width.equalTo(50)
            make.centerX.equalTo(messageImageView)
            make.centerY.equalTo(messageImageView)
        }
        
        profileImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.leading.equalToSuperview().offset(5)
            make.bottom.equalToSuperview()
        }
        
        
        messageTime.snp.makeConstraints { (make) in
            make.bottom.equalTo(textBubbleView.snp.bottom).offset(-2)
            make.right.equalTo(textBubbleView.snp.right).offset(-20)
            make.height.equalTo(20)
        }
        
        
        bubbleImageView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.top.equalTo(textBubbleView)
        }
        
    }
   
    func setFrameForImageVideoMessage(isSender: Bool, estimatedFrame: CGRect, viewFrame: CGRect, messageText: String) {
        
        if !isSender {
            messageTextView.frame = CGRect(x: 48 + 8 , y: 220, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
            messageImageView.frame = CGRect(x: 48 + 9, y: 0, width: 216, height: 220)
            textBubbleView.frame = CGRect(x: 48 - 10, y: -10, width: 200 + 48, height: 200 + 54 + estimatedFrame.height)            
            profileImageView.isHidden = false
            bubbleImageView.tintColor = UIColor(white: 0.90, alpha: 1)
            messageTextView.textColor = .black
            messageTime.textColor = .gray
            bubbleImageView.image =  TextCell.grayBubbleImage
        }

       else {
            messageTextView.frame = CGRect(x: viewFrame.width - estimatedFrame.width - 40, y: 220, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)

            //MARK: Set certain lenght if background view lenght of less than text lenght
            if estimatedFrame.width <= 235{
                messageImageView.frame = CGRect(x: viewFrame.width - 200 - 50, y: 0, width: 200 + 16, height: 200 + 20)

                if messageText == "" {
                    textBubbleView.frame = CGRect(x: viewFrame.width - 200 - 40 - 20, y: -10, width: 200 + 44, height: estimatedFrame.height +  230)
                }
                else{
                    textBubbleView.frame = CGRect(x: viewFrame.width - 200 - 40 - 20, y: -10, width: 200 + 44, height: estimatedFrame.height +  257)
                }

            }
            else {
                messageImageView.frame = CGRect(x: viewFrame.width - estimatedFrame.width - 18, y: 0, width: 200 + 16, height: 200 + 20)
                textBubbleView.frame = CGRect(x: viewFrame.width - estimatedFrame.width - 40 - 4, y: -10, width: estimatedFrame.width + 28, height: estimatedFrame.height +  257)
            }
            profileImageView.isHidden = true

            bubbleImageView.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
            messageTextView.textColor = .white
            messageTime.textColor = UIColor(white: 0.80, alpha: 1)
            bubbleImageView.image =  TextCell.blueBubbleImage
        }
    }
}

extension ImageCell: FileDownloaderDelegate {
    func sendPogress(progress: CGFloat) {
        DispatchQueue.main.async {
            self.progressView.updateProgress(Float(progress))
        }
    }
    
    func didFinished(url: String?) {
        DispatchQueue.main.async {
            self.startDownloading = true
            self.progressView.isHidden = true
            self.loadImageButton.isHidden = true
            self.blurEffectView.isHidden = true
            self.progressView.updateProgress(0)
            self.progressView.stopRotating()
            self.loadImageButton.shapeView.image = UIImage(named: "load")
            self.delegate?.didFinishDownloading(withLocalURL: url, in: self)
        }
        

    }
}
