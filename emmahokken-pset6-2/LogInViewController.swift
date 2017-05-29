//
//  ViewController.swift
//  emmahokken-pset6-2
//
//  Created by Emma Hokken on 18-05-17.
//  Copyright © 2017 Emma Hokken. All rights reserved.
//
//  Music Listen List is an app that allows users to search for music.
//  The app autmomaticall rembmbers that music. When the user presses the
//  cell with the chosen song, more information about the song is displayed.
//  Here, the user can click a "Buy!" button that transports them to Apple Music.
//  Once there, the user can decide to buy the music.
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
        
        // Specify reference to database.
        ref = FIRDatabase.database().reference()
        
        // Function to let the user stay logged in.
        stayLoggedIn()
        
        // Hide back button (if applicable).
        self.navigationItem.hidesBackButton = true
        
        // Dismiss keyboard when tapping anywhre on screen.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LogInViewController.dismissKeybard))
        view.addGestureRecognizer(tap)
    }

    // MARK: - Actions
    
    // WHen signIn button is pressed, log user in.
    @IBAction func signInButtonAction(_ sender: Any) {
        login()
    }
    
    // When register button is pressed, pop-up alert and register user.
    @IBAction func registerButtonAction(_ sender: Any) {
        
        // Present alert with message.
        let alert = UIAlertController(title: "Welcome!", message: "Enter the email and password you'd like to use.", preferredStyle: .alert)
        
        // Add email textfield.
        alert.addTextField { (textField) in
            textField.placeholder = "Email"
        }
        
        // Add password textfield with secure typing.
        alert.addTextField { (textField) in
            textField.placeholder = "password"
            textField.isSecureTextEntry = true
        }
        
        // When user presses "Ok", register user.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let email = alert?.textFields![0]
            let password = alert?.textFields![1]
            
            // If email or password field are empty, alert user
            if email?.text! == "" || password?.text! == "" {
                self.alertUser(title: "Whoops!", message: "You must provide an email and password.")
            } else {
                self.signUpUser(email: (email?.text)!, password: (password?.text)!)
                email?.text = ""
            }
            
        }))
        
        // Allows for cancel action [1].
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            print("Cancel button tapped");
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Functions
    
    /// Dismiss keyboard when tapping anywhre ont hte screen.
    func dismissKeybard() {
        view.endEditing(true)
    }
    
    /// Allows user to register.
    func signUpUser(email: String, password: String) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            // if the error is not empty, print it
            if error != nil {
                self.alertUser(title: "Whoops!", message: "Unable to register user.")
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
                    self.alertUser(title: "Whoops!", message: "Unable to register user.")
                    return
                }
                // if things went succesfully, send user to next window
                else {
                    self.performSegue(withIdentifier: "signIn", sender: self)
                }
                
                self.dismiss(animated: true, completion: nil)
            })
        })
    }
    
    /// Allows user to log in.
    func login() {
        FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
            // If an error occured, alert user.
            if error != nil {
                self.alertUser(title: "Whoops!", message: "Unable to log in user.")
                return
            } else {
                self.performSegue(withIdentifier: "signIn", sender: self)
            }})
        
        self.dismiss(animated: true, completion: nil )
    }
    
    /// Let user stay logged in [2].
    func stayLoggedIn() {
        let currentUser = FIRAuth.auth()?.currentUser
        if currentUser != nil {
            performSegue(withIdentifier: "signIn", sender: nil)
        }
    }
    
    /// Function to alert users with a custom message.
    func alertUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Dismiss alert when "Ok" is pressed.
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel) { (action:UIAlertAction!) in
        })
        
        // Present alert.
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Sources
    // [1] http://swiftdeveloperblog.com/code-examples/create-uialertcontroller-with-ok-and-cancel-buttons-in-swift/
    // [2] https://stackoverflow.com/questions/42381188/swift-app-staying-signed-in-with-firebase
    
}

