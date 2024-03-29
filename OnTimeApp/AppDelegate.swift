//
//  AppDelegate.swift
//  OnTimeApp
//
//  Created by Husseinomda16 on 5/12/19.
//  Copyright © 2019 Ontime24. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import UserNotifications
import Firebase
import FirebaseCore
import SwiftyJSON

var FlagcomeNotification = false
var NotificationModel : FirBasNotModelClass!
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?

    var http = HttpHelper()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        StartApp()
        http.delegate = self
        // fireBase
        
        // test fox push
        FirebaseApp.configure()
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        }else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        let token = Messaging.messaging().fcmToken
        
        
        print("FCM token: \(token ?? "")")
        UserDefaults.standard.set(token, forKey: "token")
        let udidKey = UIDevice.current.identifierForVendor!.uuidString
        UserDefaults.standard.set(udidKey, forKey: "udidKey")
        print("udidKey: \(udidKey)")
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func Login() {
        let Phone = UserDefaults.standard.string(forKey: "Phone")!
        print(Phone)
        print(UserDefaults.standard.string(forKey: "Password")!)
        let params = [
            "phone":Phone,
            "password":"\(UserDefaults.standard.string(forKey: "Password")!)",
            "fcm_token": "\(UserDefaults.standard.string(forKey: "token")!)"
            ] as [String: Any]
        //let headers = ["Accept": "application/json" ,   "lang":SharedData.SharedInstans.getLanguage() ,"Content-Type": "application/json"]
        http.requestWithBody(url: APIConstants.Login, method: .post, parameters: params, tag: 1, header: nil)
    }
    
    ////// notification ///////////
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
     //   var type = ""
        print(userInfo)
        // Print full message.
        print(userInfo)
        
        FlagcomeNotification = true
        
        NotificationModel = FirBasNotModelClass(
            message: "",
            notification_id:"",
            request_id: (userInfo["gcm.notification.request_id"]! as? String)!,
            token: (userInfo["gcm.notification.token"]! as? String)!,
            type: (userInfo["gcm.notification.type"]! as? String)!)
        
      
      
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let mainStoryboard = UIStoryboard(name: "Projects", bundle: nil)
        let homeController = mainStoryboard.instantiateViewController(withIdentifier: "HomeProjectVC") as! HomeProjectVC
        appDelegate?.window?.rootViewController = homeController
        
        
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //
        let userInfo:[AnyHashable:Any] =  notification.request.content.userInfo
      
        
        print(userInfo)
        
        FlagcomeNotification = true
       
        print((userInfo["gcm.notification.request_id"]! as? String)!)
        NotificationModel = FirBasNotModelClass(
            message: "",
            notification_id:"",
            request_id: (userInfo["gcm.notification.request_id"]! as? String)!,
            token: (userInfo["gcm.notification.token"]! as? String)!,
            type: (userInfo["gcm.notification.type"]! as? String)!)
       

        
        completionHandler([.alert,.badge,.sound])
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print (userInfo)
        FlagcomeNotification = true
        
        NotificationModel = FirBasNotModelClass(
            message: "",
            notification_id:"",
            request_id: (userInfo["gcm.notification.request_id"]! as? String)!,
            token: (userInfo["gcm.notification.token"]! as? String)!,
            type: (userInfo["gcm.notification.type"]! as? String)!)
        
        
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let mainStoryboard = UIStoryboard(name: "Projects", bundle: nil)
        let homeController = mainStoryboard.instantiateViewController(withIdentifier: "HomeProjectVC") as! HomeProjectVC
        appDelegate?.window?.rootViewController = homeController
        
       

    }
    
    func StartApp(){
        if  SharedData.SharedInstans.GetIsLogin() == false
        {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            // let storyboard = UIStoryboard(name: "StoryBord", bundle: nil)
            let storyboard = UIStoryboard.init(name: "Introduction", bundle: nil); delegate.window?.rootViewController = storyboard.instantiateInitialViewController()
        }
        else
        {
            //Login()

//            FlagcomeNotification = true
//
//            NotificationModel = FirBasNotModelClass(
//                message: "",
//                notification_id:"",
//                request_id: "110",
//                token: "",
//                type: "view_components"
//
//            )
//            let currentController = self.getCurrentViewController()
//            let storyBoard : UIStoryboard = UIStoryboard(name: "Projects", bundle:nil)
//            let cont = storyBoard.instantiateViewController(withIdentifier: "HomeNAV")
//            currentController?.revealViewController()?.pushFrontViewController(cont, animated: true)
//            let appDelegate = UIApplication.shared.delegate as? AppDelegate
//            let mainStoryboard = UIStoryboard(name: "Projects", bundle: nil)
//            let homeController = mainStoryboard.instantiateViewController(withIdentifier: "HomeNAV")
//            appDelegate?.window?.rootViewController = homeController

            

                let delegate = UIApplication.shared.delegate as! AppDelegate
                // let storyboard = UIStoryboard(name: "StoryBord", bundle: nil)
                let storyboard = UIStoryboard.init(name: "Projects", bundle: nil); delegate.window?.rootViewController = storyboard.instantiateInitialViewController()
           
       
         
        }
            
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "OnTimeApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func getCurrentViewController() -> UIViewController? {
        
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            var currentController: UIViewController! = rootController
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
        
    }
    
    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
extension AppDelegate: HttpHelperDelegate {
    func receivedResponse(dictResponse: Any, Tag: Int) {
        print(dictResponse)
    
        let json = JSON(dictResponse)
        if Tag == 1 {
            
            let status =  json["status"]
            let Message = json["msg"]
            let data = json["data"]
            let token = data["token"]
            print(token)
            print(status)
            print(Message)
            print(data)
            
            if status.stringValue  == "0" {
                
                AppCommon.sharedInstance.saveJSON(json: data, key: "Profiledata")
                print(AppCommon.sharedInstance.getJSON("Profiledata")["token"].stringValue)
                SharedData.SharedInstans.SetIsLogin(true)
                
                let delegate = UIApplication.shared.delegate as! AppDelegate
                // let storyboard = UIStoryboard(name: "StoryBord", bundle: nil)
                let storyboard = UIStoryboard.init(name: "Projects", bundle: nil); delegate.window?.rootViewController = storyboard.instantiateInitialViewController()
                
            } else {
                
                let message = json["message"]
                Loader.showError(message: message.stringValue )
                
            }
            
        }
    }
    
    func receivedErrorWithStatusCode(statusCode: Int) {
        print(statusCode)
        
    }
    
    func retryResponse(numberOfrequest: Int) {
        
    }
}
