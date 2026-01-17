//
//  ListSelectViewController.swift
//  Jisa-Bokei
//
//  Created by 小沢克治 on 2017/12/02.
//  Copyright © 2017年 Private. All rights reserved.
//

import UIKit

class ListSelectViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource {

    var tapPos: (use  : Bool, section: Int, row: Int) = (false, 0, 0)
    var check : (exist: Bool, section: Int, row: Int) = (false, 0, 0)

    // セクションの個数を指定
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    // セクションごとの行数を指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (areas[section].count)
    }

    // セクションのタイトルを指定
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    // セルのコンテンツを指定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if cell.detailTextLabel == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
        }
        let section = indexPath.section
        let row = indexPath.row
        cell.textLabel?.text = areas[section][row].country
        cell.detailTextLabel?.text = areas[section][row].datetime
        if gridIndex != 0 {
            cell.accessoryType = areas[section][row].checked ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        }
        return cell
    }

    // セル選択された時に実行するメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tapPos.section = indexPath.section
        tapPos.row = indexPath.row
        tapPos.use = true
        if gridIndex != 0 {
            tableViewCellChecked(tableView, indexPath: indexPath)
        } else {
            // 日時選択用詳細画面に遷移
            self.performSegue(withIdentifier: "toDatetimeSelectSegue1", sender: areas[indexPath.section][indexPath.row].country)
        }
        // セルの選択状態を解除
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    func tableViewCellChecked(_ tableView: UITableView, indexPath: IndexPath) {
        // 既存のチェックがあればOff
        if check.exist == true {
            areas[check.section][check.row].checked = false
            check.exist = false
            tableView.cellForRow(at: IndexPath(row:check.row, section:check.section))?.accessoryType = .none
            if check.section == indexPath.section && check.row == indexPath.row {
                return
            }
        }

        // チェックマークOn
        if let cell = tableView.cellForRow(at:indexPath) {
            cell.accessoryType = .checkmark
            areas[indexPath.section][indexPath.row].checked = true
            check.exist = true
            check.row = indexPath.row
            check.section = indexPath.section
        }
    }

    @IBOutlet weak var tableView: UITableView!
    
    // Table View Cellの識別子
    let cellIdentifier = "Cell"
    let checkedImage: UIImage! = UIImage(named: "checked")
    let uncheckedImage: UIImage! = UIImage(named: "unchecked")

    // 前後画面とのパラメタ
    var gridIndex = 0               // タップされたグリッドのインデックス

    // 地域データベース
    private let sections = ["あ","い","う"]
    private var areas: [[(country: String, checked: Bool, datetime: String)]] = [
        [
            ("アイスランド", false, ""),
            ("アイルランド", false, ""),
            ("アゼルバイジャン", false, ""),
            ("アセンション島", false, ""),
            ("アフガニスタン", false, ""),
            ("アメリカ合衆国", false, ""),
            ("アラブ首長国連邦", false, ""),
            ("アルジェリア", false, ""),
            ("アルゼンチン", false, ""),
            ("アルバ", false, ""),
            ("アルバニア", false, ""),
            ("アルメニア", false, ""),
            ("アンギラ", false, ""),
            ("アンゴラ", false, ""),
            ("アンティグア・バーブーダ", false, ""),
            ("アンドラ", false, "")
        ],
        [
            ("イエメン", false, ""),
            ("イギリス", false, ""),
            ("イスラエル", false, ""),
            ("イタリア", false, ""),
            ("イラク", false, ""),
            ("イラン", false, ""),
            ("インド", false, ""),
            ("インドネシア", false, "")
        ],
        [
            ("ウォリス・フツナ", false, ""),
            ("ウガンダ", false, ""),
            ("ウクライナ", false, ""),
            ("ウズベキスタン", false, ""),
            ("ウルグアイ", false, "")
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        // Do any additional setup after loading the view, typically from a nib.

        // Table View Cellの登録
//        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
//        tableView.register(cell.classForCoder, forCellReuseIdentifier: cellIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        // trueで複数選択、falseで単一選択
        tableView.allowsMultipleSelection = false

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toDatetimeSelectSegue1" {
            let datetimeSelectViewController = segue.destination as! DatetimeSelectViewController
            datetimeSelectViewController.parameter.areaName = sender as? String
        }
    }

    // 戻ってきた時の処理
    @IBAction func goBack(unwindSegue: UIStoryboardSegue) {
        guard unwindSegue.identifier != nil else {
            print("unwindSegue.identifier is nil")
            return
        }
        print("unwindSegue.identifier = '\(unwindSegue.identifier!)'")
        guard tapPos.use == true else {
            print("tapPos is unused")
            return
        }
        let datetimeSelectVC = unwindSegue.source as! DatetimeSelectViewController
        guard datetimeSelectVC.labelDatetime.text != nil else {
            print("datetimeSelectVC.labelDatetime.text = nil")
            return
        }
        let cell = tableView.cellForRow(at: IndexPath(row: tapPos.row, section: tapPos.section))
        guard cell != nil else {
            print("cell(tapPos(row=\(tapPos.row),section=\(tapPos.section)) = nil")
            return
        }
        if unwindSegue.identifier! == "Done" {
            // 既存の設定があればクリア
            if check.exist == true {
                areas[check.section][check.row].datetime = ""
                check.exist = false
                tableView.cellForRow(at: IndexPath(row:check.row, section:check.section))?.detailTextLabel?.text = ""
            }
            // 日時設定
            areas[tapPos.section][tapPos.row].datetime = datetimeSelectVC.labelDatetime.text!
            cell!.detailTextLabel?.text = areas[tapPos.section][tapPos.row].datetime
            check.exist = true
            check.section = tapPos.section
            check.row = tapPos.row
            tableView.setNeedsLayout()
        } else if unwindSegue.identifier! == "Cancel" {
        }
    }
}

/*
class MyCell: UITableViewCell {
//    var myLabel: UILabel!
//    var myImage: UIImage!
//    var myImageView: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.value1, reuseIdentifier: reuseIdentifier)
        
//        myLabel = UILabel(frame: CGRect.zero)
//        myLabel.textAlignment = .left
//        contentView.addSubview(myLabel)
        
//        myImage = UIImage(named: "maguro.jpg")
//        myImageView = UIImageView(image: myImage)
//        contentView.addSubview(myImageView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        myLabel.frame = CGRect(x: 110, y: 0, width: frame.width - 100, height: frame.height)
//        myImageView.frame = CGRect(x: 0, y: 0, width: 100, height: frame.height)
    }
    
}
*/
