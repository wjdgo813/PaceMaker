//
//  PaceDataManager.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/23.
//

import Foundation
import CoreData
import RxSwift
import RxCocoa

class PaceDataManager {
    static let shared = PaceDataManager()
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Pace")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error, \((error as NSError).userInfo)")
            }
        })
        return container
    }()
    
    func save(runDate: Date,distance: Double,
              duration: Int64,walking: Int64,
              pace: String,
              onSuccess: @escaping ((Bool) -> Void)) {
        let context = self.persistentContainer.viewContext
        guard let entitiy = NSEntityDescription.entity(forEntityName: "Pace", in: context) else { return }
        guard let p: Pace = NSManagedObject(entity: entitiy, insertInto: context) as? Pace else { return }
        p.runDate = runDate
        p.distance = distance
        p.duration = duration
        p.walking = walking
        p.pace = pace
        p.id = Date().toUTCString()
        p.yearMonth = "\(runDate.string(WithFormat: .MMMM)) \(runDate.string(WithFormat: .yyyy))"
        contextSave { success in
            onSuccess(success)
        }
    }
    
    func query(yearMonth: String) -> [Pace] {
        var paces = [Pace]()
        let context = persistentContainer.viewContext
        
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>(entityName: "Pace")
        let predicate = NSPredicate(format: "yearMonth == %@", yearMonth)
        request.predicate = predicate

        do {
            if let fetchResult: [Pace] = try context.fetch(request) as? [Pace] {
                paces = fetchResult
            }
        } catch let error as NSError {
            print("Could not fetch🥺: \(error), \(error.userInfo)")
        }
        
        
        return paces
    }
    
    func query() -> [Pace] {
        var paces = [Pace]()
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>(entityName: "Pace")
        do {
            if let fetchResult: [Pace] = try context.fetch(request) as? [Pace] {
                paces = fetchResult
            }
        } catch let error as NSError {
            print("Could not fetch🥺: \(error), \(error.userInfo)")
        }
        
        return paces
    }
    
    func deletePace(id: String, onSuccess: @escaping ((Bool) -> Void)) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
            = NSFetchRequest<NSFetchRequestResult>(entityName: "Pace")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            if let results: [Pace] = try self.persistentContainer.viewContext.fetch(fetchRequest) as? [Pace] {
                if results.count != 0 {
                    self.persistentContainer.viewContext.delete(results[0])
                }
            }
        } catch let error as NSError {
            print("Could not fatch🥺: \(error), \(error.userInfo)")
            onSuccess(false)
        }
        
        contextSave { success in
            onSuccess(success)
        }
    }
}

extension PaceDataManager {
    
    private func contextSave(onSuccess: ((Bool) -> Void)) {
        do {
            try persistentContainer.viewContext.save()
            onSuccess(true)
        } catch let error as NSError {
            print("Could not save🥶: \(error), \(error.userInfo)")
            onSuccess(false)
        }
    }
}
