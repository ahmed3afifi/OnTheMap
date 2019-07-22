//
//  StudentsMapViewController.swift
//  OnTheMap
//
//  Created by Ahmed Afifi on 7/21/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import Foundation
import MapKit
import SafariServices


class StudentsMapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var studentsLocation = [StudentLocation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    @IBAction func addLocation(_ sender: Any) {
        let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "AddLocationNavigationController") as! UINavigationController
        self.present(mapVC, animated: true, completion: nil)
    }
    
    @IBAction func refresh(_ sender: Any) {
        API.shared.getStudentsLocations { (result, error) in
            guard let result = result else {
                return
            }
            guard result.count != 0 else{
                return
            }
            self.studentsLocation = result
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        API.shared.getStudentsLocations(){(result, error) in
            DispatchQueue.main.async {
                if error != nil {
                    let alert = UIAlertController(title: "Fail", message: "sorry, we could not fetch data", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    print("error")
                    return
                }
                
                guard result != nil else {
                    let alert = UIAlertController(title: "Fail", message: "sorry, we could not fetch data", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    return
                }
                
                StudentLocation.lastFetched = result
                var map = [MKPointAnnotation]()
                
                for location in result! {
                    let long = CLLocationDegrees(location.longitude ?? 0.0)
                    let lat = CLLocationDegrees(location.latitude ?? 0.0)
                    let cords = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    let mediaURL = location.mediaURL ?? " "
                    let firstName = location.firstName ?? " "
                    let lastName = location.lastName ?? " "
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = cords
                    annotation.title = "\(firstName) \(lastName)"
                    annotation.subtitle = mediaURL
                    map.append(annotation)
                }
                self.mapView.addAnnotations(map)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseid = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseid) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseid)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            if let toOpen = view.annotation?.subtitle! {
                guard let url = URL(string: toOpen) else {return}
                openUrlInSafari(url:url)
            }
        }
    }
    
    func openUrlInSafari(url:URL){
        if url.absoluteString.contains("http://"){
            let svc = SFSafariViewController(url: url)
            present(svc, animated: true, completion: nil)
        }else {
            DispatchQueue.main.async {
                print("could not open url")
            }
        }
    }
    
    
    
}


