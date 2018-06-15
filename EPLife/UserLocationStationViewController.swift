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
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var informationBackground: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var informationView: UIImageView!
    @IBOutlet weak var informationViewConstraint: NSLayoutConstraint!
//    @IBOutlet weak var closeButtonConstrain: NSLayoutConstraint!
    @IBOutlet weak var stationStatus: UIImageView!
    
    @IBOutlet weak var stationName: UILabel!
    @IBOutlet weak var carsNum: UILabel!
    @IBOutlet weak var parkNum: UILabel!
    
    let manager = CLLocationManager()
    var coordinate = CLLocationCoordinate2D()
    var distance = Double()
    
    var moveTimer = Timer()
    var isShow = Bool()
    
    var ntcStationAnnotations = [MKAnnotation]()
    var tcStationAnnotations = [MKAnnotation]()
    
    let application = UIApplication.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(initData), name: NSNotification.Name(rawValue: "Init"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dismissPage), name: NSNotification.Name(rawValue: "DismissPage"), object: nil)
        
        initData()
    }
    
    @objc func initData() {
        informationViewConstraint.constant = -(informationView.frame.height)
        stationStatus.isHidden = true
        closeButton.isHidden = true
        isShow = false
        informationBackground.isHidden = false
        informationView.isHidden = true
        loading.isHidden = false
        loading.startAnimating()
        managerSetting()
        downloadNtcInformation()
        downloadTcInformation()
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
            showCircule()
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
        informationBackground.isHidden = true
        loading.isHidden = true
        loading.stopAnimating()
        
        if annotation is MKUserLocation {
            return MKAnnotationView()
        } else {
            let resueID = "Pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: resueID)
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: resueID)
            let status = (annotation.title!)!.components(separatedBy: ",")[2]
            switch status {
            case "LessPin" :
                pinView?.image = UIImage(named: "LessPin")
            case "NormalPin" :
                pinView?.image = UIImage(named: "NormalPin")
            case "FullPin" :
                pinView?.image = UIImage(named: "FullPin")
            default :
                break
            }
            return pinView
        }
    }
    
    //選擇大頭針查看詳細資訊
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let status = (view.annotation?.title!)!.components(separatedBy: ",")[2]
        let CnName = (view.annotation?.title!)!.components(separatedBy: ",")[0]
        let EnName = (view.annotation?.title!)!.components(separatedBy: ",")[1]
        let cars = (view.annotation?.title!)!.components(separatedBy: ",")[3]
        let spaces = (view.annotation?.title!)!.components(separatedBy: ",")[4]
        
        switch status {
        case "LessPin":
            stationStatus.image = UIImage(named: "Less")
        case "NormalPin":
            stationStatus.image = UIImage(named: "Normal")
        case "FullPin":
            stationStatus.image = UIImage(named: "Full")
        default:
            break
        }
        
        stationName.text = "\(EnName)\n\(CnName)"
        carsNum.text = cars
        parkNum.text = spaces
        
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
                    self.informationView.isHidden = true
                    self.stationStatus.isHidden = true
                    self.isShow = false
                    self.stoptInformationViewMove()
                }
            } else {
                self.informationView.isHidden = false
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
    
    @objc func downloadNtcInformation() {
        let information = "http://data.ntpc.gov.tw/od/data/api/54DDDC93-589C-4858-9C95-18B2046CC1FC?$format=json"
        let apiURL = URL(string: information)
        let session = URLSession.shared
        let dataDask = session.dataTask(with: apiURL!) { (data, response, error) in
            if error == nil {
                let responseStatus = response as! HTTPURLResponse
                if responseStatus.statusCode == 200 {
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [[String:Any]] {
                        for j in json {
                            let act = j["act"] as! String
                            if act == "1" {
                                let lat = j["lat"] as! String
                                let lon = j["lng"] as! String
                                let lat_n = lat.trimmingCharacters(in: .whitespaces)
                                let lon_n = lon.trimmingCharacters(in: .whitespaces)
                                let sna = j["sna"] as! String
                                let snaen = j["snaen"] as! String
                                let carsNum = j["sbi"] as! String
                                let totalSpace = j["tot"] as! String
                                let spacesNum = j["bemp"] as! String
                                let userCoordinate = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
                                let stationCoordinate = CLLocation(latitude: Double(lat_n)!, longitude: Double(lon_n)!)
                                self.distance = userCoordinate.distance(from: stationCoordinate)
                                
                                let annotation = MKPointAnnotation()
                                
                                //顯示距離使用者一公里內的租借站
                                if self.distance <= 1000.0 {
                                    if Int(carsNum)! <= 5 {
                                        annotation.coordinate = CLLocationCoordinate2D(latitude: Double(lat_n)!, longitude: Double(lon_n)!)
                                        annotation.title = "\(sna),\(snaen),LessPin,\(carsNum),\(spacesNum)"
                                        self.ntcStationAnnotations.append(annotation)
                                    } else if Int(carsNum)! > 5 && Int(carsNum)! <= (Int(totalSpace)! / 2) {
                                        annotation.coordinate = CLLocationCoordinate2D(latitude: Double(lat_n)!, longitude: Double(lon_n)!)
                                        annotation.title = "\(sna),\(snaen),NormalPin,\(carsNum),\(spacesNum)"
                                        self.ntcStationAnnotations.append(annotation)
                                    } else if Int(carsNum)! > (Int(totalSpace)! / 2) {
                                        annotation.coordinate = CLLocationCoordinate2D(latitude: Double(lat_n)!, longitude: Double(lon_n)!)
                                        annotation.title = "\(sna),\(snaen),FullPin,\(carsNum),\(spacesNum)"
                                        self.ntcStationAnnotations.append(annotation)
                                    }
                                }
                                
                            }
                        }
                        DispatchQueue.main.async {
                            self.mapView.addAnnotations(self.ntcStationAnnotations)
                        }
                    }
                }
            }
        }
        dataDask.resume()
    }
    
    //台北市youbike資料庫
    func downloadTcInformation() {
        let information = "http://data.taipei/youbike"
        let apiURL = URL(string: information)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: apiURL!, completionHandler: { (data, response, error) in
            if error == nil {
                let responseStatus = response as! HTTPURLResponse
                if responseStatus.statusCode == 200 {
                    let json = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                    let retVal = json["retVal"] as! [String:Any]
                    for (_,value) in retVal {
                        let j = value as! [String:Any]
                        let act = j["act"] as! String
                        if act == "1" {
                            let lat = j["lat"] as! String
                            let lon = j["lng"] as! String
                            let lat_n = lat.trimmingCharacters(in: .whitespaces)
                            let lon_n = lon.trimmingCharacters(in: .whitespaces)
                            let sna = j["sna"] as! String
                            let snaen = j["snaen"] as! String
                            let carsNum = j["sbi"] as! String
                            let spacesNum = j["bemp"] as! String
                            let totalSpace = j["tot"] as! String
                            
                            let userCoordinate = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
                            let stationCoordinate = CLLocation(latitude: Double(lat_n)!, longitude: Double(lon_n)!)
                            self.distance = userCoordinate.distance(from: stationCoordinate)
                            
                            let annotation = MKPointAnnotation()
                            
                            //顯示距離使用者一公里內的租借站
                            if self.distance <= 1000.0 {
                                if Int(carsNum)! <= 5 {
                                    annotation.coordinate = CLLocationCoordinate2D(latitude: Double(lat_n)!, longitude: Double(lon_n)!)
                                    annotation.title = "\(sna),\(snaen),LessPin,\(carsNum),\(spacesNum)"
                                    self.ntcStationAnnotations.append(annotation)
                                } else if Int(carsNum)! > 5 && Int(carsNum)! <= (Int(totalSpace)! / 2) {
                                    annotation.coordinate = CLLocationCoordinate2D(latitude: Double(lat_n)!, longitude: Double(lon_n)!)
                                    annotation.title = "\(sna),\(snaen),NormalPin,\(carsNum),\(spacesNum)"
                                    self.ntcStationAnnotations.append(annotation)
                                } else if Int(carsNum)! > (Int(totalSpace)! / 2) {
                                    annotation.coordinate = CLLocationCoordinate2D(latitude: Double(lat_n)!, longitude: Double(lon_n)!)
                                    annotation.title = "\(sna),\(snaen),FullPin,\(carsNum),\(spacesNum)"
                                    self.ntcStationAnnotations.append(annotation)
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.mapView.addAnnotations(self.tcStationAnnotations)
                    }
                }
            }
        })
        dataTask.resume()
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
    
    @objc func dismissPage() {
        manager.stopUpdatingLocation()
        
        if ntcStationAnnotations.count != 0 {
            mapView.removeAnnotations(ntcStationAnnotations)
            ntcStationAnnotations = []
        }
        
        if tcStationAnnotations.count != 0 {
            mapView.removeAnnotations(tcStationAnnotations)
            tcStationAnnotations = []
        }
        
        //退回背景時將資訊頁init
        if isShow == true {
            informationViewConstraint.constant = -(informationView.frame.height)
            informationView.isHidden = true
            stationStatus.isHidden = true
            closeButton.isHidden = true
            isShow = false
            informationBackground.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        dismissPage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
}
