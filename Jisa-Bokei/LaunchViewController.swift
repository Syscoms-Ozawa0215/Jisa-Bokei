//
//  LaunchViewController.swift
//  Jisa-Bokei
//
//  Created by 小沢克治 on 2018/03/03.
//  Copyright © 2018年 Private. All rights reserved.
//

import UIKit
import CoreData

class LaunchViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

     override func viewDidAppear(_ animated: Bool) {
        
        // Core Data 件数カウント
        let cnt1 = appDelegate.dataController.countRecord(nil,ENTITY.TIMEZONEID)
        
        // Core Data 更新 (TimeZoneID)
        if 1...364 ~= cnt1 || cnt1 > 365 {
            // 一旦消してから入れ直す
            appDelegate.dataController.deleteRecord(nil)
            initMasters()
        } else if cnt1 <= 0 {
            // 空なので入れる
            initMasters()
        }

        // タイトル表示時間
        sleep(1)

        // abbreviation.plist読み込み
        
        // メインストーリーボードに遷移
        let storyboard: UIStoryboard = self.storyboard!
        let next = storyboard.instantiateViewController(withIdentifier: ID.STORYBOARD.MAIN)
        next.modalPresentationStyle = .fullScreen
        present(next, animated: true, completion: nil)
        
     }
 
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func initMasters() {
        print("LaunchViewController:initMasters ------------")

        // NSDictionaryとして読み込む
        let filePath = Bundle.main.path(forResource: PLIST.TIMEZONEID_MASTER, ofType: nil)
        let plist = NSMutableDictionary(contentsOfFile: filePath!)

        // CoreDataへのデータ書き込み
        let context = appDelegate.dataController.dataContext!
        let myEntity: NSEntityDescription! = NSEntityDescription.entity(forEntityName: ENTITY.TIMEZONEID, in: context)

        //
        print("LaunchViewController:initMasters:plist!.count = \(plist!.count)")
        let pl = PLIST.init()
        for i in 1...plist!.count {
            let id          = plist!.value(forKeyPath:pl.Record(i, PLIST.ITEM.ID))
            let geonameID   = plist!.value(forKeyPath:pl.Record(i, PLIST.ITEM.GEONAMEID))
            let latitude    = plist!.value(forKeyPath:pl.Record(i, PLIST.ITEM.LATITUDE))
            let longtitude  = plist!.value(forKeyPath:pl.Record(i, PLIST.ITEM.LONGTITUDE))
            let countryCode = plist!.value(forKeyPath:pl.Record(i, PLIST.ITEM.COUNTRYCODE))
            let timezoneID  = plist!.value(forKeyPath:pl.Record(i, PLIST.ITEM.TIMEZONEID))
            let area        = plist!.value(forKeyPath:pl.Record(i, PLIST.ITEM.AREA))
            let countryName = plist!.value(forKeyPath:pl.Record(i, PLIST.ITEM.COUNTRYNAME))
            let cityName    = plist!.value(forKeyPath:pl.Record(i, PLIST.ITEM.CITYNAME))

            let timezoneIDModel = NSManagedObject(entity: myEntity, insertInto: context)
            timezoneIDModel.setValue(id          as! Int16,  forKey: ENTITY.ITEM.ID)
            timezoneIDModel.setValue(geonameID   as! Int32,  forKey: ENTITY.ITEM.GEONAMEID)
            timezoneIDModel.setValue(latitude    as! Double, forKey: ENTITY.ITEM.LATITUDE)
            timezoneIDModel.setValue(longtitude  as! Double, forKey: ENTITY.ITEM.LONGTITUDE)
            timezoneIDModel.setValue(countryCode as! String, forKey: ENTITY.ITEM.COUNTRYCODE)
            timezoneIDModel.setValue(timezoneID  as! String, forKey: ENTITY.ITEM.TIMEZONEID)
            timezoneIDModel.setValue(area        as! String, forKey: ENTITY.ITEM.AREA)
            timezoneIDModel.setValue(countryName as! String, forKey: ENTITY.ITEM.COUNTRYNAME)
            timezoneIDModel.setValue(cityName    as! String, forKey: ENTITY.ITEM.CITYNAME)
        }

        do {
            try context.save()
        } catch  let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        print("LaunchViewController:initMasters:------------")
    }
    
}
