//
//  UdacityAPI.swift
//  OnTheMap
//
//  Created by Ahmed Afifi on 7/25/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import UIKit

class UdacityAPI: NSObject {
    
    var session = URLSession.shared
    
    // MARK: LOGIN FUNCTION
    func login(email: String, password: String, completionHandlerForLogin: @escaping (_ success: Bool, _ sessionID: String?, _ errorString: String?) -> Void) {
        
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
    
            if error != nil { // Handle error…
                completionHandlerForLogin(false, nil, error!.localizedDescription)
                return
            }
            
            let range = 5..<data!.count
            let newData = data?.subdata(in: range) /* subset response data! */
            
            guard let status = (response as? HTTPURLResponse)?.statusCode, status >= 200 && status <= 399 else {
                print("status code returned other than 2xx")
                completionHandlerForLogin(false,  nil, "Invalid Credentials. Please Try Again.")
                return
            }
            
            let parsedResults: [String:AnyObject]!
            
            do {
                parsedResults = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as? [String: AnyObject]
            } catch {
                print("error parsing results")
                return
            }
            
            guard let sessionInfo = parsedResults["session"] else {
                print("sessionInfo error")
                completionHandlerForLogin(false, nil, "Session Info Error")
                return
            }
            
            guard let account = parsedResults["account"] else {
                print("account error")
                return
            }
            
            if let studentKey = account["key"] as? String {
                Constants.studentKey = studentKey
            }
            
            if let sessionID = sessionInfo["id"] as? String {
                //if data returned contains a session ID, instantiate new view controller
                completionHandlerForLogin(true, "sessionID: \(sessionID)", nil)
            } else {
                //print("sessionID error")
                completionHandlerForLogin(false, nil, "Could not retrieve a session ID")
            }
        }
        task.resume()
    }
    
    
    // MARK: LOGOUT FUNCTION
    func logout(completionHandlerForLogout: @escaping (_ success: Bool,_ error: String?) -> Void) {
        
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let range = 5..<data!.count
            if let _ = data?.subdata(in: range) { /* subset response data! */
                completionHandlerForLogout(true, nil)
            } else {
                completionHandlerForLogout(false, "error in logoutRequest data retrieval: Udacity Client function")
            }
            //print(String(data: newData!, encoding: .utf8)!)
        }
        task.resume()
    }
    
    
    
    // MARK: GET PUBLIC USER DATA
    func getUser() {
        let request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/users/\(Constants.studentKey)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            let range = 5..<data!.count
            let newData = data?.subdata(in: range) /* subset response data! */
            //print(String(data: newData!, encoding: .utf8)!)
            
            guard let parsedResults = try? JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as? [String:AnyObject] else {
                print("public parse error")
                return
            }
            
            guard let user = parsedResults["user"] as? [String:AnyObject] else {
                print("user parse error")
                return
            }
            
            guard let firstName = user["first_name"] as? String, let lastName = user["last_name"] as? String else {
                print("first/last name error")
                return
            }
            Constants.firstName = firstName
            Constants.lastName = lastName
            print("user: \(Constants.firstName) \(Constants.lastName)")
            
            
        }
        task.resume()
    }
    
    class func sharedInstance() -> UdacityAPI {
        struct Singleton {
            static var sharedInstance = UdacityAPI()
        }
        return Singleton.sharedInstance
    }

    
    override init() {
        super.init()
    }

}
