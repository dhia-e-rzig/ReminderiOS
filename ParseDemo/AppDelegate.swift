import UIKit
import Parse
import ParseFacebookUtilsV4
import UserNotifications
import  MessageUI
import Contacts
import ContactsUI
import AddressBook
import ParseTwitterUtils
import SwiftyJSON
import  Alamofire
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate  ,  UNUserNotificationCenterDelegate , MFMessageComposeViewControllerDelegate {
var window: UIWindow?
    var action:ReminderAction = SendText()
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let window = self.window, let rootViewController = window.rootViewController {
            var currentController = rootViewController
            while let presentedController = currentController.presentedViewController {
                currentController = presentedController
            }
            
            let userInfo = response.notification.request.content.userInfo
            switch userInfo["type"] as! String{
            case "Messages" :
                action=SendText()
            case "Instagram Post":
                 action = InstaPost()
            case "Tweet" :
                 action = Tweet()
            case "Post on Facebook":
                action = FbPost()
           case "Twitter DM":
                action = TwitterDm()
           case "Slack Message":
                action = SlackMsg()
           case "WhatsApp Message":
                action = WhatsappDM()
            
            default:
                print("ERROR , Type not detected")
                exit(1)
                
            }
            
            

//            print(userInfo["image"])
            action.doAction(Content:  userInfo["body"] as! String, Receivers: userInfo["dest"] as! [String] , CurrentController: currentController , ImageURL: userInfo["image"] as? String ?? "" )
            
            
        }
        completionHandler()
        
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        // Check the result or perform other tasks.
        // Dismiss the message compose view controller.
        controller.dismiss(animated: true, completion: nil)}


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
//        Twitter.sharedInstance().start(withConsumerKey:"EsvYDUf5iPumMr9izoeAeIpXF", consumerSecret:"AfNaYg0UuPQnGpqII8Ylm9ehTDL2GBPGtkvwRuHVYAECAC6PCI")
        
        let parseConfiguration = ParseClientConfiguration(block: { (ParseMutableClientConfiguration) -> Void in
            ParseMutableClientConfiguration.applicationId = "appID"
//            ParseMutableClientConfiguration.clientKey = "CLIENT_KEY"
            ParseMutableClientConfiguration.server = "http://192.168.1.17:1337/parse"
        })
        configureParse()
        Parse.initialize(with: parseConfiguration)
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)
        PFTwitterUtils.initialize(withConsumerKey: "EsvYDUf5iPumMr9izoeAeIpXF",  consumerSecret:"AfNaYg0UuPQnGpqII8Ylm9ehTDL2GBPGtkvwRuHVYAECAC6PCI")
        PFUser.enableRevocableSessionInBackground()
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert]) { (granted, error) in
        // Enable or disable features based on authorization.
        }
        
        UNUserNotificationCenter.current().delegate=self
        // Override	 point for customization after application launch.
        return true
    }
    
    
    func configureParse() {
        Reminder.registerSubclass()
    }
    
    
    // FB redirect
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
       
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
            
    }
    
    /*
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return Twitter.sharedInstance().application(app, open: url, options: options)
    }*/
    
    //Slack Redirect+Config
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool{
        self.exchangeCodeInURL(codeURL: url as NSURL)
        return true
    }
    
    // slack getToken setup
    func exchangeCodeInURL(codeURL : NSURL) {
        let clientId = "60201726932.212407189781"
        let clientSecret = "d4321e1b38a6daa99e4cfaeae9ccd10f"
        let end = codeURL.query?.index(after: (codeURL.query?.range(of: "&")?.lowerBound)!)
        let start = codeURL.query?.index(after:(codeURL.query?.range(of: "=")?.lowerBound)!)
        let myRange = start!..<end!
        var token = ""
        if let code =
            codeURL.query?.substring(with : myRange) {
            print(code)
            let request = NSMutableURLRequest(url: URL(string: "https://slack.com/api/oauth.access?client_id=\(clientId)&client_secret=\(clientSecret)&code=\(code)")!)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            Alamofire.request(request as URLRequest).responseJSON(completionHandler: {
                data in
                token=JSON(data.result.value!).dictionaryObject?["access_token"] as! String
                PFUser.current()?.setValue(token, forKey: "slackToken")
                PFUser.current()?.saveInBackground()
                           })
        }
    }

    
    
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
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }



}

