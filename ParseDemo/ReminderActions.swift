//
//  reminderType.swift
//  RemindMe
//
//  Created by Dhia Elhaq Rzig on 6/21/17.
//  Copyright © 2017 devagnos. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import Appz
import FacebookShare
import Photos
import  Alamofire
import SwiftyJSON
import Parse
import ParseTwitterUtils
// Change Reminder Save function , select receivers and show receiver functions

protocol  ReminderAction{
    func doAction(Content : String , Receivers : [String] , CurrentController : UIViewController ,ImageURL : String) -> Void
    
}

class SendText : NSObject , ReminderAction , MFMessageComposeViewControllerDelegate{
    @available(iOS 4.0, *)
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult ) {
        controller.dismiss(animated: true, completion: nil)
    }
    func doAction(Content : String , Receivers : [String] , CurrentController : UIViewController  ,ImageURL : String = ""){
        if MFMessageComposeViewController.canSendText() {
            let composeVC = MFMessageComposeViewController()
            composeVC.messageComposeDelegate = self
            // Configure the fields of the interface.
            composeVC.recipients = Receivers
            composeVC.body = Content
            if(ImageURL != ""){
                let url = URL(string: ImageURL)
                print(url)
                let session = URLSession(configuration: .default)
                
                // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
                let downloadPicTask = session.dataTask(with: url!) { (data, response, error) in
                    // The download has finished.
                    if let e = error {
                        print("Error downloading  picture: \(e)")
                    } else {
                        // No errors found.
                        // It would be weird if we didn't have a response, so check for that too.
                        if let res = response as? HTTPURLResponse {
                            print("Downloaded  picture with response code \(res.statusCode)")
                            if let imageData = data {
                                // Finally convert that Data into an image and do what you wish with it.
                                //                                    let image = UIImage(data: imageData)
                                DispatchQueue.global(qos: .userInitiated).async {
                                    composeVC.addAttachmentData(imageData, typeIdentifier: "public.data", filename: "image.jpg")
                                    CurrentController.present(composeVC, animated: true, completion: nil) }
                                // Do something with your image.
                            } else {
                                print("Couldn't get image: Image is nil")
                            }
                        } else {
                            print("Couldn't get response code for some reason")
                        }
                    }
                }
                downloadPicTask.resume()
                
                
                
                
                
                
                
                
                
                
                
                
            }else{
                CurrentController.present(composeVC, animated: true, completion: nil)
            }
            
            
            
            
            
        }
    }
}

class InstaPost : NSObject , ReminderAction ,	UIDocumentInteractionControllerDelegate {
    var documentController: UIDocumentInteractionController!
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        if error != nil {
            print(error)
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        if let lastAsset = fetchResult.firstObject {
            let localIdentifier = lastAsset.localIdentifier
            let u = "instagram://library?LocalIdentifier=" + localIdentifier
            let url = NSURL(string: u)!
            if UIApplication.shared.canOpenURL(url as URL) {
                UIApplication.shared.openURL(NSURL(string: u)! as URL)
            } else {
                //                let alertController = UIAlertController(title: "Error", message: "Instagram is not installed", preferredStyle: .alert)
                //                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                //                self.presentViewController(alertController, animated: true, completion: nil)
                print("NO instagram installed")
            }
            
        }
    }
    func doAction(Content : String , Receivers : [String] , CurrentController : UIViewController  ,ImageURL : String = "")
    {
        let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150)) as UIActivityIndicatorView
        spinner.startAnimating()
        
        let instagramURL = URL(string: "instagram://app")
        
        if UIApplication.shared.canOpenURL(instagramURL!) {
            let url = URL(string: ImageURL)
            
            DispatchQueue.global(qos: .userInitiated).async {
                var imageData = Data()
                do{ try imageData = Data(contentsOf: url!)
                }
                catch{
                    print(error)
                }
                let tempim = UIImage(data: imageData)
                UIImageWriteToSavedPhotosAlbum(tempim!, self, #selector(InstaPost.image(image:didFinishSavingWithError:contextInfo:)), nil)
                
            }
            
            // Using document controller
            /*
             imageData = UIImageJPEGRepresentation(tempim!, 100)!
             let writePath = (NSTemporaryDirectory() as NSString).appendingPathComponent("image.igo")
             
             do {
             try imageData.write(to: URL(fileURLWithPath: writePath), options: .atomic)
             
             } catch {
             
             print("Writing error : \(error)")
             }
             
             let fileURL = URL(fileURLWithPath: writePath )
             
             self.documentController = UIDocumentInteractionController(url: fileURL)
             
             self.documentController.delegate = self
             
             self.documentController.uti = "com.instagram.exlusivegram"
             
             print(fileURL)
             
             self.documentController.annotation = NSDictionary(object: Content, forKey: "InstagramCaption" as NSCopying)
             
             self.documentController.presentOpenInMenu(from: CurrentController.view.bounds, in: CurrentController.view, animated: true)
             
             
             }
             */
            
        } else {
            
            print(" Instagram is not installed ")
        }
        
        
        
        
        
    }
}


