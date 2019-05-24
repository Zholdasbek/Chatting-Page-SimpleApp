//
//  PhotoLibraryViewController.swift
//  FinalProject
//
//  Created by Zholdas on 4/3/19.
//  Copyright © 2019 Zholdas. All rights reserved.
//

import UIKit
import Photos

class PhotoLibraryViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout  {
    
    private let cellId = "cellId2"
    
    var assets: [PHAsset] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Library"
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(LibraryImagesCell.self, forCellWithReuseIdentifier: cellId)
        
        fetchImages()
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false

    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! LibraryImagesCell
        
        let asset = assets[indexPath.row]
        
        switch asset.mediaType {
        case .video:
            cell.playVideoButton.isHidden = false
        default:
            cell.playVideoButton.isHidden = true
        }
        
        asset.getImage(ofSize: CGSize(width: 200, height: 200)) { [weak cell] (image) in
            cell?.libraryImages.image = image
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = collectionView.frame.width
        
        return CGSize(width: width/4 - 1, height: width/4 - 1)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let asset = assets[indexPath.row]
        
        let vc = AddCommentViewController()
        
        if asset.mediaType == .video {
            asset.getImage(ofSize: PHImageManagerMaximumSize) { (image) in
                vc.messageImageView.image = image
            }
            
            asset.getURL(completionHandler: { (url) in
                vc.getVideoUrl = url! as NSURL
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            })
        }
        
        else if asset.mediaType == .image {
            asset.getImage(ofSize: PHImageManagerMaximumSize) { (image) in
                vc.messageImageView.image = image
                self.navigationController?.pushViewController(vc, animated: true)}
        }
    }
    
    
    func fetchImages() {
        DispatchQueue.global(qos: .background).async { [unowned self] in
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = false
            requestOptions.deliveryMode = .highQualityFormat
            requestOptions.isNetworkAccessAllowed = false
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            let fetchResult2 = PHAsset.fetchAssets(with: .video, options: fetchOptions)
            
            if fetchResult2.count > 0 {
                for i in 0..<fetchResult2.count {
                    let asset = fetchResult2.object(at: i) as PHAsset
                    self.assets.append(asset)
                }
            }
            if fetchResult.count > 0 {
                for i in 0..<fetchResult.count {
                    let asset = fetchResult.object(at: i) as PHAsset
                    self.assets.append(asset)
                }
            }
            else {
                print("There are no images or videos")
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
}

extension PHAsset {
    
    
    func getImage(ofSize size: CGSize, completion: @escaping (UIImage) -> ()) {
        let imageManager = PHCachingImageManager()
//        let imageResource = PHAssetResource.assetResources(for: self)
//        imageResource[0].originalFilename
        
        
        
        imageManager.requestImage(for: self, targetSize: size, contentMode: .aspectFit, options: nil, resultHandler: { image, _ in
            completion(image!)
        })
    }
    
    // MARK: Get your video url
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)) {

        if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            
            
                        PHImageManager.default().requestAVAsset(forVideo: self, options: nil) { (AVAsset, AVAudioMix, [AnyHashable : Any]?) -> Void in
            
                            let urlAsset = AVAsset as! AVURLAsset
                            let localVideoUrl = urlAsset.url as NSURL
                            completionHandler(localVideoUrl as URL)
            }
            

            
        }
    }
}

