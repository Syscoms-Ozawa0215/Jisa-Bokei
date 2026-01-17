//
//  ListViewController.swift
//  Jisa-Bokei
//
//  Created by 小沢克治 on 2018/03/04.
//  Copyright © 2018年 Private. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    // AppDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // 呼び出し回数
    var pushCnt:Int = 0
    
    // 選択情報
    var selectCountry: String? = nil
    
    //　都市選択ビューコントローラー
    var citySelectViewController: CitySelectViewController? = nil
    
    // セクションの個数を指定
    func numberOfSections(in tableView: UITableView) -> Int {
        let cnt = fetchedResultsController.sections!.count
//        print("ListViewController:numberOfSections:fetchedResultsController.sections!.count = \(cnt)")
        return cnt
    }

    // セクションごとの行数を指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cnt = fetchedResultsController.sections?[section].numberOfObjects ?? 0
//        print("ListViewController:numberOfRowsInSections:fetchedResultsController.sections?[\(section)].numberOfObjects = \(cnt)")
        return cnt
    }

    // セクションのタイトルを指定
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sTitle = fetchedResultsController.sections?[section].name
//        print("ListViewController:titleForHeaderInSection:fetchedResultsController.sections?[\(section)].name = \(sTitle ?? "nil")")
        return sTitle
    }

    //セクション名の配列を返す
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if pushCnt == 0 {
            let indexArray = ["ア","ア","イ","オ","ヨ","北","北","南","南","大","太"]
            return indexArray
        }
        return nil
    }
    
    // セルのコンテンツを指定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: ID.CELL.LIST, for: indexPath)
        if cell.detailTextLabel == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: ID.CELL.LIST)
        }
        // Set up the cell
        configureCell(cell, indexPath, tableView)
        return cell
    }

    // セルのConfigration
    func configureCell(_ cell: UITableViewCell, _ indexPath: IndexPath,_ tv: UITableView) {
        // Populate cell from the NSManagedObject instance
        let tzModelObj = fetchedResultsController.object(at: indexPath)
        if pushCnt == 0 {
            // 国一覧
            let areaName    = tzModelObj.value(forKey: ENTITY.ITEM.AREA)        as? String ?? "nil"
            let countryName = tzModelObj.value(forKey: ENTITY.ITEM.COUNTRYNAME) as? String ?? "nil"
            let countryCode = tzModelObj.value(forKey: ENTITY.ITEM.COUNTRYCODE) as? String ?? "nil"
//            print("areaName='\(areaName)', countryName='\(countryName)', countryCode='\(countryCode)'")
            // タイトル（Value Text)
            cell.imageView?.image = UIImage(named: countryCode) ?? UIImage(named: IMAGE.NO_IMAGE)
            // タイトル（Value Text）
            cell.textLabel?.text = countryName
            // サブタイトル(Detail Text)
            let cond = ENTITY.ITEM.CHECKED + "=True and " + ENTITY.ITEM.AREA + "='" + areaName + "' and " + ENTITY.ITEM.COUNTRYNAME + "='" + countryName + "'"
            let rec:[TimeZoneIDModel] = appDelegate.dataController.fetchTimeZoneIDModel(cond)
            if rec.count == 1 {
                cell.detailTextLabel?.text = rec[0].city_name
            } else if rec.count == 0 {
                cell.detailTextLabel?.text = ""
            } else {
                print("ListViewController:configureCell: rec.count=\(rec.count)")
                cell.detailTextLabel?.text = "???"
            }
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        } else {
            // 都市一覧
            let cityName = tzModelObj.value(forKey: ENTITY.ITEM.CITYNAME) as? String ?? "nil"
            cell.textLabel?.text = cityName
            let checked = tzModelObj.value(forKey: ENTITY.ITEM.CHECKED) as? Bool ?? false
            cell.accessoryType = checked ? .checkmark : .none
//            print("city='\(cityName)', checked=\(checked)")
        }
    }

    // セル選択された時に実行するメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("ListViewController:tableView(didSelectRowAt): indexPath=\(indexPath), pushCnt=\(pushCnt)")
        if pushCnt == 0 {
            // 移動先のviewcontroller（自分自身）を選択
            let storyboard: UIStoryboard = self.storyboard!
            let next = storyboard.instantiateViewController(withIdentifier: ID.STORYBOARD.SELF)
            // Push遷移
            let nextVC = next as! ListViewController
            nextVC.selectCountry = (tableView.cellForRow(at: indexPath)?.textLabel?.text!)!
            nextVC.pushCnt += 1
            self.navigationController?.pushViewController(next, animated: true)
        } else {
            // チェックマーク更新
            tableViewCellChecked(tableView, indexPath: indexPath)
        }
        // セルの選択状態を解除
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    // チェックマークの更新
    func tableViewCellChecked(_ tableView: UITableView, indexPath: IndexPath) {

        let tzModelObj  = fetchedResultsController.object(at: indexPath)
        let id          = tzModelObj.value(forKey: ENTITY.ITEM.ID)          as! Int16
        let country     = tzModelObj.value(forKey: ENTITY.ITEM.COUNTRYNAME) as! String
        let city        = tzModelObj.value(forKey: ENTITY.ITEM.CITYNAME)    as! String
        let tz_id       = tzModelObj.value(forKey: ENTITY.ITEM.TIMEZONEID)  as! String
        let latitude    = tzModelObj.value(forKey: ENTITY.ITEM.LATITUDE)    as! Double
        let longtitude  = tzModelObj.value(forKey: ENTITY.ITEM.LONGTITUDE)  as! Double
        let countryCode = tzModelObj.value(forKey: ENTITY.ITEM.COUNTRYCODE) as! String
        
        // 設定ボタン無効化
        citySelectViewController!.setButton.isEnabled = false

        // 既存のチェックがあればOff
        let rec:[TimeZoneIDModel] = appDelegate.dataController.fetchTimeZoneIDModel(ENTITY.ITEM.CHECKED+"=true")
        if !rec.isEmpty {
            let recId = rec[0].id
            // DB上のチェックをクリア
            _ = appDelegate.dataController.updateCheckedData(recId, false)

            // 表示上のチェックマークOff
            for cell in tableView.visibleCells {
                if cell.accessoryType == .checkmark {
                    cell.accessoryType = .none
                    break
                }
            }

            // 自分自身なら終了
            if id == recId {
                do {
                    try fetchedResultsController.performFetch()
                } catch let error as NSError {
                    fatalError("tableViewCellChecked: Failed to performFetch: \(error), \(error.userInfo)")
                }
                tableView.reloadData()
                return
            }
        }

        // チェックマークOn
        if let cell = tableView.cellForRow(at:indexPath) {
            // 設定ボタン有効化
            citySelectViewController!.setButton.isEnabled = true
            // チェックマークセット
            cell.accessoryType = .checkmark
            // 更新データセット
            let data = citySelectViewController!.copyBaseData!
            data.setCountry    (country)        // 国名
            data.setCountryCode(countryCode)    // 国名
            data.setCity       (city)           // 都市名
            data.setLatitude   (latitude)       // 緯度
            data.setLongtitude (longtitude)     // 軽度
            data.setTimezone   (tz_id)          // タイムゾーン
            data.setRecordID   (id)             // レコードID
            // データ更新
            if appDelegate.dataController.updateCheckedData(id, true) == true {
                // データ更新があれば、データ再読み込み＆描画更新して終了
                do {
                    try fetchedResultsController.performFetch()
                } catch let error as NSError {
                    fatalError("ListViewController:tableViewCellChecked:Failed to performFetch: \(error), \(error.userInfo)")
                }
                tableView.reloadData()
            }
        }
    }

    @IBOutlet weak var tableView: UITableView!

    // フェッチリザルト
    var dataContext             : NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<TimeZoneIDModel>!

    override func viewDidLoad() {
        print("ListViewController:viewDidLoad:self.pushCnt=\(self.pushCnt)")
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        citySelectViewController = (self.parent!.parent as! CitySelectViewController)
        if pushCnt == 0 {
            // 設定ボタン無効化
            citySelectViewController!.setButton.isEnabled = false
            // CoreDataを一旦クリア
            _ = appDelegate.dataController.clearCheckedData()
            
            // 選択したデータでCoreDataを更新
            let rec_id = citySelectViewController!.copyBaseData!.getRecordID16()
            if rec_id > 0 {
                _ = appDelegate.dataController.updateCheckedData(rec_id, true)
            }
            self.navigationController?.navigationBar.isHidden = true
            fetchedResultsController = appDelegate.dataController.initializeFetchedResultsController(FETCHTYPE.COUNTRY_SELECT.rawValue,nil)
        } else {
            self.navigationItem.title = self.selectCountry
           self.navigationController?.navigationBar.isHidden = false
           fetchedResultsController = appDelegate.dataController.initializeFetchedResultsController(FETCHTYPE.CITY_SELECT.rawValue,self.selectCountry)
        }
        dataContext = appDelegate.dataController.dataContext

        // Table View Cellの登録
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: ID.CELL.LIST)
        tableView.register(cell.classForCoder, forCellReuseIdentifier: ID.CELL.LIST)
        // trueで複数選択、falseで単一選択
        tableView.allowsMultipleSelection = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        if let viewControllers = self.navigationController?.viewControllers {
            self.navigationController?.navigationBar.isHidden = (viewControllers.count == 1)
            // データ再読み込み＆再ロード
            do {
                try fetchedResultsController.performFetch()
            } catch let error as NSError {
                fatalError("tableViewCellChecked:Failed to performFetch: \(error), \(error.userInfo)")
            }
            tableView.reloadData()
        }
//        print("ListViewController:viewWillAppear: animated=\(animated), viewControllers.count=\(viewControllers.count)")
        super.viewWillAppear(animated)
    }

}
