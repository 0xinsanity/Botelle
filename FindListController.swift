//
//  FindListController.swift
//  Botelle
//
//  Created by Noah Hanover on 7/28/17.
//  Copyright © 2017 Botelle. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class FindListController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {
    
    var dataArray: [String]! = ["Create Your Own List!"]
    
    var searchController: UISearchController!
    var shouldShowSearchResults = false
    var tableView: UITableView!
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
    
        ref.child("Shopping List").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            
            if value != nil {
                self.dataArray.append(contentsOf: (value?.allKeys)! as! [String])
            }
            self.tableView.reloadData()
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
        self.title = "Find your Community"
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Enter Zipcode"
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        
        // Place the search bar view to the tableview headerview.
        tableView.tableHeaderView = searchController.searchBar
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        
        if shouldShowSearchResults {
            //cell.textLabel?.text = filteredArray[indexPath.row]
            cell.textLabel?.text = dataArray[indexPath.row]
        }
        else {
            cell.textLabel?.text = dataArray[indexPath.row]
        }
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            self.navigationController?.pushViewController(ListFormController(), animated: true)
        } else {
            let cell_text = (tableView.cellForRow(at: indexPath)!.textLabel?.text)!
            
            let user_email = (Auth.auth().currentUser?.email)!.replacingOccurrences(of: ".", with: "_")
            ref.child("Shopping List/\(cell_text)/users").observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as! NSArray
                
                let new_users = value.adding(Auth.auth().currentUser?.email)
                self.ref.child("Users/\(user_email)/list/").setValue(cell_text)
                self.ref.child("Shopping List/\(cell_text)/users").setValue(new_users)
                
                //ref.child("Shopping List/\(cell?.textLabel?.text)/users").setValue([Auth.auth().currentUser?.email])
                // ...
            }) { (error) in
                print(error.localizedDescription)
            }
            
            self.present(UINavigationController(rootViewController: ViewController()), animated: true, completion: nil)
        }
        
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
        

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if !shouldShowSearchResults {
            return
        }
        
        guard searchController.searchBar.text != nil else {
            return
        }
        
        // Reload the tableview.
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        dataArray = []
        tableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        dataArray = []
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tableView.reloadData()
        }
        updateSearchResults(for: self.searchController)
        
        searchController.searchBar.resignFirstResponder()
    }
}
