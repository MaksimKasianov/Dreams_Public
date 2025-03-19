//
//  SoundsMixEntity.swift
//  DreamApp
//
//  Created by Kasianov on 26.04.2024.
//

import CoreData
import UIKit

@objc(SoundsMixEntity)
public class SoundsMixEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SoundsMixEntity> {
        return NSFetchRequest<SoundsMixEntity>(entityName: "SoundsMixEntity")
    }

    @NSManaged public var sounds: String?
    @NSManaged public var name: String?
}


class SoundsMixBase {
    static let shared = SoundsMixBase()
    
    var mixList = [SoundsMixEntity]()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    init() {
        self.mixList = loadAll()
    }
    
    func loadAll() -> [SoundsMixEntity] {
        print("LOADING MIXES")
        
        let contex: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<SoundsMixEntity> = SoundsMixEntity.fetchRequest()
        
        do {
            let results = try contex.fetch(request)
            return results
        } catch {
            return [SoundsMixEntity]()
        }
    }
    
    func add(name: String, sounds: String) -> SoundsMixEntity {
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let newMix = SoundsMixEntity(context: context)
        newMix.name = name
        newMix.sounds = sounds
        
        do {
            try context.save()
            mixList.append(newMix)
        } catch { }
        
        return newMix
    }
    
    func delete(mix: SoundsMixEntity) {
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        context.delete(mix)
        
        do {
            try context.save()
            if let index = mixList.firstIndex(of: mix) {
                mixList.remove(at: index)
            }
            
        } catch { }
    }
}


