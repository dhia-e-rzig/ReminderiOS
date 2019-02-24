////
////  Facebook.swift
////  Lya
////
////  Created by Aymen Ben Romdhane on 10/27/16.
////  Copyright © 2016 Devagnos. All rights reserved.
////
//
//import Foundation
//import UIKit
//import FBSDKLoginKit
//import Parse
////{
////    "user_id": "1240689298",
////    "name": "Sami Ayed",
////    "picture": "https://scontent-cdg2-1.xx.fbcdn.net/v/t1.0-9/13932686_10207605270150083_1458311173450454812_n.jpg?oh=d02d631e55a4bdd36d03d9ba94d03aff&oe=58A9EE56",
////    "first_name": "Sami",
////    "last_name": "Ayed",
////    "gender": "male"
////}
//
//
//
//class Facebook {
//    class func connect(from: UIViewController, _ completion: @escaping (User?) -> ()){
//        let fbLoginManager = FBSDKLoginManager()
//        fbLoginManager.logOut()
//        fbLoginManager.logIn(withReadPermissions: ["email"], from: from, handler: { (result, error) -> Void in
//            //   print(error)
//            if error == nil{
//                if let _ = result {
//                    let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, gender, first_name, last_name, picture.width(512).height(512), location, age_range,cover,devices,email"])
//                    graphRequest.start(completionHandler: { (connection, result, error) -> Void in
//                        //   print("Rami")
//                        
//                        if error == nil {
//                            
//                            
//                            if let result = result as? [String: Any] {
//                                print(result)
//                                
//                                guard let userId = result["id"] as? String,
//                                    let name = result["name"] as? String,
//                                    let gender = result["gender"] as? String,
//                                    let first_name = result["first_name"] as? String,
//                                    let email = result["email"] as? String,
//                                    //let location = result["location"] as? String,
//                                    
//                                    let last_name = result["last_name"] as? String,
//                                    let picture = result["picture"] as? [String: Any]
//                                    else {
//                                        return
//                                }
//                                
//                                let user = User()
////                                user.location = location
//                                user.user_id = userId
//                                user.name = name
//                                user.gender = gender
//                                user.firstName = first_name
//                                user.email = email
//                                
//                                user.lastName = last_name
//                                if let data = picture["data"] as? [String: Any] {
//                                    if let url = data["url"] as? String {
//                                        user.pictureUrl = url
////                                        user.pictureLinkFacebook = url
//                                        
//                                    }
//                                }
//                                completion(user)
//                            }
//                        }
//                    })
//                }
//            }
//        })
//        
//    }
//}
