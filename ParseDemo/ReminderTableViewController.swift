//
//  TableViewController.swift
//  RemindMe
//
//  Created by Dhia Elhaq Rzig on 6/14/17.
//  Copyright © 2017 devagnos. All rights reserved.
//

import UIKit
import  Parse
import  os.log

class ReminderTableViewController: UITableViewController, UINavigationControllerDelegate, UITextFieldDelegate {
   
    @IBAction func unwindToReminderList(_ segue:UIStoryboardSegue) {
    }
   
        override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
//        loadReminders()
        
//        print(reminders)
//        print("e")
            
//        Set left button as edit Button 
//            navigationItem.leftBarButtonItem = editButtonItem
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
               return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return HomeViewController.reminders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cellIdentifier = "ReminderTableViewCell"
        guard   let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)as? ReminderTableViewCell  else {
            fatalError("The dequeued cell is not an instance of Reminder TableViewCell.")
        }
     let rem = HomeViewController.reminders[indexPath.row]
     cell.ReminderContentText.text=rem.value(forKey: "content") as? String
     cell.ReminderNameText.text=rem.value(forKey: "title") as? String
        return cell
    }
    


    @IBAction func unwindToReminderList(sender: UIStoryboardSegue) {
        if let sourceViewController =   sender.source as? AddReminderViewController,
//            let reminder = sourceViewController.rem as Reminder? ,
            let i = sourceViewController.i as Int? {
            
           
     //     let newIndexPath = IndexPath(row: HomeViewController.reminders.count, section: 0)
            
//            HomeViewController.reminders.append(reminder)
           if (i == -1) {   let newIndexPath = IndexPath(row: HomeViewController.reminders.count-1, section: 0)
            print([newIndexPath])
            tableView.insertRows(at: [newIndexPath], with: .automatic)
           }
                else { let newIndexPath = IndexPath(row:i, section: 0)
            tableView.reloadRows(at: [newIndexPath], with: .automatic)}

        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "AddItem":
            if #available(iOS 10.0, *) {
                os_log("Adding a new Reminder", log: OSLog.default, type: .debug)
            } else {
                // Fallback on earlier versions
            }
            AddReminderViewController.rem = nil
            
        case "ShowDetail":
            guard let reminderDetailViewController = segue.destination as? AddReminderViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedMealCell = sender as? ReminderTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedReminder = HomeViewController.reminders[indexPath.row] as PFObject?
             AddReminderViewController.rem = selectedReminder as! Reminder?
            
        default: break
//            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    

    
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

        // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            HomeViewController.reminders[indexPath.row].deleteInBackground()
            HomeViewController.reminders.remove(at: indexPath.row)

            tableView.deleteRows(at: [indexPath], with: .fade)
                  } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
 

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
}
