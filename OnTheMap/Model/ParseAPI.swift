//
//  ParseAPI.swift
//  OnTheMap
//
//  Created by Ahmed Afifi on 7/19/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class ParseAPI: NSObject {
    
    var session = URLSession.shared
    
    var latitude: Double!
    var longitude: Double!
    var firstName: String?
    var lastName: String?
    var objectID: String?
    var locationString: String?
    var userURL: String?
    
    
    // MARK: GETTING STUDENTS LOCATION
    func getStudentsLocations(_ completion: @escaping (_ result: [StudentsLocations]?, _ error: String?) -> Void) {
    
    var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation?order=-updatedAt&limit=200")!)
    request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
    let session = URLSession.shared
    let task = session.dataTask(with: request) { data, response, error in
        guard (error == nil) else {
            print("error in your request")
            completion(nil, error!.localizedDescription)
            return
        }
        guard let data = data else {
            completion(nil, "No Data Returned.  Please Try Again Later.")
            return
        }
        guard let status = (response as? HTTPURLResponse)?.statusCode, status >= 200 && status <= 399 else {
            print("response error")
            completion(nil, "The request returned other than 2xx.  Please Try Again Later.")
            return
        }
        
        let parsedResults: [String: AnyObject]!
        
        do {
            parsedResults = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
        } catch {
            completion(nil, "Error Parsing JSON Data.  Please Try Again Later.")
            return
        }
        
        if let results = parsedResults["results"] as? [[String:AnyObject]] {
            let students = StudentsLocations.studentsFromResults(results)
            completion(students, nil)
        } else {
            completion(nil, "Error parsing 'Results' from JSON data.  Please Try Again Later.")
        }
        
    }
    task.resume()
}

    // MARK: CHECK FOR OBJECT ID
    func checkForObjectId(_ uniqueKey: String, _ completionHandlerfForCheckForObjectId: @escaping (_ result: Bool) -> Void) {
        
        var urlString = "https://onthemap-api.udacity.com/v1/StudentLocation"
        urlString.append("?where=%7B%22uniqueKey%22%3A%22\(uniqueKey)%22%7D")
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                return
            }
            print(String(data: data!, encoding: .utf8)!)
            
            guard let parsedResults = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: AnyObject] else {
                print("parse query error")
                return
            }
            
            guard let results = parsedResults["results"] as? [[String: AnyObject]] else {
                print("no results")
                return
            }
            
            if results.isEmpty {
                completionHandlerfForCheckForObjectId(false)
            }
            
            for result in results {
                
                if let objectID = result["objectId"] as? String {
                    self.objectID = objectID
                    completionHandlerfForCheckForObjectId(true)
                }
            }
        }
        task.resume()
    }
    
    
    // MARK: POSTING STUDENT INFO
    func postStudentLocation(_ completionHandlerPost: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        let lat = Float(ParseAPI.sharedInstance().latitude)
        let lon = Float(ParseAPI.sharedInstance().longitude)
        
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(UdacityAPI.Constants.studentKey)\", \"firstName\": \"\(UdacityAPI.Constants.firstName)\", \"lastName\": \"\(UdacityAPI.Constants.lastName)\",\"mapString\": \"\(ParseAPI.sharedInstance().locationString!)\", \"mediaURL\": \"\(ParseAPI.sharedInstance().userURL!)\",\"latitude\": \(lat), \"longitude\": \(lon)}".data(using: .utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard (error == nil) else {
                print("error in your request")
                return
            }
            guard let data = data else {
                completionHandlerPost(false, "Could Not Post Student Location")
                return
            }
            guard let status = (response as? HTTPURLResponse)?.statusCode, status >= 200 && status <= 399 else {
                completionHandlerPost(false, "Could Not Post Student Location")
                return
            }
            
            guard let parsedResults = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else {
                completionHandlerPost(false, "Could Not Post Student Location")
                return
            }
            
            if let objectID = parsedResults["objectId"] as? String {
                self.objectID = objectID
                completionHandlerPost(true, nil)
            } else {
                completionHandlerPost(false, "Could Not Post Student Location")
            }
        }
        task.resume()
    }
    
    // UPDATE STUDENT INFO
    func updateStudentInfo(objectID: String, _ completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        let urlString = "https://onthemap-api.udacity.com/v1/StudentLocation/\(objectID)"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(UdacityAPI.Constants.studentKey)\", \"firstName\": \"\(UdacityAPI.Constants.firstName)\", \"lastName\": \"\(UdacityAPI.Constants.lastName)\",\"mapString\": \"\(self.locationString!)\", \"mediaURL\": \"\(self.userURL!)\",\"latitude\": \(Float(self.latitude!)), \"longitude\": \(Float(self.longitude!))}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                return
            }
            guard let data = data else {
                print("no data returned")
                completionHandler(false, "Could Not Update Student Information.")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("status code returned other than 2xx")
                completionHandler(false, "Could Not Update Student Information.")
                
                return
            }
            
            guard let parsedResults = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else {
                print("parse query error")
                completionHandler(false, "Could Not Update Student Information.")
                return
            }
            
            if let results = parsedResults["updatedAt"] as? String {
                print(results)
                completionHandler(true, nil)
            } else {
                completionHandler(false, "Could Not Update Student Information.")
            }
            
        }
        task.resume()
    }
    
    private func checkURLValidity(userURL: String?) -> Bool {
        if let urlString = userURL, let url = URL(string: urlString)  {
            if UIApplication.shared.canOpenURL(url) == true {
                self.userURL = userURL
                return true
            }
        }
        return false
    }
    
    // FIND STUDENT LOCATION
    func findStudentLocation(location: String, userURL: String, completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        forwardGeocodeLocationString(locationString: location) { (success, error) in
            if success == true {
                self.locationString = location
                if self.checkURLValidity(userURL: userURL) == true {
                    completion(true, nil)
                } else {
                    completion(false, "Please enter a valid URL with https://")
                }
            } else {
                completion(false, error)
                
            }
        }
    }
    
    func forwardGeocodeLocationString(locationString: String, _ completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
        CLGeocoder().geocodeAddressString(locationString) { (result, error) in
            if error != nil {
                completion(false, "Please Enter a City, Address, Postal Code, or Intersection")
                return
            }
            if let location = result, let coordinate = location[0].location?.coordinate {
                self.latitude = coordinate.latitude
                self.longitude = coordinate.longitude
                completion(true, nil)
            }
        }
    }
    
    
    
    class func sharedInstance() -> ParseAPI {
        struct Singleton {
            static var sharedInstance = ParseAPI()
        }
        return Singleton.sharedInstance
    }
    
}
