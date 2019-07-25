//
//  StudentsData.swift
//  OnTheMap
//
//  Created by Ahmed Afifi on 7/24/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import Foundation

class StudentsData: NSObject {
    
    var students = [StudentsLocations]()
    
    class func sharedInstance() -> StudentsData {
        struct Singleton {
            static var sharedInstance = StudentsData()
        }
        return Singleton.sharedInstance
    }
    
}
