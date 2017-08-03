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
    var span: MKCoordinateSpan!
    let user_point = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navShadow()
        //self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        let add = IconButton(image: Icon.cm.add)
        add.tintColor = teal
        add.addTarget(self, action: #selector(addCommunity), for: UIControlEvents.touchUpInside)
        navigationItem.rightViews = [add]
        navigationController?.navigationBar.tintColor = teal
        
        // Use your location
        let miles: Double = 0.5
        let scalingFactor: Double = abs((cos(2 * .pi * 42.3 / 360.0)))
        span = MKCoordinateSpan()
        span.latitudeDelta = miles / 69.0
        span.longitudeDelta = miles / (scalingFactor * 69.0)
        
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
        mapView.showsUserLocation = true
        self.view.addSubview(mapView)
        let geoCoder = CLGeocoder()
        
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedAlways) {
            ref.child("Users/\(email_name)/location").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                let value = snapshot.value as? [String: Any]
            
                var region = MKCoordinateRegion()
                region.span = self.span
                region.center.latitude = value?["latitude"] as! Double
                region.center.longitude = value?["longitude"] as! Double
                self.mapView.region = region
                
                let point = MKPointAnnotation()
                point.coordinate = CLLocationCoordinate2D(latitude: region.center.latitude, longitude: region.center.longitude)
                self.mapView.addAnnotation(point)
            })
        }
        //mapView.
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "Find Your Community"
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isMotionEnabled = true
        navigationController?.motionNavigationTransitionType = MotionTransitionType.slide(direction: MotionTransitionType.Direction.right)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isMotionEnabled = true
        navigationController?.motionNavigationTransitionType = MotionTransitionType.slide(direction: MotionTransitionType.Direction.left)
    }
    
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        mapView.removeAnnotation(user_point)
        let region = MKCoordinateRegion(center: userLocation.coordinate, span: span)
        mapView.region = region
        
        //user_point = MKPointAnnotation()
        user_point.coordinate = userLocation.coordinate
        mapView.addAnnotation(user_point)
    }
    
    func addCommunity() {
        self.navigationController?.pushViewController(CreateNewListController(), animated: true)
    }
}
