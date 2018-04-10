//
//  EnsStore.swift
//  Ens
//
//  Created by liu-george-p on 3/26/18.
//  Copyright © 2018 tehillim. All rights reserved.
//

import UIKit
import Alamofire


class EnsStore {
    
    var allArchives = [Ens]()
    
    func fetchEnsArchives(completion: @escaping (EnsArchivesResult) -> Void) {
        let url = EnsAPI.getEnsArchivesURL()
        
        Alamofire.request(url).validate().responseJSON { response in
            guard response.result.error == nil else {
                print(response.result.error!)
                completion(.Failure(response.result.error!))
                return
            }
            
            // json is an array of json objects
            guard let json = response.result.value as? [[String: AnyObject]] else {
                print("ENS-STORE: fetchEnsArchives: Invalid JSON Object")
                completion(.Failure(APIError.InvalidEnsJSONData))
                return
            }
            
            var ensArchives:[Ens] = []
            for element in json {                
                if let ensArchiveResult = EnsAPI.ensFromJSONObject(element) {
                    ensArchives.append(ensArchiveResult)
                }
            }
            completion(.Success(ensArchives))
        }
    }
    
}   // end ensStore
