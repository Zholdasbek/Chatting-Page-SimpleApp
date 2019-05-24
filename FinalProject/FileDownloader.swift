//
//  FileDownloader.swift
//  FinalProject
//
//  Created by Zholdas on 5/4/19.
//  Copyright © 2019 Zholdas. All rights reserved.
//

import UIKit

protocol FileDownloaderDelegate: class {
    func sendPogress(progress: CGFloat)
    func didFinished(url: String?)
}

class FileDownloader: NSObject ,URLSessionDownloadDelegate{
    
    var urlSession = URLSession()
    var downloadTask: URLSessionDownloadTask!
    var progressToImageCell: ImageCell?
    weak var delegate: FileDownloaderDelegate?
    
    func beginDownloadingFile(isDownloading: Bool, randomRemoteUrl: String?) {
        if isDownloading {
            let configuration = URLSessionConfiguration.default
            let operationQueue = OperationQueue()
            self.urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)
            
            guard let url = URL(string: randomRemoteUrl!) else { return }
            downloadTask = urlSession.downloadTask(with: url)
            
            downloadTask.resume()
        }
        else {
            DispatchQueue.main.async {
                self.downloadTask.cancel()
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let percentage = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        delegate?.sendPogress(progress: percentage)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
     

        let fileManager = FileManager()

        let directoryURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let docDirectoryURL = NSURL(fileURLWithPath: "\(directoryURL)")

        let destinationFilename = (Date().description + (downloadTask.originalRequest?.url?.lastPathComponent)!)
        let destinationURL =  docDirectoryURL.appendingPathComponent(destinationFilename)

        if let path = destinationURL?.path {
            if fileManager.fileExists(atPath: path) {
                do { try fileManager.removeItem(at: destinationURL!) }
                catch { print (error)}
            }
        }

        do { try fileManager.copyItem(at: location, to: destinationURL!)}
        catch {print(error)}

        delegate?.didFinished(url: destinationFilename)
    }
}
