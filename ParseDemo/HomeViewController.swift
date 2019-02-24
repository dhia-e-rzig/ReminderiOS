

import UIKit
import Parse
import MessageUI
import UserNotifications
import NVActivityIndicatorView



class HomeViewController: UIViewController   {

    static var reminders = [PFObject]()
    let colors = Colors()
    
    func refresh() {
        view.backgroundColor = UIColor.clear
        let backgroundLayer = colors.gl
        backgroundLayer?.frame = view.frame
        view.layer.insertSublayer(backgroundLayer!, at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (PFUser.current() == nil) {
            DispatchQueue.main.async(execute: { () -> Void in
                
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login")
                self.present(viewController, animated: true, completion: nil)
            })
        }
        
        
    }
    
    
        @IBOutlet weak var TableView: UIView!
   
    override func viewDidLoad() {
        let nv = NVActivityIndicatorView(frame: CGRect(x: super.view.frame.size.width  / 2, y: super.view.frame.size.height / 2, width: 100, height: 100) , type: NVActivityIndicatorView.DEFAULT_TYPE, color: UIColor.white)
          refresh()
        nv.startAnimating()
        super.viewDidLoad()
        self.view.addSubview(nv)
        if(PFUser.current() != nil)
        {
        let query = PFQuery(className: "Reminder")
        query.findObjectsInBackground{
            (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                for object in objects! {
                    
                HomeViewController.reminders.append(object)
            
                }
                 let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Table")
                self.present(viewController, animated: true, completion: nil)
                
            }

        }
        
        }
        
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

