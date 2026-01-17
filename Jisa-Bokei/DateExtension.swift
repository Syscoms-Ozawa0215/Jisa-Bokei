//
//  DateExtension.swift
//  Jisa-Bokei
//
//  Created by 小沢克治 on 2018/11/24.
//  Copyright © 2018年 Private. All rights reserved.
//

import Foundation

public extension Date {
    func getDateFormatter(_ template:DateFormatter.Template,_ timeZoneID:String?) -> DateFormatter {
        let format = DateFormatter()
        format.setTemplate(template)
        if timeZoneID != nil {
            format.timeZone = TimeZone(identifier: timeZoneID!)
        }
        return format
    }
    func toString(_ template:DateFormatter.Template,_ timeZoneID:String?) -> String {
        var abbr = ""
        if timeZoneID != nil {
            if let timeZone = TimeZone(identifier: timeZoneID!) {
                abbr = " " + timeZone.abbreviation()!.description
            }
        }
        return setString(getDateFormatter(template, timeZoneID), abbr)
    }
    func getDateFormatter(_ template:DateFormatter.Template,_ timeZone:TimeZone?) -> DateFormatter {
        let format = DateFormatter()
        format.setTemplate(template)
        if timeZone != nil {
            format.timeZone = timeZone
        }
        return format
    }
    func toString(_ template:DateFormatter.Template,_ timeZone:TimeZone?) -> String {
        var abbr = ""
        if timeZone != nil {
            abbr = " " + timeZone!.abbreviation()!
        }
        return setString(getDateFormatter(template, timeZone), abbr)
    }
    func getDateFormatter(_ template:DateFormatter.Template,_ secondFromGMT:Int) -> DateFormatter {
        let format = DateFormatter()
        format.setTemplate(template)
        format.timeZone = TimeZone(secondsFromGMT: secondFromGMT)
        return format
    }
    func toString(_ template:DateFormatter.Template,_ secondFromGMT:Int) -> String {
        let format = getDateFormatter(template, secondFromGMT)
        let abbr = " " + format.timeZone!.abbreviation()!
        return setString(format, abbr)
    }
    private func setString(_ fmt:DateFormatter, _ abr:String) -> String {
        let userDefaults = UserDefaults.standard
        if userDefaults.integer(forKey: .DISPLAY_TIMEDIFF) == MODE.TIMEDIFF.UTC {
            return fmt.string(from: self) + abr
        } else {
            return fmt.string(from: self)
        }
    }
}

public extension DateFormatter {
    // テンプレートの定義
    enum Template: String {
        case full = "ydMMM kmm"
        case fullTZ = "ydMMM kmm ZZZZ"
        case fullJP = "ydMMM HH時mm分"        // 使えないのでダミー設定
        case fullJPTZ = "ydMMM HH時mm分 ZZZZ" // 使えないのでダミー設定
    }
    // 冗長な関数のためラップ
    func setTemplate(_ template: Template) {
        // 端末の言語設定値をロケールで使用
        let languageID = NSLocale.preferredLanguages[0]
        let locale = Locale(identifier: languageID)
        // optionsは拡張のためにあるが使用されていない引数
        if languageID.components(separatedBy: "-").first == "ja" {
//            print("Test-1")
            if template == .fullJP {
                dateFormat = "yyyy年MM月dd日 HH時mm分"
            } else if template == .fullJPTZ {
                dateFormat = "yyyy年MM月dd日 HH時mm分 ZZZZ"
            } else {
                dateFormat = DateFormatter.dateFormat(fromTemplate: template.rawValue, options: 0, locale: locale)
            }
        } else {
//            print("Test-2:template=\(template)")
            dateFormat = DateFormatter.dateFormat(fromTemplate: template.rawValue, options: 0, locale: locale)
        }
//        self.dateStyle = .full
//        self.timeStyle = .short
    }

}
