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

class FindListController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var dataArray: [String]! = []
    
    var mapView: MKMapView!
    let ref = Database.database().reference()
    let email_name = (Auth.auth().currentUser?.email)!.replacingOccurrences(of: ".", with: "_")
    var span: MKCoordinateSpan!
    let user_point = MKPointAnnotation()
    var request_list: UIView!
    var title_annotation: UILabel!
    var names: UILabel!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
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
        
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.dequeueReusableAnnotationView(withIdentifier: "Annotation")
        self.view.addSubview(mapView)
    
        ref.child("Shopping List").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let lists: [String: Any] = snapshot.value as? [String : Any] {
                for list in lists {
                    let pointAnnotation = MKPointAnnotation()
                    let latitude = (((list.value as! [String: Any])["area"])! as! [String: Any])["latitude"]! as! CLLocationDegrees
                    let longitude = (((list.value as! [String: Any])["area"])! as! [String: Any])["longitude"]! as! CLLocationDegrees
                    let title = list.key as String
                    let names = (((list.value as! [String: Any])["users"])! as! [String]).joined(separator: " • ")
                    pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    pointAnnotation.title = title
                    pointAnnotation.subtitle = names
                    self.mapView.addAnnotation(pointAnnotation)
                }
            }
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedAlways) {
            ref.child("Users/\(email_name)/location").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                let value = snapshot.value as? [String: Any]
            
                var region = MKCoordinateRegion()
                region.span = self.span
                region.center.latitude = value?["latitude"] as! Double
                region.center.longitude = value?["longitude"] as! Double
                self.mapView.region = region
            })
        } else {
            var region = MKCoordinateRegion()
            region.span = self.span
            region.center.latitude = (locationManager.location?.coordinate.latitude)!
            region.center.longitude = (locationManager.location?.coordinate.longitude)!
            self.mapView.region = region

        }
        //mapView.
        request_list = UIView(frame: CGRect(x: 0, y: self.view.frame.height-185, width: self.view.frame.width, height: 185))
        request_list.backgroundColor = .white
        request_list.layer.shadowColor = UIColor.black.cgColor
        request_list.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        request_list.layer.shadowRadius = 4.0
        request_list.layer.shadowOpacity = 1.0
        request_list.layer.masksToBounds = false
        title_annotation = UILabel()
        title_annotation.text = "List Title"
        title_annotation.font = UIFont(name: "ProximaNova-Sbold", size: 15)
        names = UILabel()
        names.text = "Names Here"
        names.font = UIFont(name: "ProximaNova-Regular", size: 12)
        names.textColor = .gray
        let joinList = RaisedButton(frame: CGRect(x:0 , y: 0, width: self.view.frame.width/2, height: 40))
        joinList.backgroundColor = teal
        joinList.setTitle("Request to Join List", for: UIControlState.normal)
        joinList.addTarget(self, action: #selector(joinCommunity), for: UIControlEvents.touchUpInside)
        joinList.layer.cornerRadius = 10
        joinList.titleLabel?.font = UIFont(name: "ProximaNova-Semibold", size: 15)
        joinList.pulseColor = UIColor.white
        joinList.addTarget(self, action: #selector(joinCommunity), for: UIControlEvents.touchUpInside)
        request_list.layout(joinList).width(request_list.frame.width*0.8).height(30)
        request_list.addSubview(joinList)
        request_list.addSubview(title_annotation)
        request_list.addSubview(names)
        
        title_annotation.autoPinEdge(toSuperviewEdge: .top, withInset: 10, relation: NSLayoutRelation.equal)
        names.autoPinEdge(.top, to: .bottom, of: title_annotation, withOffset: 5)
        joinList.autoPinEdge(.top, to: .bottom, of: names, withOffset: 12)
        title_annotation.autoPinEdge(toSuperviewEdge: .left, withInset: 15, relation: NSLayoutRelation.equal)
        names.autoPinEdge(toSuperviewEdge: .left, withInset: 15, relation: NSLayoutRelation.equal)
        joinList.autoAlignAxis(toSuperviewAxis: .vertical)
        self.view.addSubview(request_list)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "Find Your Community"
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isMotionEnabled = true
        navigationController?.motionNavigationTransitionType = MotionTransitionType.slide(direction: MotionTransitionType.Direction.right)
        request_list.opacity = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isMotionEnabled = true
        navigationController?.motionNavigationTransitionType = MotionTransitionType.slide(direction: MotionTransitionType.Direction.left)
        request_list.opacity = 0
    }
    
    func joinCommunity() {
        ref.child("Users/\(email_name)/full_name").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let full_name = snapshot.value as? NSString
            self.ref.child("Shopping List/\(self.title_annotation.text!)/requests").setValue([self.email_name])
            self.ref.child("Users/\(self.email_name)/lists").setValue([self.title_annotation.text!])
            
            self.navigationController?.present(NavigationController(rootViewController: ViewController()), animated: true, completion: nil)
        }) { (error) in
            print(error.localizedDescription)
        }
            
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Annotation")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Annotation")
            //annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        annotationView!.image = resizeImage(image: UIImage(named: "pin")!, newWidth: 28)
        annotationView?.detailCalloutAccessoryView = UIView()
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if ((view.annotation?.title)! == "My Location") {
            return
        }
        
        view.image = resizeImage(image: UIImage(named: "pin")!, newWidth: 42)
        
        
        title_annotation.text = (view.annotation?.title)!
        names.text = (view.annotation?.subtitle)!
        request_list.animate([MotionAnimation.fadeIn, .duration(0.1)])
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if ((view.annotation?.title)! == "My Location") {
            return
        }
        
        request_list.animate([MotionAnimation.fadeOut, .duration(0.1)])
        view.image = resizeImage(image: UIImage(named: "pin")!, newWidth: 28)
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        image.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    
    func addCommunity() {
        self.navigationController?.pushViewController(CreateNewListController(), animated: true)
    }
}
