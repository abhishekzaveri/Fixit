//
//  TableViewController.swift
//  Filterer
//
//  Created by Cyrus on 2/1/17.
//  Copyright © 2017 Cyrus. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

 
  @IBOutlet var tableView: UITableView!
  
  let filters = ["Red", "Blue", "Green", "Yellow",]
  
  override func viewDidLoad() {
      super.viewDidLoad()
      tableView.dataSource = self
      tableView.delegate = self
      // Do any additional setup after loading the view.
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print(filters[indexPath.row])
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return filters.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
    
    cell.textLabel?.text = filters[indexPath.row]
    return cell
  }
  
}
