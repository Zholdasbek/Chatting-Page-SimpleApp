//
//  LibraryImageCell.swift
//  FinalProject
//
//  Created by Zholdas on 4/7/19.
//  Copyright © 2019 Zholdas. All rights reserved.
//

import UIKit


class LibraryImagesCell: UICollectionViewCell {
    
    var libraryImages: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .red
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var playVideoButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "play-image") as UIImage?
        button.setImage(image, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.clipsToBounds = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(libraryImages)
        
        libraryImages.addSubview(playVideoButton)
        
        libraryImages.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        playVideoButton.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(25)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
