
//
//  AddReminderViewController.swift
//  RemindMe
//
//  Created by Dhia Elhaq Rzig on 6/16/17.
//  Copyright © 2017 devagnos. All rights reserved.
//
import Bolts
import UIKit
import UserNotifications
import os.log
import ContactsUI
import AddressBook
import Parse
import Alamofire
import ParseTwitterUtils
import SwiftyJSON

class AddReminderViewController: UIViewController,UITextFieldDelegate,CNContactPickerDelegate, UIPickerViewDelegate,UIImagePickerControllerDelegate, UIPickerViewDataSource,UINavigationControllerDelegate {
    var recnumber:[String] =  [String] ()
    static var rem:Reminder?
    public var iterator = 0
    public var i = -1
    
    @IBOutlet weak var showReceivers: UIButton!
    
    @IBOutlet weak var selectReceivers: UIButton!
    // Type Picker
    //----------------------------------------------------------------------------------------------------------------------
    
    
    @IBOutlet weak var typePicker: UIPickerView!
    var pickerData:[String]=["Messages","Instagram Post","Tweet","Post on Facebook","Twitter DM","Slack Message","WhatsApp Message"]
    
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateSaveButtonState()
        switch row
        {
            case  1...3 :
            showReceivers.isEnabled=false
            showReceivers.alpha=0.8
            selectReceivers.isEnabled=false
            selectReceivers.alpha=0.8
            case 4 :
                if !PFTwitterUtils.isLinked(with: PFUser.current()) {
                    let alert = UIAlertController(title: "Error!", message:"Please Link your Twitter Acount First", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default) { _ in }
                    alert.addAction(action)
                    self.present(alert, animated: true){}
                    saveButton.isEnabled=false
                }
                else
                {
                 saveButton.isEnabled=true
                }
                // warn about twitter
            break
            case 5 :
                guard let token:String = PFUser.current()?.value(forKey: "slackToken") as! String else
                {
                    let alert = UIAlertController(title: "Error!", message:"Please Link your Slack Acount First", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default) { _ in }
                    alert.addAction(action)
                    
                    self.present(alert, animated: true){}
                }
                             // warn about slack
            break
            
            default :
            selectReceivers.isEnabled=true
             showReceivers.alpha=1
            showReceivers.isEnabled=true
            selectReceivers.alpha=1
        }
            
            }
    
    
    //*********************************************************************************************************************
    
    
    
    // Image
    //----------------------------------------------------------------------------------------------------------------------
    
    let imagePicker = UIImagePickerController()
    var imageToUpload : UIImage?  = nil
    @IBOutlet weak var imageView: UIImageView!
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func setImage(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
            imageToUpload = pickedImage
        }
        	
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func removeImage(_ sender: UIButton) {
        imageView.image = #imageLiteral(resourceName: "noImageSelected.jpg")
        imageToUpload=nil
        
        //  clear image in Parse server
        
    }
    //*********************************************************************************************************************
    
    

    // Notifcation
    //----------------------------------------------------------------------------------------------------------------------
    
    
    func scheduleNotification(at date: Date , withcontent text : String , toContacts con : [String] , Reminder rem : Reminder ) {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        let content = UNMutableNotificationContent()
        content.categoryIdentifier="myCategory"
        content.title = "Send this Text to ?"
        content.body = text
        content.sound = UNNotificationSound.default()
        var i:Int = 0
        
        i =  typePicker.selectedRow(inComponent: 0)
        print(i)
        content.userInfo["body"]=text
        content.userInfo["type"]=pickerData[i]
        content.userInfo["dest"] = con
        content.userInfo["image"]=rem.image?.url?.replacingOccurrences(of: "localhost", with: "192.168.1.17")
        let request = UNNotificationRequest(identifier: (rem.objectId)! , content: content, trigger: trigger )
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [(rem.objectId)!])
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }
    
     //*********************************************************************************************************************
    
    // Contact
    //----------------------------------------------------------------------------------------------------------------------
    
    var contactStore = CNContactStore()
    var contacts : [CNContact] = []
    func askForContactAccess() {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus {
        case .denied, .notDetermined:
            self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
                if !access {
                    if authorizationStatus == CNAuthorizationStatus.denied {
                        DispatchQueue.main.async(execute: { () -> Void in
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            let alertController = UIAlertController(title: "Contacts", message: message, preferredStyle: UIAlertControllerStyle.alert)
                            
                            let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) -> Void in
                            }
                            
                            alertController.addAction(dismissAction)
                            
                            self.present(alertController, animated: true, completion: nil)
                        })  
                    }  
                }  
            })  
            break  
        default:  
            break  
        }  
    }
    
    // select receivers
    public var receivers = [String]()
    @IBAction func selectReceiver(_ sender: UIButton) {
         let i = typePicker.selectedRow(inComponent: 0)
        switch i {
        case 0,6 :
            self.askForContactAccess()
            let contactPicker = CNContactPickerViewController()
            contactPicker.delegate = self
            self.present(contactPicker, animated: true, completion: nil)
        case 4 :
            //Selecting Twitter users , Done
            let verify = URL(string: "https://api.twitter.com/1.1/friends/list.json")
            let request = NSMutableURLRequest(url: verify!)
            PFTwitterUtils.twitter()!.sign(request)
            
            Alamofire.request(request as URLRequest).validate().responseJSON() { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        Shared.twitterUsers.removeAll()
                        json.dictionary?["users"]?.array?.forEach {
                            element in
                            
                            Shared.twitterUsers.append(twitterUser(name: (element.dictionary?["name"]?.stringValue)!, screenname: (element.dictionary?["screen_name"]?.stringValue)!))
                            }
                        
                        DispatchQueue.main.async(execute: { () -> Void in
                            
                            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pickReceivers")
                            _ = viewController.childViewControllers[0] as! PickReceiversTableViewController
                            self.present(viewController, animated: true, completion: nil)
                        })

                    }
                case .failure(let error):
                    print(error)
                }
            }
            
        case 5 :
            //Selecting Slack users , TBC
            
            if let token:String = PFUser.current()?.value(forKey: "slackToken") as? String
            {
            let listuser = NSMutableURLRequest(url: NSURL(string: "https://slack.com/api/channels.list?token=\(token)") as! URL)
            print(listuser)
            listuser.httpMethod = "POST"
            listuser.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Accept")
                
                Alamofire.request(listuser as URLRequest).responseJSON() { response in
                    switch response.result {
                    case .success:
                        if let value = response.result.value {
                            let json = JSON(value)
                            Shared.twitterUsers.removeAll()
                            json.dictionary?["channels"]?.array?.forEach {
                                element in
                                
                                Shared.twitterUsers.append(twitterUser(name: (element.dictionary?["name"]?.stringValue)!, screenname: (element.dictionary?["id"]?.stringValue)!))
                            }
                            
                            DispatchQueue.main.async(execute: { () -> Void in
                                
                                let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pickReceivers")
//                                viewController = viewController.childViewControllers[0] as! PickReceiversTableViewController
                                
                                self.present(viewController, animated: true, completion: nil)
                            })
                            
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
                

            }
        default : break

    }
        
    }
    
    
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        let isPresentingInAddReminderMode = presentingViewController is UINavigationController
        if isPresentingInAddReminderMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
    }
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        picker.dismiss(animated: true, completion: nil)
        self.contacts=contacts
        print(contacts)
    }

    
    
    
    
    
    //*********************************************************************************************************************

    
    
    @IBAction func SaveAction(_ sender: UIBarButtonItem) {
    
        if(AddReminderViewController.rem == nil){
            AddReminderViewController.rem = Reminder()
        }
        HomeViewController.reminders.forEach {x in
            if AddReminderViewController.rem === x
            { i = iterator }
            iterator+=1
        }
        if (i != -1) {HomeViewController.reminders.remove(at: i) }
            AddReminderViewController.rem?.setValue(ReminderContent.text, forKey: "content")
            AddReminderViewController.rem?.setValue(ReminderTitle.text, forKey: "title")
            AddReminderViewController.rem?.setValue(ReminderDate.date, forKey: "datetime")
        
            AddReminderViewController.rem?.setValue(pickerData[typePicker.selectedRow(inComponent: 0)], forKey: "type")
        if((imageToUpload) != nil)
        {
        let imageData = UIImageJPEGRepresentation(imageToUpload!, 0.5)
        let imageFile = PFFile(name:"image.jpg", data:imageData!)
        AddReminderViewController.rem?.setValue(imageFile, forKey: "image")
        }
        
        if (i != -1) { HomeViewController.reminders.insert(AddReminderViewController.rem!, at: i)}
        else { HomeViewController.reminders.append(AddReminderViewController.rem!)}
        
        if( (AddReminderViewController.rem?.value(forKey: "type") as! String) == "Messages" || (AddReminderViewController.rem?.value(forKey: "type") as! String) == "WhatsApp Message")
        {
            var recnumber:[String] =  AddReminderViewController.rem?.value(forKey: "dest") as? [String] ?? []
     
        if(contacts.count != 0)
        {
            
            contacts.forEach({con in
                if con.phoneNumbers.count>0
                {
                    recnumber.append(((con.phoneNumbers[0].value ).value(forKey: "digits") as? String!)!)
//                recnumber.append(con.identifier)
                }}
            )
            
        AddReminderViewController.rem?.setValue(recnumber, forKey: "dest")
            }}
        
         print(AddReminderViewController.rem?.value(forKey: "dest"))
       
        
        let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150)) as UIActivityIndicatorView
        spinner.startAnimating()
        AddReminderViewController.rem?.saveInBackground(block:
            {t in
                
                self.scheduleNotification(at: self.ReminderDate.date , withcontent: self.ReminderContent.text! , toContacts:AddReminderViewController.rem?.value(forKey: "dest") as? [String] ?? [] , Reminder: AddReminderViewController.rem!)
                spinner.stopAnimating()
                    print("notification saved")
            }
        )
        
      
        performSegue(withIdentifier: "unwindToReminderList", sender: saveButton)
        
    }
    

    @IBAction func dateChanged(_ sender: UIDatePicker) {
        updateSaveButtonState()
    }
    

    @IBOutlet weak var theScrollView: UIScrollView!
    var inset = CGFloat(1.0)
    @IBOutlet weak var ReminderDate: UIDatePicker!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var ReminderContent: UITextField!
    @IBOutlet weak var ReminderTitle: UITextField!
    
    override func viewDidLoad() {
        
        
        saveButton.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.init(white: 0.8, alpha: 0.8)], for: .disabled)
        inset = theScrollView.contentInset.bottom
        super.viewDidLoad()
        updateSaveButtonState()
