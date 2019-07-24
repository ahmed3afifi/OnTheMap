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
    static let shared = mapsLocationViewController()
    var location: StudentLocation?
    var selectedLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var locationTitle = ""
    var url = ""
    
    var mapString: String?
    var mediaURL: String?
    var latitude: Double?
    var longitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancel(_:)))
        self.navigationItem.leftBarButtonItem = cancel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        createAnnotation()
    }
    
    func createAnnotation() {
        let annotation = MKPointAnnotation()
        annotation.title = mapString
        annotation.subtitle = mediaURL
        annotation.coordinate = CLLocationCoordinate2DMake(latitude ?? 0.0, longitude ?? 0.0)
        self.mapView.addAnnotation(annotation)
        
        //zooming to location
        let coredinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude ?? 0.0, longitude ?? 0.0)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coredinate, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    @objc private func cancel(_ sender: Any){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func finishTapped(_ sender: Any) {
        API.shared.getUser { (success, student, errorMessage) in
            if success {
                print("student?.uniqueKey: \(String(describing: student?.uniqueKey))")
                DispatchQueue.main.async {
                    self.sendInformation(student!)
                }
            } else {
                DispatchQueue.main.async {
                    print(errorMessage!)
                }
            }
        }
    }
    
    func sendInformation(_ student: StudentLocation){
        var newStudent = StudentLocation()
        newStudent.uniqueKey = student.uniqueKey
        newStudent.firstName = student.firstName
        newStudent.lastName = student.lastName
        newStudent.mapString = student.mapString
        newStudent.mediaURL = student.mediaURL
        newStudent.longitude = student.longitude
        newStudent.latitude = student.latitude
        API.shared.postStudent(newStudent) { (success, errorMessage) in
            if success {
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    print(errorMessage!)
                }
            }
        }
    }
    
}
