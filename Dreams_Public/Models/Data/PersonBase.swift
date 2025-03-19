//
//  PersonData.swift
//  WeDream
//
//  Created by Kasianov on 17.11.2023.
//

import CoreData
import UIKit

@objc(PersonData)
class PersonData: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersonData> {
        return NSFetchRequest<PersonData>(entityName: "PersonData")
    }

    @NSManaged public var born: Date?
    @NSManaged public var name: String?
    @NSManaged public var status: String?
    @NSManaged public var gender: String?
}

class PersonBase {
    static let shared = PersonBase()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func loadPerson(complection: @escaping (PersonData?) -> Void) {
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<PersonData> = PersonData.fetchRequest()
        
        do {
            let results = try context.fetch(request)
            if let data = results.last {
                complection(data)
            } else {
                complection(nil)
            }
        } catch {
            complection(nil)
        }
    }
    
    func add(data: PersonRegister) {
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let newPerson = PersonData(context: context)
        
        newPerson.name = data.name
        newPerson.born = data.born
        newPerson.gender = data.gender
        newPerson.status = data.status
                
        do {
            try context.save()
        } catch {
            print("add error: \(error)")
        }
    }
    
    func edit(complection: @escaping () -> Void) {
        let context = appDelegate.persistentContainer.viewContext

        do {
            try context.save()
        } catch {
            print("edit error: \(error)")
        }
        
        complection()
    }
    
    func delete() {
        if let person = Shared.shared.personData {
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            
            context.delete(person)
            
            do {
                try context.save()
                Shared.shared.personData = nil
            } catch {
                print("delete error: \(error)")
            }
        }
    }
}

class PersonRegister {
    var born: Date!
    var name: String!
    var status: String!
    var gender: String!
}
