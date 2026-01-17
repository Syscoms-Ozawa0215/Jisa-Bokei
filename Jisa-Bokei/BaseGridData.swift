//
//  BaseGridData.swift
//  Jisa-Bokei
//
//  Created by 小沢克治 on 2018/03/14.
//  Copyright © 2018年 Private. All rights reserved.
//

import Foundation

class BaseGridData {

    // メンバ変数
    private var select_kind    : Int       = 0              // 選択種類（0:地域選択, 1:地図選択, 2:時差選択）
    private var country        : String?   = nil            // 国名（地域/地図）/ 略称（時差）
    private var countryCode    : String?   = nil            // 国コード（地域/地図）
    private var city           : String?   = nil            // 都市名（地域/地図）/ 日本語名称（時差）
    private var longtitude     : Double?   = nil            // 経度（地域/地図）
    private var latitude       : Double?   = nil            // 緯度（地域/地図）
    private var longtitude_span: Double?   = nil            // 経度方向拡大率（地図）
    private var latitude_span  : Double?   = nil            // 緯度方向拡大率（地図）
    private var datetime       : Date?     = nil            // 日時（GMT/UTC）
    private var timezone       : TimeZone? = nil            // 指定都市のタイムゾーン（地域/地図）
    private var record_ID      : Int       = 0              // レコードID（地域）/セル位置（時差）
    private var secondFromGMT  : Int       = 0              // GMTからの時差（秒、時差）

    // Getter
    func getKind()           -> Int       { return self.select_kind          }
    func getCountry()        -> String?   { return self.country              }
    func getCountryCode()    -> String?   { return self.countryCode          }
    func getCity()           -> String?   { return self.city                 }
    func getLatitude()       -> Double?   { return self.latitude             }
    func getLongtitude()     -> Double?   { return self.longtitude           }
    func getLatitudeSpan()   -> Double?   { return self.latitude_span        }
    func getLongtitudeSpan() -> Double?   { return self.longtitude_span      }
    func getDate()           -> Date?     { return self.datetime             }
    func getTimezone()       -> TimeZone? { return self.timezone             }
    func getTimezoneID()     -> String?   { return self.timezone?.identifier }
    func getRecordID16()     -> Int16     { return Int16(self.record_ID)     }
    func getRecordID()       -> Int       { return self.record_ID            }
    func getSecondFromGMT()  -> Int       { return self.secondFromGMT        }

    func getDateStr() -> String? {
        return self.datetime?.toString(getTimeStyle(), self.timezone)
    }

    func getDateStr2() -> String? {
        return self.datetime?.toString(getTimeStyle(), self.secondFromGMT)
    }

    func getDateStr(_ null:String) -> String {
        if self.isDateSet() {
            return self.datetime!.toString(getTimeStyle(), self.timezone)
        } else {
            return null
        }
    }

    private func getTimeStyle() -> DateFormatter.Template {
        let userDefaults = UserDefaults.standard
        if userDefaults.integer(forKey: .TIME_STYLE) == MODE.TIMESTYLE.STANDARD {
            return .full
        } else {
            return .fullJP
        }
    }
    
    func getCityStr(_ null:String) -> String {
        if self.isCitySet() {
            return self.city! + " (" + self.country! + ")"
        } else {
            return null
        }
    }
    
    // Setter
    func set(source tzIDModel:TimeZoneIDModel) {
        self.record_ID   = Int(tzIDModel.id)
        self.city        = tzIDModel.city_name
        self.country     = tzIDModel.country_name
        self.countryCode = tzIDModel.countryCode
        self.latitude    = tzIDModel.latitude
        self.longtitude  = tzIDModel.longtitude
    }
    
    func set(_ source: BaseGridData) {
        self.select_kind     = source.select_kind
        self.city            = source.city
        self.country         = source.country
        self.countryCode     = source.countryCode
        self.latitude        = source.latitude
        self.longtitude      = source.longtitude
        self.latitude_span   = source.latitude_span
        self.longtitude_span = source.longtitude_span
        self.datetime        = source.datetime
        self.timezone        = source.timezone
        self.record_ID       = source.record_ID
        self.secondFromGMT   = source.secondFromGMT
    }

    func setKind          (_ kind          :Int    ) { self.select_kind     = kind           }
    func setCountry       (_ country       :String?) { self.country         = country        }
    func setCountryCode   (_ code          :String?) { self.countryCode     = code           }
    func setCity          (_ city          :String?) { self.city            = city           }
    func setLatitude      (_ latitude      :Double ) { self.latitude        = latitude       }
    func setLongtitude    (_ longtitude    :Double ) { self.longtitude      = longtitude     }
    func setLatitudeSpan  (_ latitudeSpan  :Double ) { self.latitude_span   = latitudeSpan   }
    func setLongtitudeSpan(_ longtitudeSpan:Double ) { self.longtitude_span = longtitudeSpan }
    func setDate          (_ date          :Date   ) { self.datetime        = date           }

    func setDate(_ date:Date,_ timeZoneID:String?) {
        self.datetime = date
        self.timezone = timeZoneID != nil ? TimeZone(identifier: timeZoneID!) : nil
    }
    
    func setDate(_ date:Date,_ secFromGMT:Int) {
        self.datetime = date
        self.timezone = TimeZone(secondsFromGMT: secFromGMT)
    }
    
    func setDate(_ date:Date,_ timeZone:TimeZone) {
        self.datetime = date
        self.timezone = timeZone
    }
    
    func setTimezone(_ timezone: TimeZone) { self.timezone = timezone }
    func setTimezone(_ secFromGMT: Int) { self.timezone = TimeZone(secondsFromGMT: secFromGMT) }
    func setTimezone(_ timezoneID: String?) {
        self.timezone = (timezoneID != nil ? TimeZone(identifier: timezoneID!) : nil)
    }
        
    func setRecordID(_ recordID: Int16) { self.record_ID = Int(recordID) }
    func setRecordID(_ recordID: Int)   { self.record_ID = recordID      }

    func setSecondFromGMT(_ secFromGMT:Int) { self.secondFromGMT = secFromGMT }
    func setSecondFromGMT(_ sign:Int,_ hour:Int,_ minutes:Int) {
        self.secondFromGMT = (hour * 60 + minutes) * 60 * sign
    }
    
    // 判定用
    func isCitySet() -> Bool {
        return ((self.country != nil && self.city != nil))
    }
    
    func isDateSet() -> Bool {
        return ((self.datetime != nil && self.timezone != nil))
    }
    func isDataSet() -> Bool {
        return (self.isCitySet() && self.isDateSet())
    }

    // インスタンスコピー
    func Copy() -> BaseGridData {
        let newInstance = BaseGridData()
        newInstance.select_kind     = self.select_kind
        newInstance.city            = self.city
        newInstance.country         = self.country
        newInstance.countryCode     = self.countryCode
        newInstance.latitude        = self.latitude
        newInstance.longtitude      = self.longtitude
        newInstance.latitude_span   = self.latitude_span
        newInstance.longtitude_span = self.longtitude_span
        newInstance.datetime        = self.datetime
        newInstance.timezone        = self.timezone
        newInstance.record_ID       = self.record_ID
        newInstance.secondFromGMT   = self.secondFromGMT
        return newInstance
    }
}
