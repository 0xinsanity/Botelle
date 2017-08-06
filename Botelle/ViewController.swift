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
import Stripe
import Material

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SearchBarDelegate {
    
    var groceriesList: [String: [String]]!
    let ref = Database.database().reference()
    var list_name: String!
    let email_name = (Auth.auth().currentUser?.email)!.replacingOccurrences(of: ".", with: "_")
    var pay_for_goods: RaisedButton!
    var checkedItemArray: [IndexPath]!
    var keys: [String]! = []
    var logoutItem: UIBarButtonItem!
    var add: IconButton!
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
        
        //navShadow()
        navigationController?.isMotionEnabled = true
        
        logoutItem = UIBarButtonItem(title: "Log Out", style: UIBarButtonItemStyle.plain, target: self, action: #selector(logout))
        logoutItem.tintColor = teal
        self.navigationItem.leftBarButtonItem = logoutItem
        
        add = IconButton(image: Icon.cm.add)
        add.tintColor = teal
        add.addTarget(self, action: #selector(addGrocery), for: UIControlEvents.touchUpInside)
        navigationItem.rightViews = [add]
        
        groceriesList = ["My List": []]
        // TODO: Figure out how to get my list to appear first
        keys.append("My List")
        
        ref.child("Users/\(email_name)").observeSingleEvent(of: .value, with: { (snapshot) in
            let full_name = ((snapshot.value! as? NSDictionary)?["full_name"] as? String)!
            if let svalue = (snapshot.value! as? NSDictionary)?["lists"] as? [String] {
                self.list_name = svalue[0] as String!
                self.navigationController?.navigationBar.topItem?.title = self.list_name
                self.ref.child("Shopping List/\(self.list_name!)/requests").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                    // TODO: Implement request system
                    //if let users_notinputted = snapshot.value as? [String] {
                    //for user_notinputted in users_notinputted {
                            //if (user_notinputted == self.email_name) {
                                // TODO: Figure out what to do when not permitted yet
                                self.ref.child("Shopping List/\(self.list_name!)/").observe(DataEventType.value, with: { (snapshot2) in
                                    if let value2 = (snapshot2.value! as? NSDictionary) {
                                        let grocery_people = value2["grocery_list"] as! NSDictionary
                                        for var person in grocery_people {
                                            if (full_name == (person.key as? String)!) {
                                                self.groceriesList["My List"] = person.value as! [String]
                                            } else {
                                                let list_name = (person.key as? String)! + "'s List"
                                                self.groceriesList[list_name] = person.value as! [String]
                                            }
                                        }
                                        
                                        self.tableView.reloadData()
                                    }
                                });
                            /*} else {
                                self.ref.child("Shopping List/\(svalue)/grocery_list").observe(DataEventType.value, with: { (snapshot2) in
                                    if let value2 = snapshot2.value! as? [String : [String: [String]]] {
                                        let grocery_people = value2["grocery_list"] as! [String: [String]]
                                        for var person in grocery_people {
                                            let list_name = person.key + "'s List"
                                            self.groceriesList[list_name] = person.value
                                        }
                                        self.tableView.reloadData()
                                    }*/
                })
            } else {
                self.navigationController?.present(NavigationController(rootViewController: FindListController()), animated: false, completion: nil)
                return
            }
        })
        
        self.tableView.register(TableViewCell.self, forCellReuseIdentifier: "Cell")
        
        pay_for_goods = RaisedButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        pay_for_goods.backgroundColor = teal
        pay_for_goods.setTitle("Pay For Goods", for: UIControlState.normal)
        pay_for_goods.addTarget(self, action: #selector(paidForGroceries), for: UIControlEvents.touchUpInside)
        pay_for_goods.titleLabel?.font = UIFont(name: "ProximaNova-Semibold", size: 18)
        pay_for_goods.pulseColor = UIColor.white
        pay_for_goods.opacity = 0
        view.layout(pay_for_goods).width(self.view.frame.width).height(60)
        self.view.addSubview(pay_for_goods)
        self.view.bringSubview(toFront: pay_for_goods)
        pay_for_goods.autoPinEdge(.bottom, to: .bottom, of: view)
        pay_for_goods.autoAlignAxis(toSuperviewAxis: .vertical)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (list_name != nil) {
            ref.child("Users/\(email_name)/full_name").observeSingleEvent(of: .value, with: { (snapshot) in
                if let svalue = snapshot.value! as? String {
                    self.ref.child("Shopping List/\(self.list_name!)/grocery_list/\(svalue)").setValue(self.groceriesList["My List"])
                }
            });
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            self.tableView.beginUpdates()
            self.groceriesList[Array(groceriesList.keys)[indexPath.section]]?.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.endUpdates()
            viewDidAppear(false)
        }
    }
    
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let section_text = Array(groceriesList.keys)[indexPath.section]
        if (section_text == "My List") {
            return true
        } else {
            return false
        }
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (Array(groceriesList.keys)[indexPath.section] != "My List") {
            if let cell = tableView.cellForRow(at: indexPath) as! TableViewCell? {
                
                if (cell.accessoryType == .none) {
                    cell.primaryLabel.textColor = .white
                    cell.secondaryLabel.textColor = .white
                    cell.backgroundColor = teal
                    cell.accessoryType = .checkmark
                    if (checkedItemArray == nil) {
                        checkedItemArray = [indexPath]
                    } else {
                        checkedItemArray.append(indexPath)
                    }
                    //pay_for_goods.isHidden = false
                    pay_for_goods.animate([MotionAnimation.fadeIn])
                } else {
                    cell.backgroundColor = .white
                    cell.primaryLabel.textColor = UIColor(rgb: 0x444444)
                    cell.secondaryLabel.textColor = UIColor(rgb: 0x8C8C8C)
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
                //pay_for_goods.isHidden = true
                pay_for_goods.animate([MotionAnimation.fadeOut])
            }
            print(checkedItemArray)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groceriesList[Array(groceriesList.keys)[section]]!.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
        
        let information = groceriesList[Array(groceriesList.keys)[indexPath.section]]?[indexPath.row].characters.split(separator: ":").map(String.init)
        
        var title = information![0] as NSString
        if (title.length >= 35) {
            title = title.substring(with: NSRange(location: 0, length: title.length > 32 ? 32 : title.length))+"..." as NSString
        }
        
        cell.primaryLabel.text = title as String
        cell.secondaryLabel.text = information![1]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = teal
        
        let headerLabel = UILabel(frame: CGRect(x: 10, y: 2, width:
            tableView.bounds.size.width, height: tableView.bounds.size.height))
        headerLabel.font = UIFont(name: "ProximaNova-Semibold", size: 18)
        headerLabel.textColor = UIColor.white
        headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return groceriesList.keys.count
    }
    
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(groceriesList.keys)[section]
    }
    
    func addGrocery() {
        //self.navigationController?.motionNavigationTransitionType = .zoom
        let grocery_controller = addGroceryController()
        self.tableView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.01, animations: {
            self.tableView.blur(blurRadius: 10)
        }) { (bool) in
            self.load_grocery_controller(grocery_controller: grocery_controller)
        }
        //self.navigationController?.pushViewController(addGroceryController(), animated: true)
        //present(addGroceryController(), animated: true)
    }
    
    func logout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.navigationController?.motionNavigationTransitionType = .none
            self.navigationController?.present(NavigationController(rootViewController: LoginViewController()), animated: true, completion: nil)
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
    
    func load_grocery_controller(grocery_controller: addGroceryController) {
        grocery_controller.tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        grocery_controller.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        grocery_controller.tableView.delegate = grocery_controller
        grocery_controller.tableView.dataSource = grocery_controller
        grocery_controller.tableView.opacity = 0.6
        grocery_controller.tableView.separatorColor = .white
        grocery_controller.tableView.tableFooterView = UIView()
        grocery_controller.tableView.backgroundColor = .black
        //removeShadows()
        
        grocery_controller.searchController = SearchBarController(rootViewController: self)
        //searchController.searchResultsUpdater = self
        //searchController.dimsBackgroundDuringPresentation = false
        grocery_controller.searchController.searchBar.placeholder = "Search for Grocery Items"
        grocery_controller.searchController.searchBar.delegate = grocery_controller
        grocery_controller.searchController.searchBar.delegate = self
        grocery_controller.searchController.searchBar.sizeToFit()
        grocery_controller.searchController.searchBar.tintColor = teal
        //searchController.searchBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width*0.5, height: (navigationController?.navigationBar.height)!)
        grocery_controller.searchController.searchBar.clearButton.tintColor = teal
        grocery_controller.searchController.searchBar.textField.delegate = grocery_controller
        
        self.view.addSubview(grocery_controller.tableView)
        self.addChildViewController(grocery_controller)
        self.navigationItem.leftBarButtonItems?.removeAll()
        self.navigationItem.rightViews.removeAll()
        self.navigationItem.centerViews = [grocery_controller.searchController.searchBar]
        
        grocery_controller.searchController.searchBar.textField.becomeFirstResponder()
    }
    
    func searchBar(searchBar: SearchBar, willClear textField: UITextField, with text: String?) {
        removeAddGroceryFromView()
    }
    
    func removeShadows() {
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 0.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.0
    }
    
    func removeAddGroceryFromView() {
        //navShadow()
        self.navigationItem.centerViews.removeAll()
        self.navigationItem.rightViews = [add]
        self.navigationItem.leftBarButtonItem = logoutItem
        
        self.tableView.isUserInteractionEnabled = true
        self.tableView.unBlur()
        viewDidAppear(false)
    }
    
}

