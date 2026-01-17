//
//  DataController.swift
//  Jisa-Bokei
//
//  Created by 小沢克治 on 2018/11/03.
//  Copyright © 2018年 Private. All rights reserved.
//

import UIKit
import CoreData

class DataController: NSObject {

    // コンテキスト
    var dataContext: NSManagedObjectContext!

    // イニシャライザー
    init(completionClosure: @escaping () -> ()) {
        super.init()
        if #available(iOS 10.0, *) {
            dataContext = persistentContainer.viewContext
        } else {
        }
        completionClosure()
    }

    // MARK: - Core Data stack

    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: ENTITY.TIMEZONEID)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
/*
    // iOS9以前
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional.
        // It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: ENTITY.TIMEZONEID, withExtension: "xcdatamodeld")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("TimeZoneIDTable.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
*/
    // MARK: - Core Data Saving support

    func saveContext() {
        if dataContext.hasChanges {
            do {
                try dataContext.save()
            } catch let error as NSError {
                fatalError("DataController:saveContext: Context save failure. Unresolved error \(error). \(error.userInfo)")
            }
        } else {
            print("DataController:saveContext: Context is not save.")
        }
    }

    // 件数カウント
    func countRecord(_ filter:String?,_ entityName:String!) -> Int {
//        print("DataController:countRecord: filter=\(filter ?? "nil")")
        // Core Data 件数カウント
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        if filter != nil {
            request.predicate = NSPredicate(format: filter!)
        }
        var count: Int = 0
        if dataContext == nil {
            return 0
        }
        do {
            count = try dataContext.count(for: request)
        } catch let error as NSError {
            print("DataController:countRecord: filter='\(filter ?? "nil")', entityName='\(String(entityName))'")
            fatalError("DataController:countRecord: Fetch count error. \(error), \(error.userInfo)")
        }
//        print("DataController:countRecord: fetch count = \(count)")
        return count
    }

    // TimeZoneIDModelレコード取り出し
    func fetchTimeZoneIDModel(_ filter:String?) -> [TimeZoneIDModel] {
//        print("DataController:fetchTimeZoneIDModel: filter=\(filter ?? "nil")")
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ENTITY.TIMEZONEID)
        if filter != nil {
            request.predicate = NSPredicate(format: filter!)
        }
        do {
            let fetchedTimeZoneIDs = try dataContext.fetch(request) as! [TimeZoneIDModel]
            return fetchedTimeZoneIDs
        } catch  let error as NSError {
            fatalError("DataController:fetchTimeZoneIDModel: Failed to fetch timeZoneID: \(error), \(error.userInfo)")
        }
    }

    // レコード削除
    func deleteRecord(_ filter:String?) {
//        print("DataController:deleteRecord: filter=\(filter ?? "nil")")
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ENTITY.TIMEZONEID)
        if filter != nil {
            request.predicate = NSPredicate(format: filter!)
        }
        let fetchData = try! dataContext.fetch(request)
        if !fetchData.isEmpty {
            for i in 0..<fetchData.count {
                let deleteObject = fetchData[i] as! NSManagedObject
                dataContext.delete(deleteObject)
            }
            saveContext()
        }
    }

    // データ更新
    func updateCheckedData(_ recId: Int16, _ check: Bool) -> Bool {

        // 更新するデータを指定する。
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ENTITY.TIMEZONEID)
        request.resultType = .managedObjectResultType
        request.predicate = NSPredicate(format: "id = %d", recId)
        print("DataController:updateData: request.predicate = '\(request.predicate!)'")
        
        // 読み込み実行
        do {
            let results = try dataContext.fetch(request) as! [TimeZoneIDModel]
//            print("DataController:updateData: fetch count = \(results.count)")
            if !results.isEmpty {
                let timeZoneIDModel = results[0]
                timeZoneIDModel.checked = check
                // 保存
                saveContext()
                return true
            } else {
                print("DataController:updateData: No update! recId=\(recId)")
                return false
            }
        } catch let error as NSError {
            fatalError("DataController:updateData: Failed to fetch data. \(error), \(error.userInfo)")
        }

    }

    // データクリア
    func clearCheckedData() -> Bool {

        // 更新するデータを指定する。
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ENTITY.TIMEZONEID)
        request.resultType = .managedObjectResultType
        request.predicate = NSPredicate(format: ENTITY.ITEM.CHECKED+"=true")

        // 読み込み実行
        do {
            let results = try dataContext.fetch(request) as! [TimeZoneIDModel]
            print("DataController:clearCheckedData: fetch count = \(results.count)")
            if !results.isEmpty {
                for result in results {
                    result.checked = false
                }
                // 保存
                saveContext()
                return true
            } else {
                print("DataController:clearCheckedData: No update!")
                return false
            }
        } catch let error as NSError {
            fatalError("DataController:clearCheckedData: Failed to fetch data. \(error), \(error.userInfo)")
        }
        
    }

    /*
     *  TableView用FetchResultController （TimeZoneIDModel用）
     */

     // フェッチリザルト
    var tzFetchedResultsController: NSFetchedResultsController<TimeZoneIDModel>!

     // フェッチリザルト初期化(TimeZoneIDModel)
    func initializeFetchedResultsController(_ fetchType:Int8, _ countryName: String?) -> NSFetchedResultsController<TimeZoneIDModel> {

        let request = NSFetchRequest<TimeZoneIDModel>(entityName: ENTITY.TIMEZONEID)
        request.returnsObjectsAsFaults = false
        let sortKey:NSSortDescriptor
        switch fetchType {
        case FETCHTYPE.COUNTRY_SELECT.rawValue:
            sortKey = NSSortDescriptor(key: ENTITY.ITEM.AREA, ascending: true)
            request.sortDescriptors = [sortKey]
            request.propertiesToGroupBy = [ENTITY.ITEM.AREA,ENTITY.ITEM.COUNTRYNAME,ENTITY.ITEM.COUNTRYCODE]
            request.resultType = .dictionaryResultType
            request.propertiesToFetch = [ENTITY.ITEM.AREA,ENTITY.ITEM.COUNTRYNAME,ENTITY.ITEM.COUNTRYCODE]
            tzFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: dataContext, sectionNameKeyPath: ENTITY.ITEM.AREA, cacheName: nil)
        case FETCHTYPE.CITY_SELECT.rawValue:
            sortKey = NSSortDescriptor(key: ENTITY.ITEM.ID, ascending: true)
            request.sortDescriptors = [sortKey]
            request.resultType = .dictionaryResultType
            request.predicate = NSPredicate(format: ENTITY.ITEM.COUNTRYNAME+" = %@", countryName!)
            tzFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: dataContext, sectionNameKeyPath: nil, cacheName: nil)
        default:
            print("DataController:initializeFetchedResultsController: fetchType=\(fetchType)")
        }
        tzFetchedResultsController.delegate = nil
    
        do {
            try tzFetchedResultsController.performFetch()
        } catch let error as NSError {
            fatalError("DataController:initializeFetchedResultsController: Failed to initialize FetchedResultsController: \(error), \(error.userInfo)")
        }
        return tzFetchedResultsController
    }

}
