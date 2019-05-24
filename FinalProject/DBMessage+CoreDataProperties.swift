//
//  DBMessage+CoreDataProperties.swift
//  FinalProject
//
//  Created by Zholdas on 5/21/19.
//  Copyright © 2019 Zholdas. All rights reserved.
//
//

import Foundation
import CoreData


extension DBMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBMessage> {
        let request = NSFetchRequest<DBMessage>(entityName: "DBMessage")
        request.sortDescriptors = [NSSortDescriptor.init(key: "date", ascending: false)]
        return request
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var isFinishedLoad: Bool
    @NSManaged public var isSender: Bool
    @NSManaged public var localUrlOfImage: String?
    @NSManaged public var localUrlOfVideo: String?
    @NSManaged public var text: String?
    @NSManaged public var downloading: Bool

}
