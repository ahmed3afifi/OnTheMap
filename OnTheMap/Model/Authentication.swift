//
//  Authentication.swift
//  OnTheMap
//
//  Created by Ahmed Afifi on 7/19/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import Foundation
import UIKit


struct loginRequest: Codable {
    let email: String
    let password: String
}

struct loginResponse: Codable {
    let account: Account
    let session: Session
}

struct Account: Codable {
    let registered: Bool?
    let key: String?
}

struct Session: Codable {
    let id: String?
    let expiration: String?
}

