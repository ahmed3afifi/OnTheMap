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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let activityIndicator = UIViewController.ActivityIndicator(onView: self.mapView)
        ParseAPI.sharedInstance().getStudentsLocations { (results, error) in
                if error != nil {
                    DispatchQueue.main.async {
                    let alert = UIAlertController(title: "DOWNLOAD ERROR", message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    UIViewController.deactivateSpinner(spinner: activityIndicator)
                }
            }
                
            if let locations = results {
                var annotations = [MKPointAnnotation]()
                
                for dictionary in locations {
                    
                    let lat = CLLocationDegrees(dictionary.latitude!)
                    let long = CLLocationDegrees(dictionary.longitude!)
                    
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    let first = dictionary.firstName!
                    let last = dictionary.lastName!
                    let mediaURL = dictionary.mediaURL!
                    
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(first) \(last)"
                    annotation.subtitle = mediaURL
                    
                    annotations.append(annotation)
                }
                
                DispatchQueue.main.async {
                    self.mapView.addAnnotations(annotations)
                    UIViewController.deactivateSpinner(spinner: activityIndicator)
                }
                
            } else {
                print(error!)
            }
       }
   }

    @IBAction func logout(_ sender: Any) {
        
        UdacityAPI.sharedInstance().logout { (success, error) in
            if error != nil {
                print("logout error")
            } else {
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }

    }
    
    @IBAction func refresh(_ sender: Any) {
        self.viewWillAppear(true)
    }
    
    
    @IBAction func AddLocationPressed(_ sender: Any) {
        
        ParseAPI.sharedInstance().checkForObjectId(UdacityAPI.Constants.studentKey) { (success) in
            
            if !success {
                let controller = self.storyboard!.instantiateViewController(withIdentifier: "addLocationViewController") as UIViewController
                self.present(controller, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: nil, message: "Another user has already posted a student Location. Would you like to overwrite his location?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: { action in
                    print("overwrite pressed")
                    let controller = self.storyboard!.instantiateViewController(withIdentifier: "addLocationViewController") as UIViewController
                    self.present(controller, animated: true, completion: nil)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
        
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            if let studentURLstring = view.annotation?.subtitle!, let studentURL = URL(string: studentURLstring) {
                if UIApplication.shared.canOpenURL(studentURL) {
                    UIApplication.shared.open(studentURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                } else {
                    let alert = UIAlertController(title: "URL Won't Open", message: "This URL is Not Valid and Won't Open", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }
            } else {
                let alert = UIAlertController(title: "URL not valid", message: "Student's provided URL information contains illegal characters or spaces and will not open.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

