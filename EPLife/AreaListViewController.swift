//
//  AreaListViewController.swift
//  EPLife
//
//  Created by Louis on 2018/6/3.
//  Copyright © 2018年 louis. All rights reserved.
//

import UIKit

class AreaListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var areaListView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    
    let area = ["萬華區","大安區","信義區"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton.layer.cornerRadius = 20.0
        areaListView.layer.cornerRadius = 20.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return area.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AreaTableViewCell
        cell.areaName.text = area[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(area[indexPath.row])
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
