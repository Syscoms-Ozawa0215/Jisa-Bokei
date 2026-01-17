//
//  SelectBaseViewController.swift
//  Jisa-Bokei
//
//  Created by 小沢克治 on 2020/09/26.
//  Copyright © 2020 Private. All rights reserved.
//

import UIKit

class SelectBaseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, DatePickerCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    var isPickerHidden: Bool = true
    
    // パラメタ
    var prmBaseData  : BaseGridData? = nil       // 選択したセルのデータ

    override func viewDidLoad() {
        super.viewDidLoad()

        // 戻るボタンのハンドリング用
        navigationController?.delegate = self
        
        //　スワイプバックジェスチャー禁止
        navigationController!.interactivePopGestureRecognizer!.isEnabled = false

        // タイトル設定
        self.navigationItem.title = TITLE.SECTION0

        // trueで複数選択、falseで単一選択
        tableView.allowsMultipleSelection = false
        
    }

    // 前画面に戻る場合の判定
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        //
        switch viewController {
        case is CalculationViewController:
            let vc = viewController as! CalculationViewController
            // 終了時処理
            vc.updateView()
        case is ClockViewController:
            let vc = viewController as! ClockViewController
            // 終了時処理
            vc.updateView()
        default:
            // 前画面から現画面に移動してきた時
            print("SelectViewController:viewController=\(viewController)")
        }
    }

    // DatePickerの設定値を日時セルに反映して表示を更新（カスタムセルから呼び出し）
    func setDate(dt: Date) {
        print("SelectViewController:setDate")
        // 日時を設定値に更新
        prmBaseData!.setDate(dt, prmBaseData!.getTimezoneID())
        //テーブルビュー再表示
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    // セクション数
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    // セクション内行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (isPickerHidden ? 2 : 3)
    }

    // 各セル値の設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("SelectBaseViewController:tableView(cellForRowAt): indexPath=\(indexPath)")
        guard let base = prmBaseData else {
            abort()
        }
        
        // Configure the cell...
        if indexPath.row == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: ID.CELL.AREA, for: indexPath)
            if cell.detailTextLabel == nil {
                cell = UITableViewCell(style: .value1, reuseIdentifier: ID.CELL.AREA)
            }
            cell.detailTextLabel?.text = base.getCityStr(CONST.NOT_SET)
           return cell
        } else if indexPath.row == 1 {
            var cell = tableView.dequeueReusableCell(withIdentifier: ID.CELL.DATETIME, for: indexPath)
            if cell.detailTextLabel == nil {
                cell = UITableViewCell(style: .value1, reuseIdentifier: ID.CELL.DATETIME)
            }
            cell.detailTextLabel?.text = base.getDateStr(CONST.NOT_SET)
            cell.detailTextLabel?.textColor = base.isCitySet() ? .systemBlue : .white
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ID.CELL.DATEPICKER, for: indexPath) as! DatePickerCell
            cell.datePickerCellDelegate = self
            if base.isDateSet() {
                cell.pickDatetime.date     = base.getDate()!
                cell.pickDatetime.timeZone = base.getTimezone()
            }
            return cell
        }
    }
    
    // セル選択された時に実行するメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("SelectBaseViewController:tableView(didSelectRowAt): indexPath=\(indexPath)")
        if indexPath.row == 0 {
            // 移動先のviewcontrollerを選択
            let storyboard: UIStoryboard = self.storyboard!
            let next = storyboard.instantiateViewController(withIdentifier: ID.STORYBOARD.CITY_SELECT) as! CitySelectViewController
            next.prmBaseData = self.prmBaseData
            next.prmTitle    = TITLE.SECTION0
            next.prmVC       = self
            self.present(next, animated: true, completion: nil)
        } else if indexPath.row == 1 {
            let base = prmBaseData!
            // 押すたびに表示切り替え
            isPickerHidden = !isPickerHidden
            // 日時を設定値に更新
            if base.getTimezone() != nil {
                base.setDate(base.getDate() ?? Date(), base.getTimezoneID())
            } else {
                base.setDate(base.getDate() ?? Date(), base.getSecondFromGMT())
            }
            //テーブルビュー再表示
            tableView.reloadData()
        } else if indexPath.row == 2 {
            // 
        }
        // セルの選択状態を解除
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 {
            return CGFloat(CONST.DATEPICKER_ROWHEIGHT)
        } else {
            return CGFloat(CONST.BASECELL_ROWHEIGHT)
        }
    }

}
