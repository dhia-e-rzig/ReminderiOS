

import UIKit
import Parse
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


class SignUpViewController: UIViewController , UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return false
    }
    
    let colors = Colors()
    
    func refresh() {
        view.backgroundColor = UIColor.clear
        let backgroundLayer = colors.gl
        backgroundLayer?.frame = view.frame
        view.layer.insertSublayer(backgroundLayer!, at: 0)
    }
    
    func isValidEmail(_ testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBAction func signupAction(_ sender: UIButton) {
        var username = self.usernameTextField.text
        var password = self.passwordTextField.text
        let email = self.emailTextField.text
        let finalEmail = email!.trimmingCharacters(in: CharacterSet.whitespaces)
        
        // Validate the text fields
        if username?.characters.count < 5 {
//            let alert = UIAlertView(title: "Invalid", message: "Username must be greater than 5 characters", delegate: self, cancelButtonTitle: "OK")
//            alert.show()
            let alert = UIAlertController(title: "Invalid", message:"Username must be greater than 5 characters", preferredStyle: .alert)
            //If you want to add action to alert  , insert in {}
            let action = UIAlertAction(title: "OK", style: .default) { _ in }
            alert.addAction(action)
            self.present(alert, animated: true){}
        } else if password?.characters.count < 8 {
//            let alert = UIAlertView(title: "Invalid", message: "Password must be greater than 8 characters", delegate: self, cancelButtonTitle: "OK")
//            alert.show()
            let alert = UIAlertController(title: "Invalid", message:"Password must be greater than 8 characters", preferredStyle: .alert)
            //If you want to add action to alert  , insert in {}
            let action = UIAlertAction(title: "OK", style: .default) { _ in }
            alert.addAction(action)
            self.present(alert, animated: true){}
            
            
        } else if (!isValidEmail(email!)) {
//            let alert = UIAlertView(title: "Invalid", message: "Please enter a valid email address", delegate: self, cancelButtonTitle: "OK")
//            alert.show()
            let alert = UIAlertController(title: "Invalid", message:"Please enter a valid email address", preferredStyle: .alert)
            //If you want to add action to alert  , insert in {}
            let action = UIAlertAction(title: "OK", style: .default) { _ in }
            alert.addAction(action)
            self.present(alert, animated: true){}
            
            
        } else {
            // Run a spinner to show a task in progress
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            let newUser = PFUser()
            
            newUser.username = username
            newUser.password = password
            newUser.email = finalEmail
            
            // Sign up the user asynchronously
            newUser.signUpInBackground(block: { (succeed, error) -> Void in
                
                // Stop the spinner
                spinner.stopAnimating()
                if ((error) != nil) {
//                    let alert = UIAlertView(title: "Error", message: "\(error)", delegate: self, cancelButtonTitle: "OK")
//                    alert.show()
                    let alert = UIAlertController(title: "Error", message:"\(String(describing: String(describing: error)))", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default) { _ in }
                    alert.addAction(action)
                    self.present(alert, animated: true){}
                } else {
//                    let alert = UIAlertView(title: "Success", message: "Signed Up", delegate: self, cancelButtonTitle: "OK")
//                    alert.show()
                    let alert = UIAlertController(title: "Success", message:"Signed Up", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default) { _ in }
                    alert.addAction(action)
                    self.present(alert, animated: true){}
                    DispatchQueue.main.async(execute: { () -> Void in
                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home")
                        self.present(viewController, animated: true, completion: nil)
                    })
                }
            })
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        emailTextField.delegate=self
        passwordTextField.delegate=self
        usernameTextField.delegate=self
        // Do any additional setup after loading the view.
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
