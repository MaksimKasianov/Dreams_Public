//
//  DreamsData.swift
//  WeDream
//
//  Created by Kasianov on 16.10.2023.
//

import CoreData
import UIKit

@objc(DreamData)
class DreamData: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DreamData> {
        return NSFetchRequest<DreamData>(entityName: "DreamData")
    }

    @NSManaged public var date: Date!
    @NSManaged public var dream: String!
    @NSManaged public var dreamReview: String!
    @NSManaged public var note: String!
    @NSManaged public var themes: String!
    @NSManaged public var loadingReview: NSNumber?// Bool?
    @NSManaged public var loadingImage: NSNumber?
    @NSManaged public var picture: Data?
}

class DreamBase {
    static let shared = DreamBase()
    
    var dreamsList = [DreamData]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func loadAll() {
        dreamsList.removeAll()

        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<DreamData> = DreamData.fetchRequest()

        do {
            let results = try context.fetch(request)
            dreamsList = results

            // Сортування за датою у зворотньому порядку (від більшого до меншого)
            dreamsList.sort(by: { $0.date! > $1.date! })
        } catch {
            //print("Fetch Failed")
        }
    }
    
    func add(dream: String, themes: String = "", note: String = "", descriptions: String = "", complection: @escaping (DreamData?) -> Void) {
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let newDream = DreamData(context: context)
        
        newDream.dream = dream
        newDream.date = Date()
        newDream.themes = themes
        newDream.note = note
        newDream.dreamReview = descriptions
                
        do {
            try context.save()
            dreamsList.insert(newDream, at: 0)
            
            dreamsList.sort(by: { $0.date! > $1.date! })
            
            complection(newDream)
        } catch {
            print("add error: \(error)")
            complection(nil)
        }
    }

    func deleteDream(selected: DreamData) {
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        context.delete(selected)
        
        do {
            try context.save()
            if let index = dreamsList.firstIndex(of: selected) {
                dreamsList.remove(at: index)
            }
            
            dreamsList.sort(by: { $0.date! > $1.date! })
        } catch {
            print("delete error: \(error)")
        }
    }
    
    func deleteAll() {
        if dreamsList.isEmpty {
            return
        }
        
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        for dream in dreamsList {
            context.delete(dream)
        }
        
        do {
            try context.save()
            dreamsList.removeAll()
        } catch {
            print("delete error: \(error)")
        }
    }
    
    func editDream(selectedDream: DreamData) {
        let context = appDelegate.persistentContainer.viewContext

        do {
            try context.save()
            if let index = dreamsList.firstIndex(of: selectedDream) {
                dreamsList[index] = selectedDream
            }
            
            dreamsList.sort(by: { $0.date! > $1.date! })
        } catch {
            print("edit error: \(error)")
        }
    }
}
