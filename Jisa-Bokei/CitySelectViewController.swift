//
//  CitySelectViewController.swift
//  Jisa-Bokei
//
//  Created by 小沢克治 on 2018/03/04.
//  Copyright © 2018年 Private. All rights reserved.
//

import UIKit

class CitySelectViewController: UIViewController {

    // UserDefaults のインスタンス
    let userDefaults = UserDefaults.standard
    
    // パラメタ
    var prmBaseData : BaseGridData?     = nil       // 選択したセルのデータ
    var prmTitle    : String            = ""        // タイトル
    var prmVC       : UIViewController? = nil       // 呼び出し元ViewController

    // 設定用データ
    var copyBaseData: BaseGridData?     = nil

    // storyboardとの関連づけ
    @IBAction func selectType(_ sender: UISegmentedControl) {
        containerView.bringSubviewToFront(subView[sender.selectedSegmentIndex])
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var selectType   : UISegmentedControl!
    @IBOutlet weak var labelTitle   : UILabel!
    @IBOutlet weak var setButton    : UIBarButtonItem!
    @IBOutlet      var subView      : [UIView]!
    
    @IBAction func CancelButton(_ sender: UIBarButtonItem) {
        print("CitySelectViewController:CancelButton")
        // 前画面が一覧表示の場合、再計算とテーブル再読み込み及び編集モードの解除
        switch prmVC {
        case is CalculationViewController:
            print("CitySelectViewController:CancelButton-1")
            let vc = prmVC as! CalculationViewController
            vc.setEditing(false, animated: true)
            vc.tableView.reloadData()
        case is ClockViewController:
            print("CitySelectViewController:CancelButton-2")
            let vc = prmVC as! ClockViewController
            vc.setEditing(false, animated: true)
            vc.tableView.reloadData()
        case is SelectBaseViewController:
            print("CitySelectViewController:CancelButton-3")
            let vc = prmVC as! SelectBaseViewController
            vc.tableView.reloadData()
        default:
            abort()
        }
        // 現画面を閉じる
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func SetButton(_ sender: UIBarButtonItem) {
        print("CitySelectViewController:SetButton")
        // 編集用から元インスタンスへ転記
        prmBaseData!.set(copyBaseData!)
        prmBaseData!.setKind(selectType.selectedSegmentIndex)
        // 前画面が一覧表示の場合、再計算とテーブル再読み込み及び編集モードの解除
        switch prmVC {
        case is CalculationViewController:
            //print("CitySelectViewController:SetButton-1")
            let vc = prmVC as! CalculationViewController
            vc.reCalcDate()
            vc.updateView()
        case is ClockViewController:
            //print("CitySelectViewController:SetButton-2")
            let vc = prmVC as! ClockViewController
            vc.updateView()
        case is SelectBaseViewController:
            // 前画面が選択ベース画面の場合、テーブル再読み込みのみ
            //print("CitySelectViewController:SetButton-3")
            let vc = prmVC as! SelectBaseViewController
            vc.tableView.reloadData()
        default:
            abort()
        }
        // 現画面を閉じる
        self.dismiss(animated: true, completion: nil)
    }

    // ビューロード
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let base = prmBaseData else {
            abort()
        }

        // 前画面が時計画面だった場合、タイマーを止める
        if prmVC is ClockViewController {
            let clockVC = prmVC as! ClockViewController
            clockVC.timerControlOff()
        }

        // インスタンスコピー（編集用）
        copyBaseData = base.Copy()

        // 選択種類に応じたビューを表示
        selectType.selectedSegmentIndex = base.getKind()
        containerView.bringSubviewToFront(subView[selectType.selectedSegmentIndex])

        // タイトル設定
        labelTitle.text = prmTitle

    }

    //
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
