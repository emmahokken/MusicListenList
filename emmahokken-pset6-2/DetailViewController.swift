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
    var album: String = ""
    var artist: String = ""
    var count: String = ""
    var name: String = ""
    var buy: String = ""
    var art = UIImage()
    
    // MARK: - Outlets
    @IBOutlet weak var albumArtwork: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var trackCountLabel: UILabel!

    @IBOutlet weak var buyButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut))
        
        navigationItem.title = name
        
        albumArtwork.image = art
        artistLabel.text = artist
        albumLabel.text = album
        trackCountLabel.text = count
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    @IBAction func buyButtonAction(_ sender: Any) {
        if let url = NSURL(string: buy) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil) }
    }
    
    // MARK: - Functions
    
    /// allows user to sign out
    func signOut() {
        do {
            try FIRAuth.auth()?.signOut()
            performSegue(withIdentifier: "signOut", sender: name)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
}
