//
//  StudentsTableViewController.swift
//  OnTheMap
//
//  Created by Ahmed Afifi on 7/21/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import Foundation
import UIKit

class StudentsTableViewController: HeaderViewController {
    
    @IBOutlet weak var studentsTableview: UITableView!
    var result = [StudentLocation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentsTableview.delegate = self
        studentsTableview.dataSource = self
        result = StudentLocation.lastFetched ?? []
    }
    
    /*@IBAction func addLocationPressed(_ sender: Any) {
        let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "AddLocationNavigationController") as! UINavigationController
        self.present(mapVC, animated: true, completion: nil)
    }
    
    @IBAction func refreshPressed(_ sender: Any) {
        API.shared.getStudentsLocations { (result, error) in
            guard let result = result else {
                return
            }
            guard result.count != 0 else{
                return
            }
            self.result = result
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }*/
    
}
    
extension StudentsTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell") as! DataViewCell
        let student = self.result[(indexPath).row]
        cell.name.text = "\(student.firstName ?? " ")  \(student.lastName ?? " ")"
        cell.mediaURL.text = student.mediaURL
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = self.result[(indexPath).row].mediaURL
        print("url is: \(String(describing: url))")
        if let url = URL(string: url ?? " ")
        {
            UIApplication.shared.open(url)
        }
    }
}

