

import UIKit
import Parse
import ParseFacebookUtilsV4
import FacebookLogin
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}


class LoginViewController: UIViewController , UITextFieldDelegate {
    let colors = Colors()
    
    func refresh() {
        view.backgroundColor = UIColor.clear
        let backgroundLayer = colors.gl
        backgroundLayer?.frame = view.frame
        view.layer.insertSublayer(backgroundLayer!, at: 0)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return false
    }
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    @IBAction func loginAction(_ sender: UIButton) {
        var username = self.usernameField.text
        let password = self.passwordField.text
        
        // Validate the text fields
        if username?.characters.count < 5 {
            
            let alert = UIAlertController(title: "Invalid!", message:"Username must be greater than 5 characters", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { _ in }
            alert.addAction(action)
            
            self.present(alert, animated: true){}
            
            
            
        }
        else if password?.characters.count < 7 {
            let alert = UIAlertController(title: "Invalid!", message:"Password must be greater than 8 characters", preferredStyle: .alert)
            //If you want to add action to alert  , insert in {}
            let action = UIAlertAction(title: "OK", style: .default) { _ in }
            alert.addAction(action)
            
            
            self.present(alert, animated: true){}
            
        }
        else {
            // Run a spinner to show a task in progress
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            // Send a request to login
            PFUser.logInWithUsername(inBackground: username!, password: password!, block: { (user, error) -> Void in
                
                // Stop the spinner
                spinner.stopAnimating()
                
                if ((user) != nil) {
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home")
                        self.present(viewController, animated: true, completion: nil)
                    })
                    
                } else {
                    
                    let alert	 = UIAlertController(title: "Error", message:"\(String(describing: error))", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default) { _ in }
                    alert.addAction(action)
                    self.present(alert, animated: true){}
                }
            })
        }
    }
    
    @IBAction func unwindToLogInScreen(_ segue:UIStoryboardSegue) {
    }
    
    @IBAction func fbButtonImpl(_ sender: UIButton) {
        PFFacebookUtils.logInInBackground(withReadPermissions: ["public_profile","email"] ,
                                          block: { (user:PFUser? , error:Error?) -> () in
                                            
                                            if(error != nil)
                                            {
                                                NSLog(error as! String)
                                                //Display an alert message
                                                let myAlert = UIAlertController(title:"Alert", message:error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert);
                                                let okAction =  UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                                                myAlert.addAction(okAction);
                                                self.present(myAlert, animated:true, completion:nil);
                                                
                                                return
                                            }
                                            else
                                            { if((user) != nil)
                                            {
                                                if(user?.isNew)!
                                                {
                                                    let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"first_name,email"])
                                                    
                                                    graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                                                        
                                                        if ((error) != nil)
                                                        {
                                                            print("Error: \(String(describing: error))")
                                                        }
                                                        else
                                                        {
                                                            let data:[String:AnyObject] = result as! [String : AnyObject]
                                                            user?.email=data["email"] as! String?
                                                            user?.username=data["first_name"] as! String?
                                                            user?.saveInBackground()
                                                        }
                                                    })
                                                }
                                                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home")
                                                self.present(viewController, animated: true, completion: nil)
                                                }
                                               
                                            }
                                            
                                            
                                            } as PFUserResultBlock )
        
        
        
        
    }
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        usernameField.delegate=self
        passwordField.delegate=self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
