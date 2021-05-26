//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Ahmed Afifi on 7/25/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import Foundation

extension UdacityAPI {
    
    struct Constants {
        
        static var studentKey: String = ""
        static var firstName: String = ""
        static var lastName: String = ""
        
        static let ApiKey = "insert API KEY HERE"
    }
    
    struct JSONBodyKeys {
        static let username = ""
    }
    
    struct Methods {
        
        static let Login = "" //post session https://onthemap-api.udacity.com/v1/session
        static let Logout = "" //delete session https://onthemap-api.udacity.com/v1/session
        static let GetUserData = "" // https://onthemap-api.udacity.com/v1/users/<user_id>
        
    }
}
