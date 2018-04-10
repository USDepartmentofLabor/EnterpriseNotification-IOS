//
//  EnsAPI.swift
//  Ens
//
//  Created by liu-george-p on 3/26/18.
//  Copyright © 2018 tehillim. All rights reserved.
//

import Foundation


enum Method: String {
    case EnsArchives = "/ens"    // /ensArchives"
    case CreateDeviceToken = "/createDeviceToken"
}

enum JSONParseResult {
    case EnsArchiveSuccess([Ens])
    case Failure(Error)
}

enum EnsArchivesResult {
    case Success([Ens])
    case Failure(Error)
}
    
enum APIError: Error {
    case InvalidEnsJSONData
    case MissingEnsJSONData
}



class EnsAPI: NSObject {
    
//    fileprivate static let baseURLString = "http://tru-sim-dev-2.herokuapp.com"
    fileprivate static let baseURLString = Bundle.main.infoDictionary!["EnsWebServiceUrl"] as! String
    
    
    fileprivate class func ensURL(method: Method, extra: [String]?) -> URL {
        var components = URLComponents(string: baseURLString)!
        components.path = method.rawValue
        if let additionalPath = extra {
            for (value) in additionalPath {
                components.path = (components.path as NSString!).appendingPathComponent(value)
            }
        }
        
        return components.url!
    }
    
    
    class func ensFromJSONObject(_ json: [String: AnyObject]) -> Ens? {
        guard
            let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let description = json["description"] as? String,
            let url = json["url"] as? String,
            let active = json["active"] as? String,
            let createdAt = json["created_at"] as? String,
            let updatedAt = json["updated_at"] as? String
        else {
            return nil
        }
        
        return Ens(id: id, title: title, description: description, url: url, active: active, createdAt: createdAt, updatedAt: updatedAt)
    }
    
    
    // MARK: URL Helpers
    class func getEnsArchivesURL() -> URL {
        return ensURL(method: .EnsArchives, extra: [])
    }
    
    
}   // end class EnsAPI
