//
//  StationsViewController.swift
//  EPLife
//
//  Created by Louis on 2018/6/3.
//  Copyright © 2018年 louis. All rights reserved.
//

import UIKit

class StationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func goAreaList(_ sender: UIButton) {
        performSegue(withIdentifier: "GoAreaList", sender: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Init"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
