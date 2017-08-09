//
//  CoreDataUtilities.swift
//  LoveYourSelfie
//
//  Created by Francesco Galasso on 08/05/17.
//  Copyright © 2017 Francesco Galasso. All rights reserved.
//

import UIKit
import CoreData


var appDelegate  = UIApplication.shared.delegate as!AppDelegate
var managedContext : NSManagedObjectContext!  = appDelegate.managedObjectContext
var rating : NSEntityDescription? = NSEntityDescription.entity(forEntityName: "Preferenza", in: managedContext!)


class CoreDataUtilities: NSObject {
    
    static let sharedInstance = CoreDataUtilities()

    
    func saveToDB(_ valueAttribute : [String], entityName : String, key : [String]){
        
        deleteAllData(entityName, valueAttribute:valueAttribute[0])
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: managedContext!)
        // add our data
        entity.setValue(valueAttribute[0], forKey: key[0])  //id
        entity.setValue(valueAttribute[1], forKey: key[1])  //voto1
        entity.setValue(valueAttribute[2], forKey: key[2])  //voto2
        // save it
        do {
            try managedContext!.save()
            print("salvati")
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func deleteAllData(_ entity: String, valueAttribute: String)
    {
        
        _ = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)

        let fetchPredicate = NSPredicate(format: "id == %@", valueAttribute)
        let fetchPreferenza = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchPreferenza.predicate = fetchPredicate
        fetchPreferenza.returnsObjectsAsFaults = false
        
        do
        {
            let results = try! managedContext!.fetch(fetchPreferenza)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext!.delete(managedObjectData)
                
                // save it
                do {
                    try managedContext!.save()
                } catch {
                    fatalError("Failure to save context: \(error)")
                }
            }
        } catch let error as NSError {
            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
        }
    }
    
}
