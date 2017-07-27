//
//  ViewController.swift
//  Botelle
//
//  Created by nhanover on 7/25/17.
//  Copyright © 2017 Botelle. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    let myArray = [1,2,3]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addGrocery))
        self.navigationItem.rightBarButtonItem = addItem
        self.title = "Botelle"
    
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        print("Value: \(myArray[indexPath.row])")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        cell.textLabel!.text = "\(myArray[indexPath.row])"
        return cell
    }
    
    func addGrocery() {
        self.navigationController?.pushViewController(addGroceryController(), animated: true)
    }
    
}