class SlackMsg : NSObject , ReminderAction {
    func doAction(Content : String , Receivers : [String] , CurrentController : UIViewController ,ImageURL : String){
        if let token:String = PFUser.current()?.value(forKey: "slackToken") as? String
        {
            Receivers.forEach({
                Receiver in
                print(token)
                print(Content)
                print(Receiver)
                var url : NSString = "https://slack.com/api/chat.postMessage?token=\(token)&channel=\(Receiver)&text=\(Content)" as! NSString
                var urlStr = url.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
                var sendMsg = NSMutableURLRequest(url: URL(string:urlStr as String )!)
                print(sendMsg)
                sendMsg.httpMethod = "POST"
                sendMsg.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Accept")
                sendMsg.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                Alamofire.request(sendMsg as URLRequest)	.responseJSON() { response in
                    switch response.result {
                    case .success:
                        if let value = response.result.value {
                            let json = JSON(value)
                            print(json) }
                    case .failure(let error):
                        print(error)
                    }
                }
            })
        }
    }
    
}

class Tweet: NSObject,ReminderAction {
    func doAction(Content: String, Receivers: [String], CurrentController: UIViewController, ImageURL: String) {
        let url = URL(string: ImageURL)
        var imageData = Data()
        do{ try imageData = Data(contentsOf: url!)
            
            
        }
        catch{
            print(error)
        }
        
        let imageView = UIImage(data: imageData)
        let vc = SLComposeViewController(forServiceType:SLServiceTypeTwitter)
        vc?.add(imageView)
        vc?.setInitialText(Content)
        CurrentController.present(vc!, animated: true, completion: nil)
    }
}

class FbPost : NSObject , ReminderAction {
    func doAction(Content : String , Receivers : [String] , CurrentController : UIViewController ,ImageURL : String){
        let url = URL(string: ImageURL)
        var imageData = Data()
        do{ try imageData = Data(contentsOf: url!)
            
            
        }
        catch{
            print(error)
        }
        
        let imageView = UIImage(data: imageData)
        let vc = SLComposeViewController(forServiceType:SLServiceTypeFacebook)
        vc?.add(imageView)
        vc?.setInitialText(Content)
        CurrentController.present(vc!, animated: true, completion: nil)
        
        
        
    }
    
}

class TwitterDm :  NSObject , ReminderAction  {
    func doAction(Content : String , Receivers : [String] , CurrentController : UIViewController ,ImageURL : String){
        
        Receivers.forEach({
            Receiver in
            let parameters: Parameters = [
                "text" : Content,"screen_name": Receiver
            ]
            do {
                var url : NSString = "https://api.twitter.com/1.1/statuses/update.json?status=\(Content)" as! NSString
                var urlStr = url.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
                var request = NSMutableURLRequest(url: URL(string:urlStr as String )!)
                
                
                PFTwitterUtils.twitter()!.sign(request)
                request.httpMethod="POST"
                request.addValue( "application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.addValue( "application/x-www-form-urlencoded", forHTTPHeaderField: "Accept")
                //   request.addValue( "4", forHTTPHeaderField: "Content-Length")
                request.addValue("Test1456789", forHTTPHeaderField: "User-Agent")
                var encrequest = try URLEncoding.queryString.encode(request as  URLRequest, with: parameters)
                
                Alamofire.request(encrequest).responseJSON() { response in
                    switch response.result {
                    case .success:
                        if let value = response.result.value {
                            let json = JSON(value)
                            print(json)
                            
                            // Do what you need to with JSON here!
                            // The rest is all boiler plate code you'll use for API requests
                            
                            
                        }
                    case .failure(let error):
                        print(error)
                        if let value = response.result.value {
                            let json = JSON(value)
                            print(json)
                        }
                        
                    }
                }
                
            }
            catch  {
                
            }
            
            
            
        })
        
    }
    
}

class WhatsappDM :  NSObject , ReminderAction  {
    func doAction(Content : String , Receivers : [String] , CurrentController : UIViewController ,ImageURL : String){
        let urlString = Content
        let urlStringEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let url  = NSURL(string: "whatsapp://send?text=\(urlStringEncoded!)")
        if UIApplication.shared.canOpenURL(url! as URL) {
            UIApplication.shared.open(url! as URL , options: [ : ])
            let pasteBoard = UIPasteboard.general
            var temp:String=""
            Receivers.forEach({
                element in
                temp=element+" , "
            })
            temp.remove(at: temp.index(before: temp.endIndex  ))
            pasteBoard.string = ""
            
        }
        else {
            let alert = UIAlertController(title: "Oops!", message:"Whatsapp isn't installed !", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { _ in
                // Put here any code that you would like to execute when
                // the user taps that OK button (may be empty in your case if that's just
                // an informative alert)
            }
            alert.addAction(action)
            CurrentController.present(alert, animated: true){}
        }
    }
    
    
}



