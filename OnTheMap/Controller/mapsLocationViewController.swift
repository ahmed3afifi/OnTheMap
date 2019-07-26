//
//  mapsLocationVC.swift
//  OnTheMap
//
//  Created by Ahmed Afifi on 7/23/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import UIKit
import MapKit

class mapsLocationViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let userLat = ParseAPI.sharedInstance().latitude
    let userLon = ParseAPI.sharedInstance().longitude
    let userlocationString = ParseAPI.sharedInstance().locationString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let lat = CLLocationDegrees(userLat!)
        let long = CLLocationDegrees(userLon!)
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = userlocationString
        
        
        let mapSpan = MKCoordinateSpan.init(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: coordinate, span: mapSpan)
        self.mapView.setRegion(region, animated: true)
        
        
        
        self.mapView.addAnnotation(annotation)
        self.mapView.selectAnnotation(annotation, animated: true)
        
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseID = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.red
            
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func finishTapped(_ sender: Any) {
        
        if let id = ParseAPI.sharedInstance().objectID  {
            ParseAPI.sharedInstance().updateStudentInfo(objectID: id, { (success, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "UPDATE ERROR", message: error, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
                if success == true {
                    DispatchQueue.main.async {
                        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                }
            })
        } else {
            ParseAPI.sharedInstance().postStudentLocation { (success, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "POSTING ERROR", message: error, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
                if success == true {
                    
                    DispatchQueue.main.async {
                        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                    
                }
            }
        }
    }
    
}
