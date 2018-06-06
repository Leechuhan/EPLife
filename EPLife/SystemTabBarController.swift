//
//  SystemTabBarController.swift
//  EPLife
//
//  Created by Louis on 2018/6/2.
//  Copyright © 2018年 louis. All rights reserved.
//

import UIKit
import MapKit

class SystemTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        sleep(3)
        self.tabBar.unselectedItemTintColor = UIColor.white
        self.tabBar.backgroundImage = UIImage(named: "UnderBar")
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
