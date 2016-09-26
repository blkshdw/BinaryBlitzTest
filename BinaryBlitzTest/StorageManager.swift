//
//  DataManager.swift
//  BinaryBlitzTest
//
//  Created by Алексей on 24.09.16.
//
//

import Foundation
import RxSwift
import ObjectMapper
import SwiftyJSON

enum APIPath {
    case PatchUser(Int)
    case FetchUsers
    case CreateUser
    
    var endpoint : String {
        switch self {
        case .PatchUser(let userId):
            return "users/\(userId).json"
        case .FetchUsers:
            return "users.json"
        case .CreateUser:
            return "users.json"
        }
    }
        
    var successCode : Int {
        switch self {
        case .PatchUser:
            return 200
        case .FetchUsers:
            return 200
        case .CreateUser:
            return 201
        }
    }
}

enum DataError: Error, CustomStringConvertible {
    case Network(NetworkError)
    case ResponseConvertError
    case Unknown
    
    var description: String {
        switch self {
        case .Network(let error):
            return error.description
        case .ResponseConvertError:
            return "Response is not a valid JSON"
        default:
            return ""
        }
    }
}


class StorageManager {
    static let instance = StorageManager()
    
    var users: [User] = []
    
    func fetchUsers() -> Observable<Void> {
        return DataManager.instance.doRequest(method: .get, APIPath.FetchUsers)
            .catchError { error in
                if let error = error as? NetworkError {
                    return Observable.error(DataError.Network(error))
                } else {
                    return Observable.error(DataError.Unknown)
                }
            }
            .flatMap { usersJSON -> Observable<Void> in
                if let usersJSONArray = usersJSON.array {
                    var fetchedUsers : [User] = []
                    usersJSONArray.forEach { userJSON in
                        if let userString = userJSON.rawString() {
                        if let user = Mapper<User>().map(JSONString: userString) {
                                fetchedUsers.append(user)
                            }
                        }
                        self.users = fetchedUsers
                    }
                    return Observable.empty()
                } else {
                    return Observable.error(DataError.ResponseConvertError)
                }
        }
    }
    
    func patchUser(user: User, first_name: String, last_name: String, email: String) -> Observable<Void>{
        let userMap  = [
            "first_name": first_name,
            "last_name": last_name,
            "email": email
        ]
        
        let userReq = ["user": userMap]

        return DataManager.instance.doRequest(method: .patch, APIPath.PatchUser(user.id), userReq)
            .catchError { error in
                if let error = error as? NetworkError {
                    return Observable.error(DataError.Network(error))
                } else {
                    return Observable.error(DataError.Unknown)
                }
            }
            .flatMap { _ -> Observable<Void> in
                user.first_name = first_name
                user.last_name = last_name
                user.email = email
                return Observable.empty()
        }
    }
    
    func createUser(first_name: String, last_name: String, email: String, avatar_url: String) -> Observable<Void>{
        
        let userMapJSON = [
            "first_name": first_name,
            "last_name": last_name,
            "email": email,
            "avatar_url": avatar_url
        ]
        let userReq = ["user": userMapJSON]
        return DataManager.instance.doRequest(method: .post, APIPath.CreateUser, userReq)
            .catchError { error in
                if let error = error as? NetworkError {
                    return Observable.error(DataError.Network(error))
                } else {
                    return Observable.error(DataError.Unknown)
                }
            }
            .flatMap { userJSON -> Observable<Void> in
                if let userString = userJSON.rawString() {
                    if let user = Mapper<User>().map(JSONString: userString) {
                        self.users.append(user)
                    }
                }
                
                return Observable.empty()
        }
    }
}
    
    
