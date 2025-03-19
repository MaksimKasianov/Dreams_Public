//
//  MessageEntity.swift
//  testAssistent
//
//  Created by Kasianov on 22.03.2024.
//

import Foundation
import UIKit
import CoreData


func loadMessages() -> [Message] {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
    let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()

    var messages = [Message]()
    
    do {
        let results = try context.fetch(request)
        
        for result in results {
            let mess = Message(
                id: result.id ?? UUID(),
                threadId: result.threadId ?? String(),
                role: result.role ?? String(),
                content: result.content ?? String(),
                createdAt: result.createdAt ?? Date()
            )
            messages.append(mess)
        }
        
        return messages
    } catch {
        return messages
    }
}

func addMessageEntity(id: UUID, threadId: String, role: String, content: String, createdAt: Date) {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
    let newMessageEntity = MessageEntity(context: context)
    newMessageEntity.id = id
    newMessageEntity.threadId = threadId
    newMessageEntity.role = role
    newMessageEntity.content = content
    newMessageEntity.createdAt = createdAt

    do {
        try context.save()
    } catch {
        print("Error")
    }
}
