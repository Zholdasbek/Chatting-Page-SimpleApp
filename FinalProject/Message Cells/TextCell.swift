

import UIKit
import SnapKit

protocol CanSetTime: class {
    var messageTime: UILabel { get set }
    func setTime(date: Date)
}

extension CanSetTime {
    func setTime(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        let elapsedTimeInSeconds = NSDate().timeIntervalSince(date as Date)
        
        let secondInDays: TimeInterval = 60 * 60 * 24
        
        if elapsedTimeInSeconds > 7 * secondInDays{
            dateFormatter.dateFormat = "dd/MM/yy"
        }else if elapsedTimeInSeconds > secondInDays{
            dateFormatter.dateFormat = "EEE"
        }
        
        messageTime.text = dateFormatter.string(from: date as Date)
    }
}


class TextCell: BaseCell, CanSetTime {
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.text = "Sample Message"
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isScrollEnabled = false
        return textView
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

    
    static let grayBubbleImage = UIImage(named: "bubble_gray")!.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)

    static let blueBubbleImage = UIImage(named: "bubble_blue")!.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)

    let bubbleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = TextCell.grayBubbleImage
        imageView.tintColor = UIColor(white: 0.90, alpha: 1)
        return imageView
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(textBubbleView)
        addSubview(messageTextView)
        addSubview(profileImageView)
        textBubbleView.addSubview(bubbleImageView)
        textBubbleView.addSubview(messageTime)

        
        profileImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.leading.equalToSuperview().offset(5)
            make.bottom.equalToSuperview()
        }
        

        messageTime.snp.makeConstraints { (make) in
            make.bottom.equalTo(messageTextView.snp.bottom).offset(5)
            make.right.equalTo(messageTextView.snp.right).offset(-15)
            make.height.equalTo(20)
        }


        bubbleImageView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.top.equalTo(textBubbleView)
        }
        
    }
    
    func setFrameForTextMessage(isSender: Bool, estimatedFrame: CGRect, viewFrame: CGRect) {
        if !isSender {
            
            messageTextView.frame = CGRect(x: 48 + 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
            textBubbleView.frame = CGRect(x: 48 - 10, y: -4, width: estimatedFrame.width + 16 + 8 + 16, height: estimatedFrame.height + 20 + 10)
            
            profileImageView.isHidden = false
            
            bubbleImageView.tintColor = UIColor(white: 0.90, alpha: 1)
            messageTextView.textColor = .black
            messageTime.textColor = .gray
            bubbleImageView.image =  TextCell.grayBubbleImage
        }
        else {
            messageTextView.frame = CGRect(x: viewFrame.width - estimatedFrame.width - 40, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
            
            if estimatedFrame.width <= 45 {
                textBubbleView.frame = CGRect(x: viewFrame.width - estimatedFrame.width - 40  - 58, y: -4, width: estimatedFrame.width + 24 + 58, height: estimatedFrame.height + 30)
            }
            else{
                textBubbleView.frame = CGRect(x: viewFrame.width - estimatedFrame.width - 40 - 10, y: -4, width: estimatedFrame.width + 24 + 10, height: estimatedFrame.height + 30)
            }
            
            profileImageView.isHidden = true
            
            bubbleImageView.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
            messageTextView.textColor = .white
            messageTime.textColor = UIColor(white: 0.80, alpha: 1)
            bubbleImageView.image =  TextCell.blueBubbleImage
        }
    }
    
}
