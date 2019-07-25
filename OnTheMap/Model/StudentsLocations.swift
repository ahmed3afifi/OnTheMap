//
//  StudentsLocations.swift
//  OnTheMap
//
//  Created by Ahmed Afifi on 7/19/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import Foundation
import UIKit


struct StudentsLocations {
    
    var firstName : String?
    var lastName : String?
    var latitude : Double?
    var longitude : Double?
    var mapString : String?
    var mediaURL : String?
    var objectId : String?
    var uniqueKey : String?
    
    init?(dictionary: [String:AnyObject]) {
        
        guard
            let FirstName = dictionary[ParseAPI.JSONResponseKeys.FirstName] as? String,
            let LastName = dictionary[ParseAPI.JSONResponseKeys.LastName] as? String,
            let Latitude = dictionary[ParseAPI.JSONResponseKeys.Latitude] as? Double,
            let Longitude = dictionary[ParseAPI.JSONResponseKeys.Longitude] as? Double,
            let MapString = dictionary[ParseAPI.JSONResponseKeys.MapString] as? String,
            let MediaURL = dictionary[ParseAPI.JSONResponseKeys.URL] as? String,
            let ObjectId = dictionary[ParseAPI.JSONResponseKeys.ObjectID] as? String,
            let UniqueKey = dictionary[ParseAPI.JSONResponseKeys.UdacityID] as? String
            else { return nil }
        
        self.firstName = FirstName
        self.lastName = LastName
        self.latitude = Latitude
        self.longitude = Longitude
        self.mapString = MapString
        self.mediaURL = MediaURL
        self.objectId = ObjectId
        self.uniqueKey = UniqueKey
    }
    
    static func studentsFromResults(_ results: [[String:AnyObject]]) -> [StudentsLocations] {
        
        var students = [StudentsLocations]()
        // iterate through array of dictionaries, each student is a dictionary
        for result in results {
            if let result = StudentsLocations(dictionary: result) {
                if students.count < 100 {
                    students.append(result)
                } else {
                    StudentsData.sharedInstance().students = students
                    return StudentsData.sharedInstance().students
                }
                
            }
        }
        return students
    }
}


