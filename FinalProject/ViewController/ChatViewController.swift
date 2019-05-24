
import UIKit
import SnapKit
import CoreData
import AVFoundation
import AVKit

class ChatViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextViewDelegate , UINavigationControllerDelegate{
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var buttonSwitched : Bool = false

    var progress : CGFloat!
    
    lazy var sendMessageButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "sendButtonImage") as UIImage?
        let tintedImage = image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        return button
    }()

    lazy var selectFileButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "clip") as UIImage?
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(selectFile), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
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

    var messages: [DBMessage]?
    
    private let cellId = "cellId"
    private let cellId2 = "cellId2"
    
    var bottomConstraint: NSLayoutConstraint?

    let viewModel = ViewModel()
    let downloader = FileDownloader()
    
    var downloadingCell: ImageCell?
    
    let fileManager = FileManager.default

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(TextCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(ImageCell.self, forCellWithReuseIdentifier: cellId2)

        collectionView.reloadData()
        
        
        setupViews()

        addObservers()

        navigationItemSetup()
        
        bindViewModel()
        viewModel.clearData()
        viewModel.loadData()
        
        bottomConstraintForContainerView()
        
        

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillLayoutSubviews() {
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = messages?.count {
            return count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //MARK: Cell for text message
        if messages?[indexPath.item].localUrlOfImage == nil && messages?[indexPath.item].localUrlOfVideo == nil{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TextCell
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.messageTextView.text = messages?[indexPath.item].text
            cell.profileImageView.image = UIImage(named: "steve2")
            cell.backgroundColor = .white
            let date = messages?[indexPath.item].date
            cell.setTime(date: date! as Date)
            
            if let message = messages?[indexPath.item], let messageText = message.text {
                let size = CGSize(width: 250, height: 2000)
                let option = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
                let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: option, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], context: nil)
                
                cell.setFrameForTextMessage(isSender: message.isSender, estimatedFrame: estimatedFrame, viewFrame: view.frame)
            }
            return cell

        }
          
        //MARK: Cell for message with video and image
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId2, for: indexPath) as! ImageCell
            cell.messageTextView.text = messages?[indexPath.item].text
            cell.profileImageView.image = UIImage(named: "steve2")
            cell.backgroundColor = .white

            cell.delegate = self
            
            let urlOfImage = messages?[indexPath.item].localUrlOfImage
            let urlOfVideo = messages?[indexPath.item].localUrlOfVideo
            let isLoadedData = (messages?[indexPath.item].isFinishedLoad)!
            let isLoadingData = (messages?[indexPath.item].downloading)!
            
            if isLoadedData && !isLoadingData{
                let directoryURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]

                if urlOfImage != nil && urlOfVideo == nil {
                    cell.loadImageButton.isHidden = true
                    cell.blurEffectView.isHidden = true
                    cell.progressView.isHidden = true
                    
                    do {
                        let fullPath =  directoryURL.appendingPathComponent(urlOfImage!)
                        
                        if fileManager.fileExists(atPath: fullPath.path) {
                            let imageData = try Data(contentsOf: fullPath)
                            cell.messageImageView.image = UIImage(data: imageData)
                        }
                    } catch {
                        print("Failed to retrive IMAGE")
                    }
                }
                else if urlOfImage == nil && urlOfVideo != nil {

                    cell.loadImageButton.shapeView.image = UIImage(named: "play")
                    cell.blurEffectView.isHidden = true
                    cell.progressView.isHidden = true
                    
                    let sender = messages?[indexPath.item].isSender
                    
                    if sender! {
                        let fullPath = urlOfVideo
                        let img = videoSnapshot(filePathLocal: fullPath! as NSString)
                        cell.messageImageView.image = img
                    }
                    else {
                        let fullPath =  directoryURL.appendingPathComponent(urlOfVideo!)
                        let img = videoSnapshot(filePathLocal: fullPath.path as NSString)
                        cell.messageImageView.image = img
                    }
                    
                }
            }
            else if isLoadingData && !isLoadedData{
                cell.loadImageButton.shapeView.image = UIImage(named: "stop")
                cell.loadImageButton.isHidden = false
                cell.blurEffectView.isHidden = false
                cell.progressView.isHidden = true
                cell.messageImageView.image = nil
            }
            else {
                cell.loadImageButton.shapeView.image = UIImage(named: "load")
                cell.loadImageButton.isHidden = false
                cell.blurEffectView.isHidden = false
                cell.progressView.isHidden = false
                cell.messageImageView.image = nil
            }
            
            if let date = messages?[indexPath.item].date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm a"
                let elapsedTimeInSeconds = NSDate().timeIntervalSince(date as Date)
                let secondInDays: TimeInterval = 60 * 60 * 24
                
                if elapsedTimeInSeconds > 7 * secondInDays{
                    dateFormatter.dateFormat = "dd/MM/yy"
                }else if elapsedTimeInSeconds > secondInDays{
                    dateFormatter.dateFormat = "EEE"
                }
                cell.messageTime.text = dateFormatter.string(from: date as Date)
            }
            
            if let message = messages?[indexPath.item], let messageText = message.text {
                
                let size = CGSize(width: 250, height: 2000)
                let option = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
                let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: option, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], context: nil)
                
                cell.setFrameForImageVideoMessage(isSender: message.isSender, estimatedFrame: estimatedFrame, viewFrame: view.frame, messageText: messageText)
            }
            return cell
        }
    }
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if messages?[indexPath.item].localUrlOfImage == nil && messages?[indexPath.item].localUrlOfVideo == nil{
    
            if let messageText = messages?[indexPath.item].text {
                let size = CGSize(width: 250, height: 1000)
                let option = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
                let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: option, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], context: nil)

                return CGSize(width: view.frame.width, height: estimatedFrame.height + 30 )
            }
        return CGSize(width: view.frame.width, height:  100)
        }
        
        else{
            if let messageText = messages?[indexPath.item].text {
                let size = CGSize(width: 250, height: 1000)
                let option = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
                let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: option, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], context: nil)
                
                if messageText == ""{
                    return CGSize(width: view.frame.width, height: estimatedFrame.height + 220 )
                }
                else {
                    return CGSize(width: view.frame.width, height: estimatedFrame.height + 250 )
                }
            }
            return CGSize(width: view.frame.width, height:  240)
        }
    }
    
}

