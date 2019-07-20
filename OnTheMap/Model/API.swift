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
        } catch let error {
            print("there is error in decoding data\n")
            print(error.localizedDescription)
        }
    }
    task.resume()
    
}
