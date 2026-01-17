//
//  TimezoneViewController.swift
//  Jisa-Bokei
//
//  Created by 小沢克治 on 2020/11/07.
//  Copyright © 2020 Private. All rights reserved.
//

import UIKit

class TimezoneViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource {

    //　都市選択ビューコントローラー
    var citySelectViewController: CitySelectViewController? = nil

    private var abbreviations = Abbreviation.shared
    
    @IBOutlet weak var timezoneTableView: UITableView!
    
    override func viewDidLoad() {
        print("TimezoneViewController:viewDidLoad call.")
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        timezoneTableView.dataSource = self
        timezoneTableView.delegate   = self
        timezoneTableView.allowsMultipleSelection = false                   // trueで複数選択、falseで単一選択
    }

    override func viewDidAppear(_ animated: Bool) {
        print("TimezoneViewController:viewDidAppear call.")
        super.viewDidAppear(animated)
        // 親ビューコントローラー取得
        citySelectViewController = self.parent as? CitySelectViewController
        guard let vc = citySelectViewController else {
            print("TimezoneViewController: viewDidAppear: self.parent = nil")
            abort()
        }

        // 設定ボタン無効化
        vc.setButton.isEnabled = false
  
        //
        var insMode = true
        switch vc.prmVC {
        case is CalculationViewController:
            let vc2 = vc.prmVC as! CalculationViewController
            insMode = vc2.insertMode
        case is ClockViewController:
            let vc2 = vc.prmVC as! ClockViewController
            insMode = vc2.insertMode
        case is SelectBaseViewController:
            let vc2 = vc.prmVC as! SelectBaseViewController
            if vc2.parent is CalculationViewController {
                let vc3 = vc2.parent as! CalculationViewController
                insMode = vc3.insertMode
            } else if vc2.parent is ClockViewController {
                let vc3 = vc2.parent as! ClockViewController
                insMode = vc3.insertMode
            }
        default:
            abort()
        }
        if !insMode {
            let id = vc.prmBaseData!.getRecordID()
            abbreviations.setChecked(IndexPath(row: id%100, section:id/100 ), true)
        }
    }

    // MARK: - Table view data source

    // セクション数を返却
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return abbreviations.getSectionTitleCount()
    }

    // セクション内セル数を返却
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let n = abbreviations.getSectionTitleCountInSection(section)
//        print("TimezoneViewController:tableView(numberOfRowInSection):n=\(n)")
        return n
    }

    // セクションタイトルを返却
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return abbreviations.getSectionTitle(section)
    }

    //セクション名の配列を返す
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return abbreviations.getSectionTitle()
    }

    // セル内容の設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("TimezoneViewController:tableView(cellForRowAt): indexPath=\(indexPath)")
        var cell = timezoneTableView.dequeueReusableCell(withIdentifier: ID.CELL.TIMEZONE, for: indexPath)
        if cell.detailTextLabel == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: ID.CELL.TIMEZONE)
        }
        
        // Configure the cell...
        let rec = abbreviations.getRecord(indexPath)
        let gmt = (abbreviations.getSecond(indexPath) == 0) ? "GMT" : String(format: "GMT%+03d:%02d", (rec.sign*rec.hour),rec.minute)
        cell.textLabel?.text = rec.abbr + " (" + gmt + ")"
        cell.detailTextLabel?.text = rec.descJp
        cell.accessoryType = abbreviations.isChecked(indexPath) ? .checkmark : .none
        
        return cell
    }

    // セル選択された時に実行するメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("TimezoneViewController:tableView(didSelectRowAt): indexPath=\(indexPath)")
        // チェックマーク更新
        tableViewCellChecked(tableView, indexPath: indexPath)
        // セルの選択状態を解除
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    // チェックマークの更新
    func tableViewCellChecked(_ tableView: UITableView, indexPath: IndexPath) {

        // 設定ボタン無効化
        citySelectViewController!.setButton.isEnabled = false

        // 既存のチェックがあればOff
        if let ix = abbreviations.isChecked() {
            // DB上のチェックをクリア
            abbreviations.setChecked(ix, false)

            // 表示上のチェックマークOff
            for cell in tableView.visibleCells {
                if cell.accessoryType == .checkmark {
                    cell.accessoryType = .none
                    break
                }
            }

            // 自分自身なら終了
            if ix == indexPath {
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
            // 更新データ(パラメタ)セット
            let data = citySelectViewController!.copyBaseData!
            let record = abbreviations.getRecord(indexPath)
            data.setCountry      (record.abbr)                            // 略称
            data.setCity         (record.descJp)                          // 名称（日本語）
            data.setRecordID     (indexPath.section*100+indexPath.row)    // セル位置
            data.setSecondFromGMT(record.sign, record.hour, record.minute)// 時差（GMTからの秒数）
            // データ更新
            abbreviations.setChecked(indexPath, true)
            tableView.reloadData()
        }

    }

}
