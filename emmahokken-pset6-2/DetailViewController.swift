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
    
    var collectionName = String()
    var artistName = String()
    var trackCount = String()
    var trackName = String()
    var buy = String()
    var art = String()
    
    // MARK: - Outlets
    
    @IBOutlet weak var albumArtwork: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var trackCountLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create sign out button.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut))
        
        // Set title to trackName.
        navigationItem.title = trackName
        
        // Populate labels with info from SearchViewController.
        artistLabel.text = artistName
        albumLabel.text = collectionName
        trackCountLabel.text = trackCount
        
        // Download image from url.
        let getArtwork = URLSession.shared.dataTask(with: URL(string: art)!) { (data, response, error) in
            
            // If no image was found, display default image
            if error != nil {
                DispatchQueue.main.async {
                    if let filePath = Bundle.main.path(forResource: "default-artwork", ofType: "png"), let image = UIImage(contentsOfFile: filePath) {
                        self.albumArtwork.image = image
                    }
                }
            }
            // If image was succesfully found, display image.
            else {
                if let data = data {
                    let image = UIImage(data: data)
                    
                    DispatchQueue.main.async {
                        self.albumArtwork.image = image
                    }
                }
            }
        }
        getArtwork.resume()

        
        // Initialise ability to tap image to view it fullscreen.
        let pictureTap = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.imageTapped(_:)))
        albumArtwork.addGestureRecognizer(pictureTap)
        albumArtwork.isUserInteractionEnabled = true
        
    }
    
    // MARK: - Actions
    
    /// Action when buyButton is tapped.
    @IBAction func buyButtonAction(_ sender: Any) {
        if let url = NSURL(string: buy) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    /// Action to view image fullscreen when image is tapped [1]
    @IBAction func imageTapped (_ sender: UITapGestureRecognizer) {
            let imageView = sender.view as! UIImageView
            let newImageView = UIImageView(image: imageView.image)
            newImageView.frame = UIScreen.main.bounds
            newImageView.backgroundColor = .black
            newImageView.contentMode = .scaleAspectFit
            newImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
            newImageView.addGestureRecognizer(tap)
            self.view.addSubview(newImageView)
            self.navigationController?.isNavigationBarHidden = true
            self.tabBarController?.tabBar.isHidden = true
    }
    
    // MARK: - Functions
    
    /// Disables fullscreen picture mode.
    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    /// Allows user to sign out.
    func signOut() {
        do {
            try FIRAuth.auth()?.signOut()
            performSegue(withIdentifier: "signOut", sender: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError.localizedDescription)
        }
    }
    
    // MARK: - Sources
    
    // [1] http://stackoverflow.com/questions/34694377/swift-how-can-i-make-an-image-full-screen-when-clicked-and-then-original-size
    
}
