//
//  AddGroceryController.swift
//  Botelle
//
//  Created by Akhil Sehgal on 7/25/17.
//  Copyright © 2017 Botelle. All rights reserved.
//

import UIKit
import Kanna
import Firebase
import Material

class addGroceryController: UIViewController, UITableViewDelegate, UITableViewDataSource, SearchBarDelegate, UITextFieldDelegate {
    
    var dataArray: [String]! = []
    
    var searchController: SearchBarController!
    var tableView: UITableView!
    let email_name = (Auth.auth().currentUser?.email)!.replacingOccurrences(of: ".", with: "_")
    var search_string = ""
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
        
        let information = dataArray[indexPath.row].characters.split(separator: ":").map(String.init)
        cell.textLabel?.text = information[0]
        cell.detailTextLabel?.text = information[1]
        
        cell.opacity = 0.8
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let list = (self.navigationController?.viewControllers.first as! ViewController).groceriesList["My List"] {
            (self.navigationController?.viewControllers.first as! ViewController).groceriesList["My List"]!.append((tableView.cellForRow(at: indexPath)?.textLabel?.text)!+":"+(tableView.cellForRow(at: indexPath)?.detailTextLabel?.text)!)
        } else {
            (self.navigationController?.viewControllers.first as! ViewController).groceriesList["My List"] = [((tableView.cellForRow(at: indexPath)?.textLabel?.text)!)+":"+(tableView.cellForRow(at: indexPath)?.detailTextLabel?.text)!]
        }
        
        
        (self.navigationController?.viewControllers.first as! ViewController).tableView.reloadData()
        
        //searchController.searchBar.resignFirstResponder()
        //searchController.isActive = false
        (self.navigationController?.viewControllers.first as! ViewController).removeAddGroceryFromView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func searchBar(searchBar: SearchBar, didChange textField: UITextField, with text: String?) {
        search_string = text!
        if (dataArray != []) {
            dataArray = []
        }
    }
    
    func searchBar(searchBar: SearchBar, willClear textField: UITextField, with text: String?) {
        dataArray = []
        tableView.reloadData()
        //navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let url = URL(string: "http://www.SupermarketAPI.com/api.asmx/COMMERCIAL_SearchByProductName?APIKEY=e459ef0739&ItemName="+search_string)
        if let doc = HTML(url: url!, encoding: .utf8) {
            let names = doc.xpath("//itemname")
            let pricing = doc.xpath("//pricing")
            for i in 0...names.count-1 {
                dataArray.append(names[i].innerHTML!+":"+pricing[i].innerHTML!)
            }
        }
        
        /*// Filter the data array and get only those countries that match the search text.
         filteredArray = dataArray.filter({ (grocery) -> Bool in
         let countryText:NSString = grocery as NSString
         
         return (countryText.range(of: searchString, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
         })*/
        
        // Reload the tableview.
        tableView.reloadData()
        textField.resignFirstResponder()
        return false
    }
    
    func searchBar(searchBar: SearchBar, didClear textField: UITextField, with text: String?) {
        searchBar.clearButton.isHidden = false
    }
}
