//
//  DataViewController.swift
//  Jisa-Bokei
//
//  Created by Katsuji Ozawa on 2019/08/17.
//  Copyright © 2019 Private. All rights reserved.
//

import UIKit

class DataViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {

    //
    let userDefaults = UserDefaults.standard        // UserDefaults のインスタンス

    //
    var reuseIdentifier    : String        = ""     // テーブルビューのID
    var insertMode         : Bool          = false  // 挿入モードか否か（true:挿入モード、false:更新モード）
    var insertData         : BaseGridData? = nil    // 挿入時用データ
    var actionCellIndexPath: IndexPath?    = nil    // アクション対象セルのインデックス
    var tableView          : UITableView!           // テーブルビュー
    
    // テーブルビューのロード
    override func viewDidLoad() {
        print("DataViewController:viewDidLoad call! reuseIdentifier='\(reuseIdentifier)'")
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        // テーブルビューの設定
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = false                   // trueで複数選択、falseで単一選択
//        tableView.rowHeight = UITableView.automaticDimension      // セルの高さ自動調整
//        tableView.estimatedRowHeight = 40;

        // ナビゲーションメニューの設定
        navigationController?.delegate = self
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        //　スワイプバックジェスチャー禁止
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    // 編集モード切り替え（メニューボタン）
    override func setEditing(_ editing: Bool, animated: Bool) {
        print("DataViewController:setEditing call.")
        super.setEditing(editing, animated: animated)
        tableView.isEditing = editing
    }

    // 各セルの設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        // Set up the cell
        return cell
    }

