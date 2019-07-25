//
//  addLocationViewController.swift
//  OnTheMap
//
//  Created by Ahmed Afifi on 7/22/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class addLocationViewController: UIViewController {
    
    @IBOutlet weak var locationName: UITextField!
    @IBOutlet weak var mediaURL: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    //var newLocation = StudentsLocations()
    var latitude: Double?
    var longitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationName.delegate = self
        mediaURL.delegate = self
        locationName.borderStyle = .roundedRect
        mediaURL.borderStyle = .roundedRect
        findLocationButton.layer.cornerRadius = 5
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func findLocationButton(_ sender: Any) {
        
        if locationName.text != "" && mediaURL.text != "" {
            ActivityIndicator.startActivityIndicator(view: self.view )
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = locationName.text
            
            let activeSearch = MKLocalSearch(request: searchRequest)
            
            activeSearch.start { (response, error) in
                DispatchQueue.main.async {
                    
                    if error != nil {
                        ActivityIndicator.stopActivityIndicator()
                        print("Location Error : \(error!.localizedDescription)")
                    }else {
                        ActivityIndicator.stopActivityIndicator()
                        self.latitude = response?.boundingRegion.center.latitude
                        self.longitude = response?.boundingRegion.center.longitude
                        self.performSegue(withIdentifier: "showLocation", sender: nil)
                        //let controller = self.storyboard!.instantiateViewController(withIdentifier: "mapsLocation")
                        //self.present(controller, animated: true, completion: nil)
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                
                print("error")
            }
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLocation" {
            let vc = segue.destination as! mapsLocationViewController
            vc.mapString = locationName.text!
            vc.mediaURL = mediaURL.text!
            vc.latitude = self.latitude
            vc.longitude = self.longitude
        }
    }
    
}

extension addLocationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        view.frame.origin.y = -findLocationButton.frame.origin.y+50
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
}

private extension addLocationViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}

extension UIViewController {
    func startAnActivityIndicator() -> UIActivityIndicatorView {
        let ai = UIActivityIndicatorView(style: .gray)
        self.view.addSubview(ai)
        self.view.bringSubviewToFront(ai)
        ai.center = self.view.center
        ai.hidesWhenStopped = true
        ai.startAnimating()
        return ai
    }
}
