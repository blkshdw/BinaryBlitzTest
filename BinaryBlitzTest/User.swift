//
//  User.swift
//  BinaryBlitzTest
//
//  Created by Алексей on 24.09.16.
//
//

import Foundation
import ObjectMapper

class User: Mappable {
    var id: Int = 0
    var first_name: String = ""
    var last_name: String = ""
    var email: String = ""
    var avatar_url: String = ""

    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id          <- map["id"]
        first_name  <- map["first_name"]
        last_name   <- map["last_name"]
        email       <- map["email"]
        avatar_url  <- map["avatar_url"]

    }
}