    // 各indexPathのcellがタップされた際に呼び出されます．
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("DataViewController:tableView(didSelectRowAt): indexPath=\(indexPath)")
        // タップ後すぐ非選択状態にするには下記メソッドを呼び出します．
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
/*
    // セル高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(CONST.DATAVIEW_ROWHEIGHT)
    }
*/
    // セル並べ替えの設定（有効化）
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        let n = tableView.numberOfRows(inSection: indexPath.section)
//        print("DataViewController: tableView(canMoveRowAt): isEditing=\(isEditing), n=\(n)")
        // Return false if you do not want the specified item to be editable.
        return !isEditing ? false : (!(n == 1))
    }

    // 編集モード時のアクション設定
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let space = String(repeating:" ", count:8)
        // 削除メニュー
        let deleteAction = UITableViewRowAction(style: .destructive, title: space) { (action: UITableViewRowAction, idx: IndexPath) in
            self.actionCellIndexPath = idx
            self.deleteData(tableView, indexPath)
            tableView.reloadData()
        }
        self.fixAction(deleteAction, text: CONST.DELETE, image: UIImage(named: IMAGE.TRASH)!, color: .white, bgColor: .red)

        // 追加メニュー
        let insertAction = UITableViewRowAction(style: .normal, title: space) { (action: UITableViewRowAction, idx: IndexPath) in
            self.actionCellIndexPath = idx
            self.insertData(indexPath)
            tableView.reloadData()
        }
        self.fixAction(insertAction, text: CONST.INSERT, image: UIImage(named: IMAGE.INSERT)!, color: .white)

        // 更新メニューを追加
        let updateAction = UITableViewRowAction(style: .normal, title: space) { (action: UITableViewRowAction, idx: IndexPath) in
            self.actionCellIndexPath = idx
            self.updateData(indexPath)
            tableView.reloadData()
        }
        self.fixAction(updateAction, text: CONST.UPDATE, image: UIImage(named: IMAGE.UPDATE)!, color: .white)

        // 作成済みのセル数によってボタンの付加内容を変える
        let nRows = tableView.numberOfRows(inSection: indexPath.section)
        print("DataViewController:tableView(editActionsForRowAt) call! reuseIdentifier='\(reuseIdentifier)', nRows=\(nRows)")

        // セクション内セル数が１個の場合は削除メニューはなし
        if nRows == 1 {
            return [insertAction, updateAction]
        } else {
            // セクション内セル数がMAX値の場合は追加メニューはなし
            if  reuseIdentifier == ID.CELL.CLOCK && nRows == CONST.CLOCK_MAX  ||
                reuseIdentifier == ID.CELL.CALC  && indexPath.section == 0 && nRows == CONST.SECTION0_MAX ||
                reuseIdentifier == ID.CELL.CALC  && indexPath.section == 1 && nRows == CONST.SECTION1_MAX
            {
                return [deleteAction, updateAction]
            }
            else
            {
                return [deleteAction, insertAction, updateAction]
            }
        }
    }

    private func fixAction(_ action:UITableViewRowAction, text:String, image:UIImage, color:UIColor, bgColor: UIColor = .gray) {
        // make sure the image is a mask that we can color with the passed color
        let mask = image.withRenderingMode(.alwaysTemplate)
        // compute the anticipated width of that non empty string
        let stockSize = action.title!.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)])
        // I know my row height
        let height:CGFloat = CGFloat(CONST.DATAVIEW_ROWHEIGHT)
        // Standard action width computation seems to add 15px on either side of the text
        let width = (stockSize.width + 30)
        let actionSize = CGSize(width: width, height: height)
        // lets draw an image of actionSize
        UIGraphicsBeginImageContextWithOptions(actionSize, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            context.clear(CGRect(origin: .zero, size: actionSize))
        }
        color.set()
        let attributes = [NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: UIFont(name: "Avenir-Book", size: 10)]
        let textSize = text.size(withAttributes: attributes as [NSAttributedString.Key : Any])
        // implementation of `half` extension left up to the student
        let textPoint = CGPoint(x: (width - textSize.width)/2, y: (height - (textSize.height * 3))/2 + (textSize.height * 2))
        text.draw(at: textPoint, withAttributes: attributes as [NSAttributedString.Key : Any])
        let  maskHeight = textSize.height * 2
        let maskRect = CGRect(x: (width - maskHeight)/2, y: textPoint.y - maskHeight, width: maskHeight, height: maskHeight)
        mask.draw(in: maskRect)
        if let result = UIGraphicsGetImageFromCurrentImageContext() {
            // adjust the passed in action's backgroundColor to a patternImage
            action.backgroundColor = UIColor(patternImage: result.withBackground(color: bgColor))
        }
        UIGraphicsEndImageContext()
    }

    //
    // サブクラス
    //

    // 前画面終了時のビュー再描画
    func updateView() {
        print("DataViewController:updateView:insertMode=\(self.insertMode)")
        // 編集モード終了
        self.setEditing(false, animated: true)
        // テーブル再読み込み
        self.tableView.reloadData()
        //
    }

    //
    // サブクラス override用ダミー関数
    //

    // セクションの個数を指定
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    // 各セクションごとのセル数を返却
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    // セクションタイトルの設定
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }

    // グリッドデータ設定
    func setCellData(_ base: BaseGridData) {
        print("DataViewController: setCellData call!")
    }

    // セル並べ替えの処理
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        print("DataViewController: tableView(moveRowAt) call!")
    }
        
    // セル削除の処理
    func deleteData(_ tableView: UITableView,_ indexPath: IndexPath) {
        print("DataViewController: deleteData call!")
    }

    // セル追加の処理
    func insertData(_ indexPath: IndexPath) {
        print("DataViewController: insertData call!")
    }
    
    // セル更新の処理
    func updateData(_ indexPath: IndexPath) {
        print("DataViewController: updateDate call!")
    }
    
}

extension UIImage {
    func tint(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        let drawRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIRectFill(drawRect)
        draw(in: drawRect, blendMode: .destinationIn, alpha: 1)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return tintedImage
    }
    func withBackground(color: UIColor, opaque: Bool = true) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
            
        guard let ctx = UIGraphicsGetCurrentContext(), let image = cgImage else { return self }
        defer { UIGraphicsEndImageContext() }
            
        let rect = CGRect(origin: .zero, size: size)
        ctx.setFillColor(color.cgColor)
        ctx.fill(rect)
        ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
        ctx.draw(image, in: rect)
            
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}
