//
//  PinStatus.swift
//  EPLife
//
//  Created by Louis on 2018/6/6.
//  Copyright © 2018年 louis. All rights reserved.
//

import Foundation
import MapKit

class Capital: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }
}