//        PFTwitterUtils.unlinkUser(inBackground: PFUser.current()!)
        imagePicker.delegate=self
        self.typePicker.delegate = self
        self.typePicker.dataSource = self
        ReminderContent.delegate = self
        ReminderTitle.delegate=self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        if let rem=AddReminderViewController.rem{
        typePicker.selectRow(pickerData.index(of: rem.value(forKey: "type") as! String)!, inComponent: 0, animated: false)
        ReminderContent.text=rem.value(forKey: "content") as! String?
        ReminderTitle.text=rem.value(forKey: "title") as! String?
        ReminderDate.date=rem.value(forKeyPath: "datetime") as! Date
            if(rem.value(forKey: "image") != nil){
            let file = rem.value(forKey: "image") as! PFFile
            file.getDataInBackground(block: { (data, error) -> Void in
                if  error == nil{
                    let data = data
                    let image = UIImage(data: data!)
                    self.imageView.image=image
                }
            }) }
        } else
        {
            AddReminderViewController.rem = Reminder()
        }
        

    
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let title = ReminderTitle.text ?? ""
     //        let content = ReminderContent.text ?? ""
        
        saveButton.isEnabled = !title.isEmpty
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return false
    }
    func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.theScrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.theScrollView.contentInset = contentInset
    }
    
    
    func keyboardWillHide(notification:NSNotification){
        self.theScrollView.contentInset.bottom = inset
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     super.prepare(for: segue, sender: sender)
//    guard let button = sender as? UIBarButtonItem, button === saveButton  else {
//        if #available(iOS 10.0, *) {
//            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
//        } else {
//            // Fallback on earlier versions
//        }
//        return
//    
//    }
       
        
        
    }


}
