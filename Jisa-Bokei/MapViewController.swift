//
//  MapViewController.swift
//  Jisa-Bokei
//
//  Created by 小沢克治 on 2018/03/04.
//  Copyright © 2018年 Private. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    //　都市選択ビューコントローラー
    var citySelectViewController: CitySelectViewController? = nil
    
    //
    var mapType = [MKMapType.standard          //
                  ,MKMapType.satellite         //
                  ,MKMapType.hybrid            //
                  ,MKMapType.satelliteFlyover  //
                  ,MKMapType.hybridFlyover     //
                  ]
    var n = 0

    // 関連づけ
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapTypeChange: UIButton!
    @IBAction func mapTypeChanged(_ sender: Any) {
        n += 1
        if n >= mapType.count { n = 0 }
        mapView.mapType = mapType[n]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        if #available(iOS 11.0, *) {
            mapType.append(MKMapType.mutedStandard)
        }

        // 地図の形式, デフォルト値はStandard:地図
        mapView.mapType = MKMapType.standard
        mapView.delegate = self
        
        // 長押しジェスチャー設定
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(setPin))
        mapView.addGestureRecognizer(longPress)
    }

    override func viewDidAppear(_ animated: Bool) {
        print("MapViewController:viewDidAppear call.")
        super.viewDidAppear(animated)
        // 親ビューコントローラー取得
        citySelectViewController = self.parent as? CitySelectViewController
        guard let vc = citySelectViewController else {
            print("MapViewController: viewDidAppear: self.parent = nil")
            abort()
        }
        guard let base = vc.copyBaseData else {
            print("MapViewController: viewDidAppear: citySelectViewController.copyBaseData = nil")
            abort()
        }

        // 設定ボタン無効化
        vc.setButton.isEnabled = false

        // 既存の設定があれば初期値にする
        // 緯度、経度を設定
        if  let latitude   = base.getLatitude(),
            let longtitude = base.getLongtitude() {
            //　MapViewに表示する座標を設定
            let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude,longtitude)
            mapView.setCenter(location, animated: true)
            //　表示するマップの中心座標を設定
            var region: MKCoordinateRegion = mapView.region
            region.center = location
            //　地図の拡大状態の設定
            if let latitudeSpan = base.getLatitudeSpan() {
                region.span.latitudeDelta = latitudeSpan
            }
            if let longtitudeSpan = base.getLongtitudeSpan() {
                region.span.longitudeDelta = longtitudeSpan
            }
            // regionに設定したマップの表示設定をMapViewに反映
            mapView.setRegion(region, animated: true)
            // ピンを描画
            drawPin(pos:location)
        }
     }

    @objc func setPin(_ sender: UIGestureRecognizer) {
        guard let view = sender.view else {
            print("MapViewController:setPin:sender.view is nil.")
            abort()
        }
        if (sender.state == .ended) {
            //マップビュー内のタップした位置を取得する。
            let location:CGPoint = sender.location(in: view)
            if view is MKMapView {
                let mapView = view as! MKMapView
                //タップした位置を緯度、経度の座標に変換する。
                let mapPoint:CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: view)
                drawPin(pos:mapPoint)
            }
        }
    }

    private func drawPin(pos mapPoint:CLLocationCoordinate2D) {

        //
        let target = self.mapView!
        let vc     = citySelectViewController!

        // 逆ジオコーディング
        let location = CLLocation(latitude: mapPoint.latitude, longitude: mapPoint.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks:[CLPlacemark]!, error:Error!) -> Void in
            if (error == nil && placemarks.count > 0) {
                let placemark = placemarks[0] as CLPlacemark
                //----- for debug start -----
                for pm in placemarks {
                    self.printOptional("country",pm.country)
                    self.printOptional("countryCode",pm.isoCountryCode)
                    self.printOptional("administrativeArea",pm.administrativeArea)
                    self.printOptional("subAdministrativeArea",pm.subAdministrativeArea)
                    self.printOptional("locality",pm.locality)
                    self.printOptional("subLocality",pm.subLocality)
                    self.printOptional("thoroughfare",pm.thoroughfare)
                    self.printOptional("subThoroughfare",pm.subThoroughfare)
                    self.printOptional("name",pm.name)
                    self.printOptional("inlandwater",pm.inlandWater)
                    self.printOptional("ocean",pm.ocean)
                    if #available(iOS 9.0, *) {
                        if (pm.timeZone != nil) {
                            self.printOptional("timeZone",String(describing: pm.timeZone!))
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                    print("----------")
                }
                //----- for debug end -----

                // 既存のピンがあれば削除
                let annotation = MKPointAnnotation()
                print("MapViewController:drawPin:target.annotations.count=\(target.annotations.count)")
                if (target.annotations.count > 0) {
                    for an in target.annotations {
                        target.removeAnnotation(an)
                    }
                }

                // ピンを作成してマップビューに登録する。
                annotation.coordinate = CLLocationCoordinate2DMake(mapPoint.latitude, mapPoint.longitude)
                let country     = self.getCountryName(placemark)
                let city        = self.getCityName(placemark)
                let countryCode = placemark.isoCountryCode ?? "Unknown"
                if country != "Unknown" && city != "Unknown" && placemark.timeZone != nil {
                    if let base = vc.copyBaseData {
                        base.setCountry       (country)
                        base.setCountryCode   (countryCode)
                        base.setCity          (city)
                        base.setLatitude      (mapPoint.latitude)
                        base.setLongtitudeSpan(mapPoint.longitude)
                        base.setLatitudeSpan  (target.region.span.latitudeDelta)
                        base.setLongtitudeSpan(target.region.span.longitudeDelta)
                        base.setTimezone      (placemark.timeZone!)
                        base.setRecordID      (0)
                        // 設定ボタン有効化
                        vc.setButton.isEnabled = true
                    }
                }
                let address:String = "\(city) / \(country)"
                annotation.title = address
                target.addAnnotation(annotation)
            } else if (error == nil && placemarks.count == 0) {
                print("MapViewController: drawPin: No results were returned.")
            } else if (error != nil) {
                print("MapViewController: drawPin: An error occured = \(error.localizedDescription)")
            }
            } as CLGeocodeCompletionHandler)

    }

    private func getCountryName(_ placeMark:CLPlacemark) -> String {
        return placeMark.country ?? "Unknown"
    }

    private func getCityName(_ placeMark:CLPlacemark) -> String {

        guard let countryName = placeMark.country else {
            return "Unknown"
        }

        switch countryName {
        case "日本":
            var cityName = ""
            let prefName = placeMark.administrativeArea
            let city     = placeMark.locality
            if prefName != nil {
                cityName = prefName!
            }
            if city != nil {
                cityName = cityName + city!
            }
            if cityName == "" {
                cityName = "Unknown"
            }
            return cityName
        default:
            if placeMark.locality != nil {
                return placeMark.locality!
            } else {
                if placeMark.administrativeArea != nil {
                    return placeMark.administrativeArea!
                } else {
                    return "Unknown"
                }
            }
        }

    }

    private func printOptional(_ varName:String, _ str:String?) {
        print("\(varName) = '\(str ?? "nil")'")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