extension ChatViewController: ImageCellDelegate, KeyboardObserving {
    @objc func setupViews(){
        
        view.backgroundColor = .white
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        collectionView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        view.addSubview(containerView)

        containerView.addSubview(sendMessageButton)
        containerView.addSubview(selectFileButton)
        containerView.addSubview(messageTextView)
        
        collectionView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(containerView.snp.top)
        }
        
        containerView.snp.makeConstraints { (make) in
            make.top.equalTo(messageTextView.snp.top).offset(-5)
            make.width.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        selectFileButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.bottom.equalTo(containerView.snp.bottom).offset(-10)
            make.left.equalTo(containerView.snp.left).offset(8)
        }
        
        sendMessageButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.bottom.equalTo(containerView.snp.bottom).offset(-10)
            make.right.equalTo(containerView.snp.right).offset(-8)
        }
        
        messageTextView.snp.makeConstraints { (make) in
            make.bottom.equalTo(containerView.snp.bottom).offset(-5)
            make.left.equalTo(selectFileButton.snp.right).offset(8)
            make.right.equalTo(sendMessageButton.snp.left).offset(-8)
            make.height.equalTo(38)
        }
    }
    
    @objc func bottomConstraintForContainerView() {
        
        bottomConstraint = NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
        
        view.addConstraint(bottomConstraint!)
    }
    
    @objc func navigationItemSetup() {
        navigationItem.title = "IOS IT Lab"
        
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        let image = UIImage(named: "steve2")!
        
        UIGraphicsBeginImageContextWithOptions(button.frame.size, false, image.scale)
        let rect  = CGRect(x: 0, y: 0,width: button.frame.size.width,height: button.frame.size.height)
        UIBezierPath(roundedRect: rect, cornerRadius: rect.width/2).addClip()
        image.draw(in: rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let color = UIColor(patternImage: newImage!)
        button.backgroundColor = color
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        let imageButton = UIBarButtonItem()
        imageButton.customView = button
        navigationItem.rightBarButtonItem = imageButton
        
        
        let simulateButton = UIBarButtonItem(title: "Simulate", style: .plain, target: self, action: #selector(simulateMessage))
        navigationItem.leftBarButtonItem = simulateButton
    }
    
    
    func keyboardWillShow(withHeight height: CGFloat) {
        bottomConstraint?.constant = height
        UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    
    func videoSnapshot(filePathLocal: NSString) -> UIImage? {
        
        let vidURL = NSURL(fileURLWithPath:filePathLocal as String)
        let asset = AVURLAsset(url: vidURL as URL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
        
        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage(cgImage: imageRef)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return nil
        }
    }
    
    func keyboardWillHide() {
        bottomConstraint?.constant = 0
        collectionView.reloadInputViews()
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
    
    //MARK: Textview placeholder
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
    
    private func bindViewModel() {
        viewModel.didGetList = { [weak self] (messages) in
            self?.messages = messages
            self?.collectionView.reloadData()
        }
    }
    
    @objc func sendMessage(){
        viewModel.sendMessageWithText(text: messageTextView.text, isSender: true, imageURL: nil, videoURL: nil)
        messageTextView.text = nil
        textViewDidChange(messageTextView)
        collectionView.reloadData()
    }
    
    //MARK: Simulated message with text and photo
    @objc func simulateMessage() {
//        let array = ["https://images.unsplash.com/photo-1498462440456-0dba182e775b?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=634&q=80","https://images.unsplash.com/photo-1528459801416-a9e53bbf4e17?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=655&q=80","https://images.unsplash.com/photo-1515463138280-67d1dcbf317f?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1050&q=80","https://images.unsplash.com/photo-1519873174361-37788c5a73c7?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=588&q=80","https://images.unsplash.com/photo-1494967990034-6a28085f9ed0?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1050&q=80"]
        
        let array = ["https://firebasestorage.googleapis.com/v0/b/firestorechat-e64ac.appspot.com/o/intermediate_training_rec.mp4?alt=media&token=e20261d0-7219-49d2-b32d-367e1606500c","http://techslides.com/demos/sample-videos/small.mp4","http://clips.vorwaerts-gmbh.de/VfE_html5.mp4","https://tekeye.uk/html/images/Joren_Falls_Izu_Japan.mp4","https://media.w3.org/2010/05/sintel/trailer.mp4"]

        
//        viewModel.sendMessageWithText(text: "Hi everyone this is it laboratory of company DAR Eco systems.This program for every students which studies in speciality information systems and engineers", isSender: false, image: nil, videoURL: nil, imageURL: nil)
        
        if let randomElement = array.randomElement() {
            viewModel.sendMessageWithText(text: randomElement + NSDate().description, isSender: false, imageURL: nil, videoURL: randomElement)
        }
        
//        if let randomElement = array.randomElement() {
//            viewModel.sendMessageWithText(text: "Hi my name is Steve Jobs, Nice to meet you!" + NSDate().description, isSender: false, imageURL: randomElement, videoURL: nil)
////            collectionView.reloadData()
//        }
    }
    
    //MARK: Action sheet
    @objc func selectFile(){
        let cameraVC = CameraViewController()
        let photoLibraryVC = PhotoLibraryViewController.init(collectionViewLayout: UICollectionViewFlowLayout())
        
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let takePhoto = UIAlertAction(title: "Camera", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.navigationController?.pushViewController(cameraVC,animated: true)
        })
        let takePhotoImage = UIImage(named: "camera.png")
        takePhoto.setValue(takePhotoImage?.withRenderingMode(.alwaysOriginal), forKey: "image")

        let selectFromLibrary = UIAlertAction(title: "Photo from library", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.navigationController?.pushViewController(photoLibraryVC,animated: true)
        })
        let selectFromLibraryImage = UIImage(named: "image-library.png")
        selectFromLibrary.setValue(selectFromLibraryImage?.withRenderingMode(.alwaysOriginal), forKey: "image")

        let selectDocument = UIAlertAction(title: "Document", style: .default, handler: nil)
        let selectDocumentImage = UIImage(named: "document.png")
        selectDocument.setValue(selectDocumentImage?.withRenderingMode(.alwaysOriginal), forKey: "image")

        let sendLocation = UIAlertAction(title: "Location", style: .default, handler: nil)
        let sendLocationImage = UIImage(named: "location.png")
        sendLocation.setValue(sendLocationImage?.withRenderingMode(.alwaysOriginal), forKey: "image")

        let selectContact = UIAlertAction(title: "Contact", style: .default, handler: nil)
        let selectContactImage = UIImage(named: "contacts.png")
        selectContact.setValue(selectContactImage?.withRenderingMode(.alwaysOriginal), forKey: "image")

        let backView = actionSheet.view.subviews.last?.subviews.last
        backView?.layer.cornerRadius = 10.0
        backView?.backgroundColor = UIColor(white: 0.85, alpha: 1)

        actionSheet.addAction(takePhoto)
        actionSheet.addAction(selectFromLibrary)
        actionSheet.addAction(selectDocument)
        actionSheet.addAction(sendLocation)
        actionSheet.addAction(selectContact)

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(actionSheet, animated: true, completion: nil)

    }
    
    func getRemoteURL(_ cell: ImageCell) -> (String?, Bool)  {
        
        let index = collectionView.indexPath(for: cell)?.item
        
        let isFinishedDownload = messages?[index!].isFinishedLoad
        
        let videoUrl = messages?[index!].localUrlOfVideo
        
        let isSender = messages?[index!].isSender
        
        if isFinishedDownload! && videoUrl != nil {
            
            let directoryURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]

            let fullPath: URL?

            if isSender!{
                fullPath = URL(fileURLWithPath: videoUrl!)
            }
            else {
                fullPath = directoryURL.appendingPathComponent(videoUrl!)
            }
            
            if fileManager.fileExists(atPath: fullPath!.path) {
                let player = AVPlayer(url: fullPath!)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    playerViewController.player?.play()
                }
            }
            
            return (nil,true)
        }
        
        if messages?[index!].localUrlOfImage != nil && messages?[index!].localUrlOfVideo == nil {
            let remoteImageURL = messages?[index!].localUrlOfImage
            
//            cell.loadImageButton.shapeView.image = nil
            
            self.viewModel.updateData(index: index!, downloadedIndicator: false, loadedImageLocalUrl: remoteImageURL, loadedVideoLocalUrl: nil, isDownloading: true)

            return (remoteImageURL, isFinishedDownload!)
        }
        else if messages?[index!].localUrlOfImage == nil && messages?[index!].localUrlOfVideo != nil {
            let remoteURLVideo = messages?[index!].localUrlOfVideo
//            cell.loadImageButton.shapeView.image = nil
            
            self.viewModel.updateData(index: index!, downloadedIndicator: false, loadedImageLocalUrl: nil, loadedVideoLocalUrl: remoteURLVideo, isDownloading: true)

            return (remoteURLVideo, isFinishedDownload!)
        }
        else {
            return (nil,true)
        }
    }
    
    func didFinishDownloading(withLocalURL url: String?, in cell: ImageCell) {
        
        let directoryURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        
        let fullPath =  directoryURL.appendingPathComponent(url!)        
        
        let data = try? Data(contentsOf: fullPath)
        
        DispatchQueue.main.async {
            let index = self.collectionView.indexPath(for: cell)?.item
            let isImage = self.messages?[index!].localUrlOfImage
            let isVideo = self.messages?[index!].localUrlOfVideo
            
            if isImage != nil && isVideo == nil{
                self.viewModel.updateData(index: index!, downloadedIndicator: true, loadedImageLocalUrl: url, loadedVideoLocalUrl: nil, isDownloading: false)

                if let imageData = data {
                    let image = UIImage(data: imageData)
                    cell.messageImageView.image = image
                }
            }
            else if isImage == nil && isVideo != nil{
                self.viewModel.updateData(index: index!, downloadedIndicator: true, loadedImageLocalUrl: nil, loadedVideoLocalUrl: url, isDownloading: false)
                cell.loadImageButton.shapeView.image = UIImage(named: "play")
                cell.loadImageButton.isHidden = false                
                let img = self.videoSnapshot(filePathLocal: fullPath.path as NSString)
                cell.messageImageView.image = img                
            }

        }
        
    }
}
