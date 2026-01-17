//
//  ClockTableViewCell.swift
//  Jisa-Bokei
//
//  Created by 小沢克治 on 2020/10/21.
//  Copyright © 2020 Private. All rights reserved.
//

import UIKit

class ClockTableViewCell: UITableViewCell {
 
    @IBOutlet weak var flagImage           : UIImageView!
    @IBOutlet weak var summerTimeImage     : UIImageView!
    @IBOutlet weak var datetimeLabel       : UILabel!
    @IBOutlet weak var areaLabel           : UILabel!
    @IBOutlet weak var horizontalStackView : UIStackView!
    @IBOutlet weak var summerTimeImageWidth: NSLayoutConstraint!
    
    // セルのConfigration
    func configureCell(_ data: BaseGridData) {

        let countryName    = data.getCountry()    ?? "Unknown"    // 国名/略称
        let cityName       = data.getCity()       ?? "Unknown"    // 都市名/名称（日本語）
        var isDayLightTime = false
        
        var style:DateFormatter.Template!
        let userDefaults = UserDefaults.standard
        if userDefaults.integer(forKey: .TIME_STYLE) == MODE.TIMESTYLE.STANDARD {
            style = .full
        } else {
            style = .fullJP
        }
        if data.getKind() == MODE.SELECT.ABBREVIATION {
            // 国旗イメージ
            flagImage.image = UIImage(named: IMAGE.NO_IMAGE)
            if cityName.localizedStandardContains("夏時間") {
                isDayLightTime = true
            }
            // 現在日時（現地時間）
            datetimeLabel.text = Date().toString(style, data.getSecondFromGMT())
            // 地域名
            areaLabel.text = cityName + " (" + countryName + ")"
        } else {
            // 国旗イメージ
            let countryCode = data.getCountryCode() ?? "Unknown"
            flagImage.image = UIImage(named: countryCode) ?? UIImage(named: IMAGE.NO_IMAGE)
            // サマータイムアイコン
            if let timezone = data.getTimezone() {
                if timezone.isDaylightSavingTime(for: Date()) {
                    isDayLightTime = true
                }
            }
            // 現在日時（現地時間）
            let timeZoneID = data.getTimezoneID() ?? "Unknown"
            datetimeLabel.text = Date().toString(style, timeZoneID)
            // 地域名
            areaLabel.text = cityName + " (" + countryName + ")"
        }
        if isDayLightTime {
            // サマータイム中（アイコン表示）
            summerTimeImage.image = UIImage(named: IMAGE.SUMMER)?.tint(color: .systemYellow)
            summerTimeImageWidth.constant = 24
            horizontalStackView.spacing = 4
        } else {
            // サマータイム外（アイコン非表示）
            summerTimeImageWidth.constant = 0
            horizontalStackView.spacing = 0
        }
    }

}
