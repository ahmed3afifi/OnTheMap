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
    
    let device = UIDevice.current
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationName.delegate = self
        mediaURL.delegate = self
        locationName.borderStyle = .roundedRect
        mediaURL.borderStyle = .roundedRect
        findLocationButton.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        device.beginGeneratingDeviceOrientationNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findLocationButton(_ sender: Any) {
        
        if locationName.text!.isEmpty || mediaURL.text!.isEmpty {
            let alert = UIAlertController(title: nil, message: "Location & URL are required!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            
            
        } else {
            let userLocation = locationName.text!
            let userURL = mediaURL.text!
            let activityView = UIViewController.ActivityIndicator(onView: self.view)
            
            ParseAPI.sharedInstance().findStudentLocation(location: userLocation, userURL: userURL, completion: { (success, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Could Not Find Location", message: error, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        UIViewController.deactivateSpinner(spinner: activityView)
                    }
                }
                
                if success == true {
                    DispatchQueue.main.async {
                        
                        let controller = self.storyboard!.instantiateViewController(withIdentifier: "mapsLocationViewController")
                        self.present(controller, animated: true, completion: nil)
                        UIViewController.deactivateSpinner(spinner: activityView)
        
                    }
                } else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Invalid URL", message: error, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        UIViewController.deactivateSpinner(spinner: activityView)
                    }
                }
            })
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
