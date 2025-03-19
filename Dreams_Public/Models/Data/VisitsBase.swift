//
//  VisitsData.swift
//  WeDream
//
//  Created by Kasianov on 19.10.2023.
//

import Foundation
import CoreData
import UIKit

@objc(VisitsData)
class VisitsData: NSManagedObject {
    @NSManaged var monday: NSNumber!
    @NSManaged var tuesday: NSNumber!
    @NSManaged var wednesday: NSNumber!
    @NSManaged var thursday: NSNumber!
    @NSManaged var friday: NSNumber!
    @NSManaged var saturday: NSNumber!
    @NSManaged var sunday: NSNumber!
    @NSManaged var date: Date!
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<VisitsData> {
        return NSFetchRequest<VisitsData>(entityName: "VisitsData")
    }
}

class VisitsBase {
    static let shared = VisitsBase()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var visitsList = [VisitsData]()
    
    func loadVisits() {
        if let visitsData = fetchVisits(), !visitsData.isEmpty {
            self.visitsList = visitsData
        } else {
            self.visitsList = newVisits()
        }
    }
    
    func fetchVisits() -> [VisitsData]? {
        let context = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<VisitsData> = VisitsData.fetchRequest()
        
        do {
            let results = try context.fetch(request)
            return results
        } catch {
            print("fetch visits rror: \(error)")
            return nil
        }
    }

    func newVisits() -> [VisitsData] {
        let context = appDelegate.persistentContainer.viewContext
        let newVisitsData = VisitsData(context: context)
        
        newVisitsData.monday = false
        newVisitsData.tuesday = false
        newVisitsData.wednesday = false
        newVisitsData.thursday = false
        newVisitsData.friday = false
        newVisitsData.saturday = false
        newVisitsData.sunday = false
        
        newVisitsData.date = Date()
        
        do {
            try context.save()
            return [newVisitsData]
        } catch {
            print("new visits error: \(error)")
            return [VisitsData]()
        }
    }
    
    func reloadVisits(visits: VisitsData) {
        let context = appDelegate.persistentContainer.viewContext
        visits.monday = false
        visits.tuesday = false
        visits.wednesday = false
        visits.thursday = false
        visits.friday = false
        visits.saturday = false
        visits.sunday = false
        
        visits.date = Date()
        
        do {
            try context.save()
            if let index = visitsList.firstIndex(of: visits) {
                visitsList[index] = visits
            }
        } catch {
            print("reload visits error: \(error)")
        }
        
        print("reload visits")
    }
    
    func editVisits(visit: VisitsData) {
        let context = appDelegate.persistentContainer.viewContext

        do {
            try context.save()
            if let index = visitsList.firstIndex(of: visit) {
                visitsList[index] = visit
            }
        } catch {
            print("edit visits error: \(error)")
        }
        
//        print("monday \(visitsList.first!.monday.description)")
//        print("tuesday \(visitsList.first!.tuesday.description)")
//        print("wednesday \(visitsList.first!.wednesday.description)")
//        print("thursday \(visitsList.first!.thursday.description)")
//        print("friday \(visitsList.first!.friday.description)")
//        print("saturday \(visitsList.first!.saturday.description)")
//        print("sunday \(visitsList.first!.sunday.description)")
    }
    
    func deleteAll() {
        if visitsList.isEmpty {
            return
        }
        
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        for visit in visitsList {
            context.delete(visit)
        }
        
        do {
            try context.save()
            visitsList.removeAll()
        } catch {
            print("delete error: \(error)")
        }
    }
}
