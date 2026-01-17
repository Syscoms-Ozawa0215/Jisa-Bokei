//
//  Abbreviation.swift
//  Jisa-Bokei
//
//  Created by 小沢克治 on 2020/11/08.
//  Copyright © 2020 Private. All rights reserved.
//

import Foundation

struct Abbreviation {
    
    // データレコード
    private var record: [(abbr:String, descJp:String, descEn:String, sign:Int, hour:Int, minute:Int, check:Bool)] = []

    // セクションデータ用
    private var sectionData: [(title:String, count:Int, startIndex:Int)] = []

    // シングルトン化
    static let shared: Abbreviation = {
        let instance = Abbreviation()
        return instance
    }()

    private init() {
        print("Abbreviation:init call.")
        // NSDictionaryとして読み込む
        let filePath = Bundle.main.path(forResource: PLIST.ABBREVIATION, ofType: nil)
        let plist = NSMutableDictionary(contentsOfFile: filePath!)!
        let pl = PLIST.init()
        for i in 1...plist.count {
            let abbr   = plist.value(forKeyPath:pl.Record2(i, PLIST.ITEM.ABBR))   as! String
            let descJp = plist.value(forKeyPath:pl.Record2(i, PLIST.ITEM.DESCJP)) as! String
            let descEn = plist.value(forKeyPath:pl.Record2(i, PLIST.ITEM.DESCEN)) as! String
            let sign   = plist.value(forKeyPath:pl.Record2(i, PLIST.ITEM.SIGN))   as! Int
            let hour   = plist.value(forKeyPath:pl.Record2(i, PLIST.ITEM.HOUR))   as! Int
            let minute = plist.value(forKeyPath:pl.Record2(i, PLIST.ITEM.MINUTE)) as! Int
            // レコードデータ設定
            record.append((abbr:abbr, descJp:descJp, descEn:descEn, sign:sign, hour:hour, minute:minute, check:false))
            // セクションタイトル
            let title = String(abbr.prefix(1))
            var f = false
            for j in 0..<sectionData.count {
                if sectionData[j].title == title {
                    sectionData[j].count += 1
                    f = true
                    break
                } else if sectionData[j].title > title {
                    sectionData.insert((title: title, count: 1, startIndex:i-1), at: j)
                    f = true
                    break
                }
            }
            if !f {
                sectionData.append((title: title, count: 1, startIndex:i-1))
            }
        }
    }

    func count() -> Int {
        return record.count
    }
    
    func getRecord(_ indexPath:IndexPath) -> (abbr:String, descJp:String, descEn:String, sign:Int, hour:Int, minute:Int, check:Bool) {
        return record[sectionData[indexPath.section].startIndex + indexPath.row]
    }
    
    func getAbbreviation(_ indexPath:IndexPath) -> String {
        return record[sectionData[indexPath.section].startIndex + indexPath.row].abbr
    }
    
    func getDescription(_ indexPath:IndexPath) -> String {
        return record[sectionData[indexPath.section].startIndex + indexPath.row].descJp
    }
    
    func getSecond(_ indexPath:IndexPath) -> Int {
        let index = sectionData[indexPath.section].startIndex + indexPath.row
        let h = record[index].hour
        let m = record[index].minute
        let s = ((h * 60) + m) * 60 * record[index].sign
        return s
    }
    
    func getSectionTitleCount() -> Int {
        return sectionData.count
    }
    
    func getSectionTitleCountInSection(_ section:Int) -> Int {
        return sectionData[section].count
    }

    func getSectionTitle() -> [String] {
        return sectionData.map { $0.title }
    }

    func getSectionTitle(_ section:Int) -> String {
        return sectionData[section].title
    }

    func isChecked() -> IndexPath? {
        for section in 0..<sectionData.count {
            for row in 0..<sectionData[section].count {
                let i = sectionData[section].startIndex + row
                if record[i].check { return IndexPath(row: row, section: section) }
            }
        }
        return nil
    }

    func isChecked(_ indexPath:IndexPath) -> Bool {
        let ix = sectionData[indexPath.section].startIndex + indexPath.row
        return record[ix].check
    }

    mutating func setChecked(_ indexPath:IndexPath, _ check:Bool) {
        let index = sectionData[indexPath.section].startIndex + indexPath.row
        record[index].check = check
    }
}
