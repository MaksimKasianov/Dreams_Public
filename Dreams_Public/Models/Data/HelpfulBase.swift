//
//  HelpfulBase.swift
//  WeDream
//
//  Created by Kasianov on 27.10.2023.
//

import CoreData
import UIKit

@objc(HelpfulData)
class HelpfulData: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<HelpfulData> {
        return NSFetchRequest<HelpfulData>(entityName: "HelpfulData")
    }

    @NSManaged public var dream: String!
}

class HelpfulBase {
    static let shared = HelpfulBase()
    
    var helpfulList = [HelpfulData]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func loadAll() {
        helpfulList.removeAll()
        
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<HelpfulData> = HelpfulData.fetchRequest()
        
        do {
            let results = try context.fetch(request)
            helpfulList = results
        } catch {
            //print("Fetch Failed")
        }
    }
    
    func add(dream: String) {
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let newHelpful = HelpfulData(context: context)
        
        newHelpful.dream = dream
                
        do {
            try context.save()
            helpfulList.append(newHelpful)
        } catch {
            print("add error: \(error)")
        }
    }
    
    func checkHelpful(dream: String) -> Bool {
        if !helpfulList.isEmpty {
            for helpful in helpfulList {
                if helpful.dream == dream {
                    return true
                }
            }
            return false
        } else {
            return false
        }
    }
    
    func deleteAll() {
        if helpfulList.isEmpty {
            return
        }
        
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        for helpful in helpfulList {
            context.delete(helpful)
        }
        
        do {
            try context.save()
            helpfulList.removeAll()
        } catch {
            print("delete error: \(error)")
        }
    }
}
