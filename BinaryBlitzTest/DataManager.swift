//
//  NetworkManager.swift
//  BinaryBlitzTest
//
//  Created by Алексей on 24.09.16.
//
//

import Foundation
import Alamofire
import RxSwift
import AWSS3
import SwiftyJSON

enum NetworkError: Error, CustomStringConvertible {
    case Unknown(description: String)
    case ServerUnavaliable
    
    var description: String {
        switch self {
        case .Unknown(let description):
            return description
        case .ServerUnavaliable:
            return "Server is unavaliable"
        }
    }

}

class DataManager {
    static let instance = DataManager()
    
    let apiPrefix = "https://bb-test-server.herokuapp.com"
    
    let S3BucketName = "binaryblitztest"
    
    let S3Path = "https://s3.amazonaws.com"
    
    func doRequest(method: HTTPMethod,
                           _ path: APIPath,
                           _ params: [String: Any]? = [:])
        -> Observable<JSON> {
            return Observable.create { observer in
                let req = Alamofire.request(self.apiPrefix + "/" + path.endpoint, method: method, parameters: params, encoding: URLEncoding.default)
                    .responseJSON { response in
                        debugPrint(response)
                        if response.response?.statusCode != path.successCode {
                            observer.onError(NetworkError.Unknown(description: "Invalid data"))
                        }
                        if let result = response.result.value {
                            
                            debugPrint(result)
                            observer.onNext(JSON(result))
                            observer.onCompleted()
                        } else {
                            observer.onError(NetworkError.Unknown(description: "Unexpected response format"))
                        }
                }
                
                return Disposables.create {
                    req.cancel()

                }
            }
    }

    func downloadFile(url: String) -> Observable<Data>{
        return Observable.create { observer in
            let req = Alamofire.request(url).response { response in
                if let data = response.data {
                    observer.onNext(data)
                    observer.onCompleted()
                } else {
                    observer.onError(NetworkError.Unknown(description: "Cannot get data from url"))
                }
            }
            
            return Disposables.create {
                req.cancel()
            }
        }
    }
    
    func uploadImage(image: UIImage) -> Observable<String> {
        
        return Observable.create { observer in
            let uploadRequest = AWSS3TransferManagerUploadRequest()
            let fileName = ProcessInfo.processInfo.globallyUniqueString.appending(".png") 
            let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName) ?? NSURL() as URL
            let imageData = UIImagePNGRepresentation(image)
            do {
                try imageData!.write(to: fileURL)
            } catch {
                observer.onError(NetworkError.Unknown(description: "Cannot write image file"))
            }
            

            uploadRequest?.body = fileURL
            uploadRequest?.key = fileName
            uploadRequest?.bucket = self.S3BucketName
            
            let transferManager = AWSS3TransferManager.default()
            
            transferManager?.upload(uploadRequest).continue({(task) -> AnyObject! in
                if let error = task.error {
                    observer.onError(error)
                } else {
                    observer.onNext("\(self.S3Path)/\(self.S3BucketName)/\(fileName)")
                    observer.onCompleted()
                }
                
                return nil
            })
            return Disposables.create {
                
            }
        }
        
        
    }
}
