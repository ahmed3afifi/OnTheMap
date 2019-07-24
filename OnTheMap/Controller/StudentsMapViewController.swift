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


class StudentsMapViewController: HeaderViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        Client.shared.getStudentsLocations(){(result, error) in
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
}

extension StudentsMapViewController: MKMapViewDelegate {
    
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
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.rightCalloutAccessoryView {
            guard let newUrl = annotationView.annotation?.subtitle else {return}
            guard let stringUrl = newUrl else {return}
            guard let url = URL(string: stringUrl) else {return}
            openUrlInSafari(url:url)
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

