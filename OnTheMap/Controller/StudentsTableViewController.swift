//
//  StudentsTableViewController.swift
//  OnTheMap
//
//  Created by Ahmed Afifi on 7/21/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import Foundation
import UIKit

class StudentsTableViewController: UITableViewController {
    
    @IBOutlet weak var studentsTableview: UITableView!
    var students: [StudentsLocations]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentsTableview.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.students = StudentsData.sharedInstance().students
        
    }
    
    
    
    @IBAction func addLocationPressed(_ sender: Any) {
        ParseAPI.sharedInstance().checkForObjectId(UdacityAPI.Constants.studentKey) { (success) in
            if !success {
        let mapVC = self.storyboard!.instantiateViewController(withIdentifier: "PostLocationViewController") as UIViewController
        self.present(mapVC, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: nil, message: "User \(UdacityAPI.Constants.firstName) \(UdacityAPI.Constants.lastName) has already posted a Student Location. Would you like to overwrite their location?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: { action in
                    let controller = self.storyboard!.instantiateViewController(withIdentifier: "PostLocationViewController") as UIViewController
                    self.present(controller, animated: true, completion: nil)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
        
    }
    
    @IBAction func refresh(_ sender: Any) {
        let activityIndicator = UIViewController.ActivityIndicator(onView: self.tableView)
        ParseAPI.sharedInstance().getStudentsLocations { (results, error) in
            if error != nil {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "DOWNLOAD ERROR", message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    UIViewController.deactivateSpinner(spinner: activityIndicator)
                }
            }
           
            if let results = results {
                self.students = results
                
                DispatchQueue.main.async {
                    UIViewController.deactivateSpinner(spinner: activityIndicator)
                    self.studentsTableview.reloadData()
                }
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
    
}
    
extension StudentsTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellHeight: CGFloat = 50
        return cellHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "studentCell"
        let student = students[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell?
        
        cell?.imageView?.image = #imageLiteral(resourceName: "icon_pin")
        
        // NAME
        if let firstName = student.firstName, firstName != "" {
            if let lastName = student.lastName, lastName != "" {
                cell?.textLabel!.text = "\(firstName) \(lastName)"
            } else {
                cell?.textLabel!.text = firstName
            }
        } else {
            cell?.textLabel!.text = "Student Name Unknown"
        }
        
        // URL
        if let url = student.mediaURL, url != "" {
            cell?.detailTextLabel?.text = url
        } else {
            cell?.detailTextLabel?.text = "No Student URL Provided"
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = students[(indexPath as NSIndexPath).row]
        if let studentURLstring = student.mediaURL, let studentURL = URL(string: studentURLstring) {
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
    
    fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
    }
}

