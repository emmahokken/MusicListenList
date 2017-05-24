//
//  ViewController.swift
//  emmahokken-pset6-2
//
//  Created by Emma Hokken on 18-05-17.
//  Copyright © 2017 Emma Hokken. All rights reserved.
//

import UIKit
import Firebase

class LogInViewController: UIViewController {

    // MARK: - Variables
    var ref: FIRDatabaseReference!
    
    // MARK: - Outlets
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ref = FIRDatabase.database().reference()
        stayLoggedIn()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Actions
    
    @IBAction func signInButtonAction(_ sender: Any) {
        login()
    }
    
    
    @IBAction func registerButtonAction(_ sender: Any) {
        
//        let alert = UIAlertController(title: "Register",
//                                      message: "Register",
//                                      preferredStyle: .alert)
//        
//        let saveAction = UIAlertAction(title: "Save",
//                                       style: .default) { action in
//                                        
//        }
//        
//        let cancelAction = UIAlertAction(title: "Cancel",
//                                         style: .default)
//        
//        alert.addTextField { textEmail in
//            textEmail.placeholder = "Enter your email"
//        }
//        
//        alert.addTextField { textPassword in
//            textPassword.isSecureTextEntry = true
//            textPassword.placeholder = "Enter your password"
//        }
//        
//        alert.addAction(saveAction)
//        alert.addAction(cancelAction)
//        
//        present(alert, animated: true, completion: nil)
    
        let alert = UIAlertController(title: "welcome", message: "enter your the username and password you'd like to use", preferredStyle: .alert)
        
        _ = alert.addTextField { (textField) in
            textField.placeholder = "email"
        }
        
        _ = alert.addTextField { (textField) in
            textField.placeholder = "password"
            textField.isSecureTextEntry = true
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let email = alert?.textFields![0]
            let password = alert?.textFields![1]
            print("Text field: \(email?.text)")
            
            if email?.text! == "" || password?.text! == "" {
                print("Empty String")
            } else {
                self.signUpUser(email: (email?.text)!, password: (password?.text)!)
                email?.text = ""
                
            }
            
        }))
        
        // allows for cancel action [1]
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            print("Cancel button tapped");
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Functions
    
    /// allows user to register
    func signUpUser(email: String, password: String) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            // if the error is not empty, print it
            if error != nil {
                print(error!)
                return
            }
            guard (user?.uid) != nil else {
                return
            }
            
            let userRef = self.ref.child("users").child("uid")
            let values = ["email": email, "password": password]
            
            // update new info into table
            userRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                if error != nil {
                    print(error!)
                    return
                }
                // if things went succesfully, send user to next window
                else {
                    self.performSegue(withIdentifier: "signIn", sender: self)
                    print("User sigend up!")
                }
                
                self.dismiss(animated: true, completion: nil)
            })
        })
    }
    
    /// allows user to log in
    func login() {
        FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
            if error != nil {
                print(error!)
                return
            } else {
                print("User logged in!")
                self.performSegue(withIdentifier: "signIn", sender: self)
            }})
        
        
        self.dismiss(animated: true, completion: nil )
    }
    
    /// let user stay logged in [2]
    func stayLoggedIn() {
        let currentUser = FIRAuth.auth()?.currentUser
        if currentUser != nil {
            performSegue(withIdentifier: "signIn", sender: nil)
        }
    }
    
    
    // MARK: - Sources
    // [1] http://swiftdeveloperblog.com/code-examples/create-uialertcontroller-with-ok-and-cancel-buttons-in-swift/
    // [2] https://stackoverflow.com/questions/42381188/swift-app-staying-signed-in-with-firebase
    
}

