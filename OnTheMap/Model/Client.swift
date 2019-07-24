//
//  APIs.swift
//  OnTheMap
//
//  Created by Ahmed Afifi on 7/19/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class Client: NSObject {
    
    var accountKey: String = ""
    var createdAt : String = ""
    var firstName : String = ""
    var lastName : String = ""
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var mapString : String = ""
    var mediaURL : String = ""
    var objectId : String = ""
    var uniqueKey : String = ""
    var updatedAt : String = ""
    
    static let shared = Client()
    
    func login(_ email: String,_ password: String, completion: @escaping (Bool, Error?)->()) {
        
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            
            func dispalyError(_ error: String){
                print(error)
            }
            
            guard (error == nil) else {
                completion (false, error)
                return
            }
            
            guard let data = data else {
                dispalyError("there is no data")
                return
            }
            guard let status = (response as? HTTPURLResponse)?.statusCode, status >= 200 && status <= 399 else {
                dispalyError("the status code > 2xx")
                completion (false, error)
                return
            }
            let range = 5..<data.count
            let newData = data.subdata(in: range) /* subset response data! */
            
            do {
                let decoder = JSONDecoder()
                let dataDecoded = try decoder.decode(loginResponse.self, from: newData)
                let accountID = dataDecoded.account.key
                let accountRegister = dataDecoded.account.registered
                let sessionID = dataDecoded.session.id
                let sessionExpire = dataDecoded.session.expiration
                //self.firstName = dataDecoded.account
                print(":: Authentication Information ::")
                print("--------------------------")
                print("The account ID: \(String(describing: accountID!))")
                print("The account registered: \(String(describing: accountRegister!))")
                print("The session ID: \(String(describing: sessionID!))")
                print("The seesion expire: \(String(describing: sessionExpire!))")
                print("--------------------------\n")
                completion (true, nil)
                print("The login is done successfuly!")
            } catch let error {
                dispalyError("could not decode data \(error.localizedDescription)")
                completion (false, nil)
                return
            }
        }
        task.resume()
    }
    
    private func dispalyError(_ error: String){
        print(error)
    }
    
    
    func logout() {
        
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
            func dispalyError(_ error: String){
                print(error)
            }
            guard (error == nil) else {
                return
            }
            guard let data = data else {
                dispalyError("there is no data")
                return
            }
            guard let status = (response as? HTTPURLResponse)?.statusCode, status >= 200 && status <= 399 else {
                dispalyError("the status code > 2xx")
                return
            }
            let range = 5..<data.count
            let newData = data.subdata(in: range) /* subset response data! */
            do {
                let decoder = JSONDecoder()
                _ = try decoder.decode(Session.self, from: newData)
            }catch let error {
                dispalyError(error.localizedDescription)
                return
            }
            print(String(data: newData, encoding: .utf8)!)
        }
        task.resume()
    }


func getStudentsLocations(limit: Int = 100, skip: Int = 0, orderby: Param = .updatedAt, completion: @escaping ([StudentLocation]?, Error?) -> ()) {
    
    let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?limit=\(limit)&skip=\(skip)"
    let url = URL(string: urlString)
    var request = URLRequest(url: url!)
    request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
    let session = URLSession.shared
    let task = session.dataTask(with: request) { data, response, error in
        if error != nil { // Handle error
            completion(nil, error)
            return
        }
        guard let data = data else {
            print("data issue")
            completion(nil, error)
            return
        }
        guard let status = (response as? HTTPURLResponse)?.statusCode, status >= 200 && status <= 399 else {
            print("response error")
            completion(nil, error)
            return
        }
        do {
            let decoder = JSONDecoder()
            let result = try! decoder.decode(Result.self, from: data)
            completion(result.results, nil)
        } 
    }
    task.resume()
}

func getUser(completionHandlerForGet: @escaping (_ success: Bool, _ student: StudentLocation?, _ errorString: String?) -> Void) {
    
    /*if accountKey == nil {
        completionHandlerForGet(false, nil, "could not find account key")
        return
    }*/
    let urlString = "https://onthemap-api.udacity.com/v1/users/\(accountKey)"
    let url = URL(string: urlString)
    var request = URLRequest(url: url!)
    request.httpMethod = "GET"
    request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
    let session = URLSession.shared
    let task = session.dataTask(with: request) { data, response, error in
        if error != nil { // Handle error
            completionHandlerForGet(false, nil, error?.localizedDescription)
            return
        }
        guard let data = data else {
            completionHandlerForGet(false, nil, error?.localizedDescription)
            return
        }
        guard let status = (response as? HTTPURLResponse)?.statusCode, status >= 200 && status <= 399 else {
            completionHandlerForGet(false, nil, error?.localizedDescription)
            return
        }
        print(String(data: data, encoding: .utf8)!)
        let range = 5..<data.count
        let newData = data.subdata(in: range) /* subset response data! */
        print("--------------")
        print(String(data: newData, encoding: .utf8)!)
        do {
            let decoder = JSONDecoder()
            let decodedData = try! decoder.decode(StudentLocation.self, from: newData)
            var student = StudentLocation()
            student.firstName = decodedData.firstName
            student.lastName = decodedData.lastName
            student.uniqueKey = self.accountKey
            completionHandlerForGet(true, student, nil)
        } /*catch let error {
            print(error.localizedDescription)
            completionHandlerForGet(false, nil, error.localizedDescription)
            return
        }*/
        print(String(data: data, encoding: .utf8)!)
    }
    task.resume()
  }
    
    func postStudent(_ student: StudentLocation, completionHandlerPost: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        let encoder = JSONEncoder()
        let jsonData: Data
        do {
            jsonData = try encoder.encode(student)
        } catch let error {
            print(error.localizedDescription)
            return
        }
        
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        //            "{\"uniqueKey\": \"\(student.uniqueKey)\", \"firstName\": \"\(student.firstName)\", \"lastName\": \"\(student.lastName)\",\"mapString\": \"\(student.mapString)\", \"mediaURL\": \"\(student.mediaURL)\",\"latitude\": \(student.latitude), \"longitude\": \(student.longitude)}".data(using: .utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                completionHandlerPost(false, error?.localizedDescription)
                return
            }
            guard let data = data else {
                completionHandlerPost(false, error?.localizedDescription)
                return
            }
            guard let status = (response as? HTTPURLResponse)?.statusCode, status >= 200 && status <= 399 else {
                completionHandlerPost(false, error?.localizedDescription)
                return
            }
            do {
                let decoder = JSONDecoder()
                let decodedData = try! decoder.decode(StudentLocation.self, from: data)
                completionHandlerPost(true, nil)
                print(decodedData)
            }
            print(String(data: data, encoding: .utf8)!)
        }
        task.resume()
    }
    
}
