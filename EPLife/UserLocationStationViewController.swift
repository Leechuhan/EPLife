//
//  UserLocationStationViewController.swift
//  EPLife
//
//  Created by Louis on 2018/6/2.
//  Copyright © 2018年 louis. All rights reserved.
//

import UIKit
import MapKit

class UserLocationStationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var informationBackground: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var informationView: UIImageView!
    @IBOutlet weak var informationViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeButtonConstrain: NSLayoutConstraint!
    @IBOutlet weak var stationStatus: UIImageView!
    
    let manager = CLLocationManager()
    var coordinate = CLLocationCoordinate2D()
    var distance = Double()
    
    var moveTimer = Timer()
    var isShow = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        managerSetting()
        downloadNtcInformation()
        informationViewConstraint.constant = -(informationView.frame.height)
    }
    
    func managerSetting() {
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    
    //取得使用者當下位置
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        coordinate = (locations.last?.coordinate)!
        let viewSpin = MKCoordinateSpan(latitudeDelta: 0.021, longitudeDelta: 0.021)
        let region = MKCoordinateRegion(center: coordinate, span: viewSpin)
        mapView.setRegion(region, animated: true)
        showCircule()
    }
    
    //加入範圍圓形圖示，設定範圍大小
    func showCircule() {
        if self.mapView.overlays.count != 0 {
            for i in self.mapView.overlays {
                self.mapView.remove(i)
            }
        } else {
            let circle = MKCircle(center: coordinate, radius: 1000)
            self.mapView.add(circle)
        }
    }
    
    //設定範圍圓形渲染顏色
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = UIColor.gray.withAlphaComponent(0.3)
        return renderer
    }
    
    //更換大頭針圖案
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Capital"
        if annotation is Capital {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            let capital = annotationView.annotation as! Capital
            annotationView.image = UIImage(named: capital.info)
            annotationView.canShowCallout = false
            return annotationView
        } else {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.image = UIImage(named: "UserLocation")
            annotationView.canShowCallout = false
            return annotationView
        }
    }
    
    //選擇大頭針查看詳細資訊
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        stationStatus.isHidden = false
        informationBackground.isHidden = false
        startInformationViewMove()
    }
    
    @IBAction func close(_ sender: UIButton) {
        closeButton.isHidden = true
        informationBackground.isHidden = true
        startInformationViewMove()
    }
    
    func startInformationViewMove() {
        var position = 0.0
        moveTimer = Timer.scheduledTimer(withTimeInterval: 0.0005, repeats: true, block: { (timer) in
            if self.isShow == true {
                if self.informationViewConstraint.constant > -(self.informationView.frame.height) {
                    position += 1.0
                    self.informationViewConstraint.constant = CGFloat(0.5 - position)
                } else {
                    self.stationStatus.isHidden = true
                    self.isShow = false
                    self.stoptInformationViewMove()
                }
            } else {
                if self.informationViewConstraint.constant < 0.0 {
                    position += 1.0
                    self.informationViewConstraint.constant = -(self.informationView.frame.height) + CGFloat(position)
                } else {
                    self.closeButton.isHidden = false
                    self.isShow = true
                    self.stoptInformationViewMove()
                }
            }
        })
    }
    
    func stoptInformationViewMove() {
        moveTimer.invalidate()
    }
    
    func downloadNtcInformation() {
        let information = "http://data.ntpc.gov.tw/od/data/api/54DDDC93-589C-4858-9C95-18B2046CC1FC?$format=json"
        let apiURL = URL(string: information)
        let session = URLSession.shared
        let dataDask = session.dataTask(with: apiURL!) { (data, response, error) in
            if error == nil {
                let responseStatus = response as! HTTPURLResponse
                if responseStatus.statusCode == 200 {
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [[String:Any]] {
                        for j in json {
                            let lat = j["lat"] as! String
                            let lon = j["lng"] as! String
                            let sna = j["sna"] as! String
//                            let snaen = j["snaen"] as! String
                            let carNums = j["sbi"] as! String
                            let totalSpace = j["tot"] as! String
//                            let act = j["act"] as! String
                            
                            let userCoordinate = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
                            let stationCoordinate = CLLocation(latitude: Double(lat)!, longitude: Double(lon)!)
                            self.distance = userCoordinate.distance(from: stationCoordinate)
                            
                            //顯示距離使用者一公里內的租借站
                            if self.distance <= 1000.0 {
                                if Int(carNums)! <= 5 {
                                    let lessStationCoordinate = CLLocationCoordinate2DMake(Double(lat)!, Double(lon)!)
                                    let a = Capital(title: sna, coordinate: lessStationCoordinate, info: "LessPin")
                                    self.mapView.addAnnotation(a)
                                } else if Int(carNums)! > 5 && Int(carNums)! <= (Int(totalSpace)! / 2) {
                                    let normalStationCoordinate = CLLocationCoordinate2DMake(Double(lat)!, Double(lon)!)
                                    let a = Capital(title: sna, coordinate: normalStationCoordinate, info: "NormalPin")
                                    self.mapView.addAnnotation(a)
                                } else if Int(carNums)! > (Int(totalSpace)! / 2) {
                                    let fullStationCoordinate = CLLocationCoordinate2DMake(Double(lat)!, Double(lon)!)
                                    let a = Capital(title: sna, coordinate: fullStationCoordinate, info: "FullPin")
                                    self.mapView.addAnnotation(a)
                                }
                            }
                        }
                    }
                }
            }
        }
        dataDask.resume()
    }
    
    //    func downLoadGogoroBatteryStation() {
    //        let information = "https://wapi.gogoro.com/tw/api/vm/list"
    //        let apiURL = URL(string: information)
    //        let session = URLSession.shared
    //        let dataDask = session.dataTask(with: apiURL!) { (data, response, error) in
    //            if error == nil {
    //                let responseStatus = response as! HTTPURLResponse
    //                if responseStatus.statusCode == 200 {
    //                    if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any] {
    //                        let stationData = json["data"] as! [[String:Any]]
    //                        for i in 0...stationData.count - 1 {
    //                            if i == 0 {
    //                                print(stationData[i]["LocName"]!)
    //                                print(stationData[i]["LocName"] as! [String:Any])
    //                                break
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //        dataDask.resume()
    //    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
