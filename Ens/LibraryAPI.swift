
//  LibraryAPI.swift
//
//  Created by George Liu on 6/9/17.
//  Copyright © 2017 OASAM All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration


let INITIALSETTINGRUNSTATE = "INITIALSETTINGRUNSTATE"
let NORMALRUNSTATE = "NORMALRUNSTATE"
let CLOSUREVCRUNSTATE = "CLOSUREVCRUNSTATE"


class LibraryAPI: NSObject {
    
    private let defaults = UserDefaults.standard
    
    private var subscriptionCityPersistencyManager = Set<String>()
    private var deviceToken = String()
    private var masterCityNamesHash = [String: String]()
    private var masterCityNamesIdHash = [String: String]()
    
    private var runState = String()   // either initial or subsequent run
    
    private var detailMessage = String()
    private var updatedAt = String()
    
    let EMPTY_STRING = ""
        
    /* use this or similar ip addr when the phone is connected to the mac */
    private let baseDoLUrl = "http://10.49.37.100:3000/" as String
    
    /************* URLs FOR NICK'S SERVER
     
 CreateSubscriptionList:
     https://staging.dol.gov/api/v1/CreateSubscriptionList
     Parameters: device token, comma separated city IDs
     Example:    https://staging.dol.gov/api/v1/CreateSubscriptionList/old-asdfasdf/7767,77675
     
 GetSubscriptinList:
     https://staging.dol.gov/api/v1/GetSubscriptionList
     Parameters: deviceToken
     Example:    https://staging.dol.gov/api/v1/GetSubscriptionList/test-device
     
 GetListOfCities:
     https://staging.dol.gov/api/v1/GetListOfCities
     Parameters: none
     Example:    https://staging.dol.gov/api/v1/GetListOfCities
 
 GetCityStatuses:
     https://staging.dol.gov/api/v1/GetCityStatuses
     Parameters: device token
     Example:
 
 CreateDeviceToken:
     https://staging.dol.gov/api/v1/CreateDeviceToken
     Parameters: old device token, new device token (optional)
     Example:    https://staging.dol.gov/api/v1/CreateDeviceToken/old-asdfasdf/new-asdfasdf
     
     ************************************/
    

    
    private let dolStagingCreateSubscriptionListBase = "https://staging.dol.gov/api/v1/CreateSubscriptionList/"
    
    private let dolStagingGetListOfCitiesBase = "https://staging.dol.gov/api/v1/GetListOfCities/"
    
    private let dolStagingGetCityStatusesBase = "https://staging.dol.gov/api/v1/GetCityStatuses/"
    
    private let dolStagingCreateDeviceTokenBase = "https://staging.dol.gov/api/v1/CreateDeviceToken/"
    
    private let dolStagingGetSubscriptionListBase = "https://staging.dol.gov/api/v1/GetSubscriptionList/"
    
    
    
    private let dolCreateDeviceTokenOnMtws = "https://staging.dol.gov/api/v1/CreateDeviceToken/?token="
    
    private let dolCityListFromBAHUrl = "https://staging.dol.gov/api/v1/emc-status-update/GetListOfCities/35.json"
    
    private let doLSubscriptionListSuffix = "SubscriptionList/?token="  as String
    private let doLSubscriptionListNoTokenAvailable = "NoTokenAvailable"  as String
    
    private let dolCityListUrlSuffix = "CityList"
    private let dolCreateCitySubscriptionUrlSuffix = "CreateCitySubscription"
 
    private let doLSubscriptionCityStatusSuffix = "CityStatuses/?token="  as String

    private let doLSubscriptionCityStatusWithCityListSuffix = "CityStatuses/?cityIDs="  as String

    
    private let dolCreateDeviceTokenOnMTWSUrl = "CityStatuses/?jsonObject="  as String
    private let dolUpdateDeviceTokenOnMTWSUrl = "CityStatuses/?jsonObject="  as String
    
    
    class var sharedInstance: LibraryAPI {
        
        struct Singleton {
            static let instance = LibraryAPI()
        }
        return Singleton.instance
    }
    
    override init() {
        super.init()
        deviceToken = EMPTY_STRING
        runState = INITIALSETTINGRUNSTATE
    }
    
    
    // MARK: Run Status Ops
    func setRunStatus(myRunState: String) {
        runState = myRunState
    }
    
    func getRunStatus() -> String {
        return runState
    }
  
    
    

    
    // MARK: Device Token Ops -------------------------
    func setDeviceTokenWith(myDeviceToken: String) {
        deviceToken = myDeviceToken        
        defaults.set(myDeviceToken, forKey: "deviceTokenKey")
    }
    
    func getDeviceToken() -> String {
        deviceToken = (defaults.object(forKey: "deviceTokenKey")  as? String)!
        return deviceToken
    }

    

    
    // MARK: URL Ops -----------------------------------
    func getDolSubscriptionListUrl() -> String {
        var url = String()
        
        // No device token -> no subscription list to get from URL
        if (deviceToken == "") {
            url = (doLSubscriptionListNoTokenAvailable)
        }
        else {
            url = (baseDoLUrl + doLSubscriptionListSuffix + deviceToken)
        }
        return url
    }
    
    func getDolCityListUrl() -> String {
        var url = String()
        url = baseDoLUrl + dolCityListUrlSuffix
        return url
    }
    
    func getCreateCitySubscriptionUrl() -> String {
        var url = String()
        url = "http://10.67.17.223:3000/devices.json"  //baseDoLUrl + dolCreateCitySubscriptionUrlSuffix
        return url
    }
    
    func getCityStatusesUrl() -> String {
        var url = String()
        
        if (deviceToken == "") {
            url = (doLSubscriptionListNoTokenAvailable)
        }
        else {
            url = (baseDoLUrl + doLSubscriptionCityStatusSuffix + deviceToken)
        }
        return url
    }
    
    // MARK: Detail Message Ops -------------------------
    func clearDetailMessage() {
        self.setDetailMessage(detailMessage: "")
    }
    
    func isDetailMsgEmpty() -> Bool {
        var rc = false
        if (defaults.string(forKey: "detailMsgKey")?.count == nil) {
            rc = true
        }
        return rc
    }
    
    func setDetailMessage(detailMessage: String) {
        self.detailMessage = detailMessage
        defaults.set(detailMessage, forKey: "detailMsgKey")
    }
    
    func getDetailMessage() -> String {
        if (isDetailMsgEmpty() == false) {
            self.detailMessage = defaults.string(forKey: "detailMsgKey")!
            return self.detailMessage
        }
        return ""
    }

    
    
    // MARK: Updated At Ops -------------------------
    func clearUpdatedAt() {
        self.setUpdatedAt(updatedAt: "")
    }
    
    func isUpdatedAtEmpty() -> Bool {
        var rc = false
        if (defaults.string(forKey: "updatedAtKey")?.count == nil) {
            rc = true
        }
        return rc
    }
    func setUpdatedAt(updatedAt: String) {
        self.updatedAt = updatedAt
        defaults.set(updatedAt, forKey: "updatedAtKey")
    }
    
    func getUpdatedAt() -> String {
        if (isUpdatedAtEmpty() == false) {
            self.updatedAt = defaults.string(forKey: "updatedAtKey")!
            return self.updatedAt
        }
        return ""
    }



}
