//
//  ViewController.swift
//  Botelle
//
//  Created by nhanover on 7/25/17.
//  Copyright © 2017 Botelle. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ViewController: UITableViewController {
    
    var groceriesList: [String: [String]]!
    let ref = Database.database().reference()
    var list_name: String!
    let email_name = (Auth.auth().currentUser?.email)!.replacingOccurrences(of: ".", with: "_")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logoutItem = UIBarButtonItem(title: "Log Out", style: UIBarButtonItemStyle.plain, target: self, action: #selector(logout))
        self.navigationItem.leftBarButtonItem = logoutItem
        
        let addItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addGrocery))
        self.navigationItem.rightBarButtonItem = addItem
        self.title = "Botelle"
        
        groceriesList = [email_name: []]
        
        ref.child("Users/\(email_name)/list").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! NSString
            self.list_name = value as String!
            self.ref.child("Shopping List/\(value)/grocery_list").observe(DataEventType.value, with: { (snapshot2) in
                if let value2 = snapshot2.value! as? NSDictionary {
                    self.groceriesList = value2 as! [String : [String]]
                    self.tableView.reloadData()
                }
            })
        })
    
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (list_name != nil) {
            ref.child("Shopping List/\(list_name!)/grocery_list/\(email_name)").setValue(groceriesList[email_name])
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            self.tableView.beginUpdates()
            self.groceriesList[Array(groceriesList.keys)[indexPath.section]]?.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView.headerView(forSection: indexPath.section)?.textLabel?.text! != email_name) {
            if let cell = tableView.cellForRow(at: indexPath) {
                if (cell.accessoryType == .none) {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groceriesList[Array(groceriesList.keys)[section]]!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        cell.textLabel!.text = "\((groceriesList[Array(groceriesList.keys)[indexPath.section]]?[indexPath.row])!)"
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return groceriesList.keys.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(groceriesList.keys)[section]
    }
    
    func addGrocery() {
        self.navigationController?.pushViewController(addGroceryController(), animated: true)
    }
    
    func logout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.present(UINavigationController(rootViewController: LoginViewController()), animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
}

