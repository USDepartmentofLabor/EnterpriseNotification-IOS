import UIKit
import UserNotifications
import Alamofire

fileprivate let viewActionIdentifier = "VIEW_IDENTIFIER"
fileprivate let newsCategoryIdentifier = "NEWS_CATEGORY"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let defaults = UserDefaults.standard
    var myDeviceToken = String()
    var previousDeviceToken = String()
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        print("APPDELEGATE: didFinishLaunchingWithOptions")
        let remoteNotification: UIApplicationLaunchOptionsKey
        myDeviceToken = loadDeviceToken()
        
        if (myDeviceToken != "NOVALUE") {
            previousDeviceToken = myDeviceToken
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
//            guard granted else { return }
            
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            
            
            // 1
            let viewAction = UNNotificationAction(identifier: viewActionIdentifier,
                                                  title: "View",
                                                  options: [.foreground])

            // 2
            let newsCategory = UNNotificationCategory(identifier: newsCategoryIdentifier,
                                                      actions: [viewAction],
                                                      intentIdentifiers: [],
                                                      options: [])
            // 3
            UNUserNotificationCenter.current().setNotificationCategories([newsCategory])
            
//            // handle notification when app is NOT running.
//            if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
//                let aps = notification["aps"] as! [String: AnyObject]
//                LibraryAPI.sharedInstance.setDetailMessage(detailMessage: aps["detailMsg"] as! String)
//            }
            

            
            self.getNotificationSettings()
        }
        
        
        // Check if launched from notification
        // 1
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            // 2
            let aps = notification["aps"] as! [String: AnyObject]

            print("APPDELEGATE: didFinishLaunchingWithOptions: aps: ", aps)
            
            LibraryAPI.sharedInstance.setDetailMessage(detailMessage: aps["detailMsg"] as! String)

        }
        else {
            LibraryAPI.sharedInstance.setDetailMessage(detailMessage: "WELCOME TO ENS")

        }

        
        
        
        
        return true
    }
    
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else { return }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    
    //MARK: Memento Ops -------------------------
    func saveDeviceToken(myDeviceToken: String) {
        print("setDeviceToken: ", myDeviceToken)
        
        defaults.set(myDeviceToken, forKey: "myDeviceToken")
    }
    
    func loadDeviceToken() -> String {
        var deviceToken = defaults.object(forKey:"myDeviceToken") as? String
        
        if (deviceToken == nil) {
            deviceToken = "NOVALUE"
        }
        
        print("APPDELEGATE: loadDeviceToken: DEVICE TOKEN: ", deviceToken)

        
        return ( deviceToken )!
    }
    
    
    //MARK: View Cycle Ops ----------------------
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        print("APPDELEGATE: applicationWillEnterForeground")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("APPDELEGATE: applicationDidBecomeActive")
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    // MARK : Result of registerForRemoteNotifications Ops ----------------------
    func updateDeviceTokenOnMTWS () {
        let jsonObject = [ "device": ["origToken": previousDeviceToken, "newToken": myDeviceToken] ]
        let myUrl =  LibraryAPI.sharedInstance.getCreateCitySubscriptionUrl() as String
        
        Alamofire.request(myUrl, method: .post, parameters: jsonObject, encoding: JSONEncoding.default).responseString { response in
            switch response.result {
            case .success:
                print("APP DELEGATE: UPLOAD TO MTWS OK")
            case .failure(let error):
                print("APP DELEGATE: UPLOAD TO MTWS ERROR: ", error)
            }   // end switch
        }   // end Alamorefire
    }
    
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        
        print("APPDELEGATE: didRegisterForRemoteNotificationsWithDeviceToken: DEVICE TOKEN: ", token)
        
        LibraryAPI.sharedInstance.setDeviceTokenWith(myDeviceToken: token)
        saveDeviceToken(myDeviceToken: token)
        
        // subsequent launches
        if (myDeviceToken != "NOVALUE") {
            // set run state to subsequent
            LibraryAPI.sharedInstance.setRunStatus(myRunState: NORMALRUNSTATE)
            
            if (previousDeviceToken != myDeviceToken) {
                // SUBSEQUENT RUNS
                updateDeviceTokenOnMTWS()
                
                print("APPDELEGATE: SUBSEQUENT RUN")
                
            }
        }
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
    
    
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
        print("APPDELEGATE: didReceiveRemoteNotification")
        
        application.applicationIconBadgeNumber += 1
  
        // handle notification when app is NOT running.
        if let aps = userInfo["aps"] as? [String: AnyObject] {
            if let detailMsg = aps["detailMsg"] {
                LibraryAPI.sharedInstance.setDetailMessage(detailMessage: detailMsg as! String)
            }
            if let updatedAt = aps["updatedAt"] {
                LibraryAPI.sharedInstance.setUpdatedAt(updatedAt: updatedAt as! String)
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: didReceiveNotificationNSKey), object: self)
        }
    }
    
}
