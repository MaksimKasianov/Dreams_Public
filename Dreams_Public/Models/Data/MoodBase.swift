//
//  MoodData.swift
//  WeDream
//
//  Created by Kasianov on 20.10.2023.
//

import CoreData
import UIKit


@objc(MoodData)
class MoodData: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MoodData> {
        return NSFetchRequest<MoodData>(entityName: "MoodData")
    }

    @NSManaged public var date: Date!
    @NSManaged public var mood: String!
    @NSManaged public var emotion: String!
}

class MoodBase {
    static let shared = MoodBase()
    
    var moodsList = [MoodData]()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func loadAll() {
        moodsList.removeAll()
        
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<MoodData> = MoodData.fetchRequest()
        
        do {
            let results = try context.fetch(request)
            moodsList = results
            
            moodsList.sort(by: { $0.date > $1.date })
        } catch {
            //print("Fetch Failed")
        }
    }
    
    func add(mood: String, emotion: String) {
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let newMood = MoodData(context: context)
        
        newMood.mood = mood
        newMood.emotion = emotion
        newMood.date = Date()
                
        do {
            try context.save()
            moodsList.insert(newMood, at: 0)
            
            moodsList.sort(by: { $0.date > $1.date })
        } catch {
            print("add error: \(error)")
        }
    }

    func delete(selected: MoodData) {
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        context.delete(selected)
        
        do {
            try context.save()
            if let index = moodsList.firstIndex(of: selected) {
                moodsList.remove(at: index)
            }
            
            moodsList.sort(by: { $0.date > $1.date })
        } catch {
            print("delete error: \(error)")
        }
    }
    
    func edit(selected: MoodData) {
        let context = appDelegate.persistentContainer.viewContext

        do {
            try context.save()
            if let index = moodsList.firstIndex(of: selected) {
                moodsList[index] = selected
            }
            
            moodsList.sort(by: { $0.date > $1.date })
        } catch {
            print("edit error: \(error)")
        }
    }
    
    func deleteAll() {
        if moodsList.isEmpty {
            return
        }
        
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        for mood in moodsList {
            context.delete(mood)
        }
        
        do {
            try context.save()
            moodsList.removeAll()
        } catch {
            print("delete error: \(error)")
        }
    }
}
