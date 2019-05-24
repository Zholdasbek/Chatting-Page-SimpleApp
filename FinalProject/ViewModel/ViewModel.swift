//
//  ViewModel.swift
//  FinalProject
//
//  Created by Zholdas on 3/29/19.
//  Copyright © 2019 Zholdas. All rights reserved.
//

import UIKit
import CoreData

class ViewModel {

    var messages: [DBMessage]?
    
    var didGetList: (([DBMessage]) -> ())?
    
    func loadData() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext {
            let fetchRequest:NSFetchRequest<DBMessage> = DBMessage.fetchRequest()
            do {
                let fetchedMessages = try(context.fetch(fetchRequest))
                DispatchQueue.main.async {
                    self.didGetList?(fetchedMessages)
                }
            } catch let err {
                print(err)
            }
        }
        
    }
    
    
    func updateData(index: Int, downloadedIndicator: Bool, loadedImageLocalUrl: String?, loadedVideoLocalUrl: String?, isDownloading: Bool){
        let delegate = UIApplication.shared.delegate as? AppDelegate

        let context = delegate?.persistentContainer.viewContext

        do {
            let arr: NSFetchRequest<DBMessage> = DBMessage.fetchRequest()
            let fetchedMessages = try(context?.fetch(arr))
            let messageToUpdate = fetchedMessages![index]
    
            
            if isDownloading {
                messageToUpdate.setValue(isDownloading, forKey: "downloading")
            }
            else {
                messageToUpdate.setValue(isDownloading, forKey: "downloading")
                if loadedImageLocalUrl != nil{
                    messageToUpdate.setValue(downloadedIndicator, forKey: "isFinishedLoad")
                    messageToUpdate.setValue(loadedImageLocalUrl, forKey: "localUrlOfImage")
                }
                else {
                    messageToUpdate.setValue(downloadedIndicator, forKey: "isFinishedLoad")
                    messageToUpdate.setValue(loadedVideoLocalUrl, forKey: "localUrlOfVideo")
                }
            }
            
            
            if (context?.hasChanges)!{
                do{
                    try context?.save()
                }
                catch
                {
                    print(error)
                }
            }
            
        }
        catch
        {
            print(error)
        }


    }
    
    func clearData() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext {
            do {
                let entityNames = [DBMessage.self]
                for entityName in entityNames {
                    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = entityName.fetchRequest()
                    let messages = try(context.fetch(fetchRequest))
                    
                    for message in messages {
                        context.delete(message as! NSManagedObject )
                    }
                }
                try(context.save())
            } catch let err {
                print(err)
            }
        }
    }
    
    func createMessageWithText (text: String, context: NSManagedObjectContext, isSender: Bool, localUrlImage: String?, localUrlVideo: String?) -> DBMessage {
        
        let message = NSEntityDescription.insertNewObject(forEntityName: "DBMessage", into: context) as! DBMessage
        

        if isSender{
            message.isFinishedLoad = true
        }
        else{
            message.isFinishedLoad = false
        }
        message.downloading = false
        message.isSender = isSender
        message.date = NSDate().addingTimeInterval(0)
        message.text = text

        // MARK: Message with just text
        
        if  localUrlImage == nil && localUrlVideo == nil {
            message.localUrlOfImage = nil
            message.localUrlOfVideo = nil
        }
        else if localUrlImage != nil && localUrlVideo == nil{
            message.localUrlOfImage = localUrlImage
            message.localUrlOfVideo = nil
        }
        else if localUrlImage == nil && localUrlVideo != nil{
            message.localUrlOfImage = nil
            message.localUrlOfVideo = localUrlVideo
        }
        return message
    }
    
    func sendMessageWithText(text: String, isSender: Bool, imageURL: String?, videoURL: String?){
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        let context = delegate?.persistentContainer.viewContext
        
        let message: DBMessage?
        
        message = createMessageWithText(text: text, context: context!, isSender: isSender , localUrlImage: imageURL, localUrlVideo: videoURL)
        
        do {
            try context?.save()
            messages?.append(message!)
            loadData()
        } catch let err {
            print(err)
        }
    }
}
