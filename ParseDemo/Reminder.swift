//
//  Reminder.swift
//  RemindMe
//
//  Created by Dhia Elhaq Rzig on 6/14/17.
//  Copyright © 2017 devagnos. All rights reserved.
//

import Foundation
import  Parse
import  UIKit

class Reminder :  PFObject , PFSubclassing {
   //Snippet 
//    let rem = Reminder();
//    let date = Date()
//    let calendar = Calendar.current
//    let hour = calendar.component(.hour, from: date)
//    let minutes = calendar.component(.minute, from: date)
//    rem.setValue("Blabla", forKey: "content")
//    rem.setValue(date, forKey: "datetime")
//    rem.saveInBackground()

        
    class func parseClassName() -> String {
        return "Reminder"
    }
    
    @NSManaged var content : String?
    @NSManaged var datetime : NSDate?
    @NSManaged var dest : [String]?
    @NSManaged var type : String?
    @NSManaged var image : PFFile?


}

