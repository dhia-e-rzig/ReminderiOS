//
//  AccountInfoViewController.swift
//  RemindMe
//
//  Created by Dhia Elhaq Rzig on 7/4/17.
//  Copyright © 2017 devagnos. All rights reserved.
//

import UIKit
import Parse
import ParseTwitterUtils

func loginToSlackWithSafariBrowser() {
    let scope = "channels%3Awrite+users%3Aread+channels%3Aread"
    let clientId = "60201726932.212407189781"
    let redirect_uri = "https://appurl.io/j52auy9a"
    let authURL = NSURL(string: "https://slack.com/oauth/authorize?client_id=\(clientId)&scope=\(scope)&redirect_uri=\(redirect_uri)"
    )
    
    guard let url  = authURL else { return }
    UIApplication.shared.open(url as URL)
}

class AccountInfoViewController: UIViewController {
    @IBAction func AddSlackAccount(_ sender: UIButton) {
        if let _:String = PFUser.current()?.value(forKey: "slackToken") as? String
        {
            PFUser.current()?.remove(forKey: "slackToken")
            slackButton.setTitle("Link Slack Account", for: .normal)
        }
        else {
            loginToSlackWithSafariBrowser()
        }
    }
    
    let colors = Colors()
    func refresh() {
        view.backgroundColor = UIColor.clear
        let backgroundLayer = colors.gl
        backgroundLayer?.frame = view.frame
        view.layer.insertSublayer(backgroundLayer!, at: 0)
    }
    
    
    @IBOutlet weak var slackButton: UIButton!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBAction func saveChanges(_ sender: UIButton) {
        
        //VERIFY this works ?
        let username = self.usernameField.text
        let password = self.passwordField.text
        let email = self.emailField.text
        let finalEmail = email!.trimmingCharacters(in: CharacterSet.whitespaces)
        let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150)) as UIActivityIndicatorView
        spinner.startAnimating()
        PFUser.current()?.setValue(username, forKey: "username")
        PFUser.current()?.setValue(password, forKey: "password")
        PFUser.current()?.setValue(finalEmail, forKey: "email")
        
        
    }
    @IBOutlet weak var twitterButton: UIButton!
    @IBAction func logoutAction(_ sender: UIButton) {
        PFUser.logOut()
        DispatchQueue.main.async(execute: { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login")
            self.present(viewController, animated: true, completion: nil)
        })
    }
    @IBAction func twitterLogin(_ sender: UIButton) {
        let user = PFUser.current()!
        if !PFTwitterUtils.isLinked(with: user) {
            PFTwitterUtils.linkUser(user, block: {
                (succeeded, error) in
                
                if PFTwitterUtils.isLinked(with: user) {
                    self.twitterButton.setTitle("Unlink Twitter Account", for: .normal)
                    PFUser.current()?.saveInBackground()
                }
                else {
                    let alert = UIAlertController(title: "Error !", message:"Error from Twitter : \(error)", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default) { _ in }
                    alert.addAction(action)
                    self.present(alert, animated: true){}
                    
                }
                
            })
        }
        else{
            
            twitterButton.setTitle("Link Twitter Acccount", for: .normal)
            PFTwitterUtils.unlinkUser(inBackground: user)
            PFUser.current()?.saveInBackground()
        }
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        let user = PFUser.current()!
        if PFTwitterUtils.isLinked(with: user){
            twitterButton.setTitle("Unlink Twitter Account", for: .normal)
        }
        else{
            twitterButton.setTitle("Link Twitter Acccount", for: .normal)
        }
        
        if let token:String = PFUser.current()?.value(forKey: "slackToken") as? String
        {
            slackButton.setTitle("Unlink Slack Account", for: .normal)
        }
        else {
            slackButton.setTitle("Link Slack Account", for: .normal)
        }
        self.usernameField.text=PFUser.current()?.username
        self.passwordField.text="Change Password ?"
        self.emailField.text=PFUser.current()?.email
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
