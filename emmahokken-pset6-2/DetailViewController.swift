//
//  DetailViewController.swift
//  emmahokken-pset6-2
//
//  Created by Emma Hokken on 18-05-17.
//  Copyright © 2017 Emma Hokken. All rights reserved.
//

import UIKit
import Firebase

// Shows a detailed view of the selected music cell.
class DetailViewController: UIViewController {

    // MARK: - Variables
    
    // MARK: - Outlets
    @IBOutlet weak var albumArtwork: UIImageView!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var songsNumber: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buyButtonAction(_ sender: Any) {
        
    }
    // MARK: - Functions
    
    /// allows user to sign out
    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            performSegue(withIdentifier: "signout", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
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
