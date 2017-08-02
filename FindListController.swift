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
import Material
import MapKit
import CoreLocation
import PureLayout

class FindListController: UIViewController, MKMapViewDelegate {
    
    var dataArray: [String]! = []
    
    var mapView: MKMapView!
    let ref = Database.database().reference()
    let email_name = (Auth.auth().currentUser?.email)!.replacingOccurrences(of: ".", with: "_")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let add = IconButton(image: Icon.cm.add)
        add.tintColor = teal
        add.addTarget(self, action: #selector(addCommunity), for: UIControlEvents.touchUpInside)
        navigationItem.rightViews = [add]
        navigationController?.navigationBar.tintColor = teal
        
        ref.child("Users/\(email_name)/list").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSString
            
            if value != nil {
                self.present(NavigationController(rootViewController: ViewController()), animated: false, completion: nil)
                return
            }
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    
        ref.child("Shopping List").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            
            if value != nil {
                self.dataArray.append(contentsOf: (value?.allKeys)! as! [String])
            }
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        mapView.delegate = self
        let geoCoder = CLGeocoder()
        ref.child("Users/\(email_name)/location").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? NSString
            
            geoCoder.geocodeAddressString(value as! String) { (placemarks, error) in
                let placemark = placemarks?.first?.location
                // Use your location
                var region = MKCoordinateRegion()
                region.center.latitude = (placemark?.coordinate.latitude)!
                region.center.longitude = (placemark?.coordinate.longitude)!
                self.mapView.region = region
            }
        })
        
        //mapView.
        self.view.addSubview(mapView)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "Find Your Community"
    }
    
    func addCommunity() {
        self.navigationController?.pushViewController(CreateNewListController(), animated: true)
    }
}
