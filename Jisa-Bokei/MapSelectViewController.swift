//
//  MapSelectViewController.swift
//  Jisa-Bokei
//
//  Created by 小沢克治 on 2017/12/02.
//  Copyright © 2017年 Private. All rights reserved.
//

import UIKit
import MapKit

class MapSelectViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //緯度、経度を皇居で決め打ちにしてる
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(35.68154,139.752498)
        //MapViewに表示する座標を設定
        mapView.setCenter(location, animated: true)
        
        //表示するマップの中心座標を設定
        var region: MKCoordinateRegion = mapView.region
        region.center = location
        
        //地図の拡大状態の設定
        //設定しないと地図の表示が最縮小された状態でマップが表示されるので、理由がない限りは設定した方がいい
        region.span.latitudeDelta = 0.2
        region.span.longitudeDelta = 0.2
        
        //regionに設定したマップの表示設定をMapViewに反映
        mapView.setRegion(region, animated: true)
        
        //地図の形式, デフォルト値はStandard:地図
        mapView.mapType = MKMapType.standard
        mapView.delegate = self
        
        //ジェスチャー設定
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(objClongPressGesture(_:)))
        mapView.addGestureRecognizer(longPress)
    }

    @objc func objClongPressGesture(_ sender: UILongPressGestureRecognizer) {
        longPressGesture(sender)
    }
    
    private func longPressGesture(_ sender: UILongPressGestureRecognizer) {
        if (sender.state == .ended) {
            //マップビュー内のタップした位置を取得する。
            let location:CGPoint = sender.location(in: sender.view)
            if (sender.view != nil  && sender.view is MKMapView) {
                drawPin(location,sender.view as! MKMapView)
            }
        }
    }
    
    private func drawPin(_ pos:CGPoint,_ target:MKMapView) {
        
        //タップした位置を緯度、経度の座標に変換する。
        let mapPoint:CLLocationCoordinate2D = target.convert(pos, toCoordinateFrom: target)
        
        // 逆ジオコーディング
        let location = CLLocation(latitude: mapPoint.latitude, longitude: mapPoint.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks:[CLPlacemark]!, error:Error!) -> Void in
            if (error == nil && placemarks.count > 0) {
                let placemark = placemarks[0] as CLPlacemark
                for pm in placemarks {
                    self.printOptional("country",pm.country)
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
                //ピンを作成してマップビューに登録する。
                let annotation = MKPointAnnotation()
                print("annotations.count = \(target.annotations.count)")
                if (target.annotations.count > 0) {
                    for an in target.annotations {
                        target.removeAnnotation(an)
                    }
                }
                
                annotation.coordinate = CLLocationCoordinate2DMake(mapPoint.latitude, mapPoint.longitude)
                var address:String?
                if (placemark.administrativeArea != nil) {
                    address = placemark.administrativeArea!
                }
                if (placemark.locality != nil) {
                    address = address! + placemark.locality!
                }
                if (placemark.subLocality != nil) {
                    address = address! + placemark.subLocality!
                }
                annotation.title = address
                if #available(iOS 9.0, *) {
                    if (placemark.timeZone != nil) {
                        annotation.subtitle = "TimeZone = '\(String(describing: placemark.timeZone!))'"
                    }
                } else {
                    // Fallback on earlier versions
                }
                target.addAnnotation(annotation)
            } else if (error == nil && placemarks.count == 0) {
                print("No results were returned.")
            } else if (error != nil) {
                print("An error occured = \(error.localizedDescription)")
            }
        } as CLGeocodeCompletionHandler)
        
    }
    
    private func printOptional(_ varName:String, _ str:String?) {
        if (str != nil) {
            print("\(varName) = '\(str!)'")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            view.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure)
        }
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        self.performSegue(withIdentifier: "toDatetimeSelectSegue2", sender: nil)
//        let storyboard: UIStoryboard = self.storyboard!
//        let nextView = storyboard.instantiateViewController(withIdentifier: "DatetimeSelectionView")
//        present(nextView, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDatetimeSelectSegue2" {
//            let secondViewController = segue.destination as! DatetimeSelectViewController
//            secondViewController.parameters = sender as! [String : String]
        }
    }

    // 戻ってきた時の処理
    @IBAction func goBack(unwindSegue: UIStoryboardSegue) {
        print("unwindSegue.identifier = '\(String(describing: unwindSegue.identifier))'")
        if unwindSegue.identifier == "Done" {
        } else if unwindSegue.identifier == "Cancel" {
        }
    }
}
