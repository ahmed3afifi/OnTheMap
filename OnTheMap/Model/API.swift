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

class API: NSObject {
    
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
    
    static let shared = API()


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
    
    let urlString = "https://onthemap-api.udacity.com/v1/users/\(accountKey)"
    let url = URL(string: urlString)
    print("account key: \(accountKey)")
    print("url is: \(url!)")
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
        }
        print(String(data: data, encoding: .utf8)!)
    }
    task.resume()
}
}
