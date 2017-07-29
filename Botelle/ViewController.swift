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
    var pay_for_goods: UIButton!
    var checkedItemArray: [IndexPath]!


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
        
        pay_for_goods = UIButton(frame: CGRect(x: 10, y: self.view.frame.height-100, width: self.view.frame.width-20, height: 40))
        pay_for_goods.backgroundColor = UIColor.blue
        pay_for_goods.setTitle("Pay for Goods", for: UIControlState.normal)
        pay_for_goods.setTitleColor(UIColor.white, for: UIControlState.normal)
        pay_for_goods.isHidden = true
        pay_for_goods.addTarget(self, action: #selector(paidForGroceries), for: UIControlEvents.touchUpInside)
        self.view.addSubview(pay_for_goods)
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            self.tableView.beginUpdates()
            self.groceriesList[Array(groceriesList.keys)[indexPath.section]]?.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let section_text = tableView.headerView(forSection: indexPath.section)?.textLabel?.text
        if (section_text == email_name) {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView.headerView(forSection: indexPath.section)?.textLabel?.text! != email_name) {
            if let cell = tableView.cellForRow(at: indexPath) {
                if (cell.accessoryType == .none) {
                    cell.accessoryType = .checkmark
                    if (checkedItemArray == nil) {
                        checkedItemArray = [indexPath]
                    } else {
                        checkedItemArray.append(indexPath)
                    }
                    pay_for_goods.isHidden = false
                } else {
                    // Remove checkeditem from our list
                    for i in 0...checkedItemArray.count {
                        if (indexPath == checkedItemArray[i]) {
                            checkedItemArray.remove(at: i)
                            break
                        }
                    }
                    cell.accessoryType = .none
                }
            }
            if (checkedItemArray.isEmpty) {
                pay_for_goods.isHidden = true
            }
            print(checkedItemArray)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groceriesList[Array(groceriesList.keys)[section]]!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
        
        let information = groceriesList[Array(groceriesList.keys)[indexPath.section]]?[indexPath.row].characters.split(separator: ":").map(String.init)
        
        cell.textLabel?.text = information![0]
        cell.detailTextLabel?.text = information![1]
        
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
    
    func paidForGroceries() {
        var items: [String] = []
        var price: Float = 0
        for i in checkedItemArray {
            items.append((tableView.cellForRow(at: i)?.textLabel?.text)!)
            price += Float((tableView.cellForRow(at: i)?.detailTextLabel?.text)!)!
        }
        price += 2
        
        let text_items = items.joined(separator: " and ")
        
        let alertView = UIAlertController(title: "Confirm", message: "Are you paying for \(text_items) at $\(price)?", preferredStyle: UIAlertControllerStyle.alert)
        
        let yes = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { (alertAction) in
            
        }
        
        let no = UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil)
        
        alertView.addAction(no)
        alertView.addAction(yes)
        
        self.present(alertView, animated: true, completion: nil)
    }
    
}

