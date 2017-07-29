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
    
    var myArray: [String] = []
    let ref = Database.database().reference()
    var list_name: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logoutItem = UIBarButtonItem(title: "Log Out", style: UIBarButtonItemStyle.plain, target: self, action: #selector(logout))
        self.navigationItem.leftBarButtonItem = logoutItem
        
        let addItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addGrocery))
        self.navigationItem.rightBarButtonItem = addItem
        self.title = "Botelle"
        
        let email_name = (Auth.auth().currentUser?.email)!.replacingOccurrences(of: ".", with: "_")
        ref.child("Users/\(email_name)/list").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! NSString
            self.list_name = value as String!
            self.ref.child("Shopping List/\(value)/grocery_list").observe(DataEventType.value, with: { (snapshot2) in
                if let value2 = snapshot2.value! as? [String] {
                    self.myArray = value2
                    self.tableView.reloadData()
                }
            })
        })
    
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (list_name != nil) {
            ref.child("Shopping List/\(list_name!)/grocery_list").setValue(myArray)
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
            self.myArray.remove(at: indexPath.row) // Check this out
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.endUpdates()
        }
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

