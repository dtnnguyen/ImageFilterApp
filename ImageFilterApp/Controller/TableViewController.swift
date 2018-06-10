//
//  TableViewController.swift
//  ImageFilterApp
//
//  Created by Trang Nguyen on 2017-04-10.
//  Copyright © 2017 Trang Nguyen. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    // this the data of the table view
    let filters = ["red", "blue", "green", "yellow", "purple", "orange", "turquoi", "white", "black"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // one section right
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        
        cell.textLabel?.text = filters[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print (filters[indexPath.row])
    }

}
