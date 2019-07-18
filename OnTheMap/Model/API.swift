//
//  APIs.swift
//  OnTheMap
//
//  Created by Ahmed Afifi on 7/19/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import Foundation
import UIKit

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
