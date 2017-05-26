//
//  SearchViewController.swift
//  emmahokken-pset6-2
//
//  Created by Emma Hokken on 18-05-17.
//  Copyright © 2017 Emma Hokken. All rights reserved.
//


// TO DO:
// Buy link bug fix
// Log in User view fix


import UIKit
import Firebase

/// View Controller allows user to search for music
class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    // MARK: - Variales
    var ref: FIRDatabaseReference!
    var items: [MusicItem] = []
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Set reference to database.
        ref = FIRDatabase.database().reference().child("music")
        
        // Add sign out button.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut))
        
        // Hide default back button.
        self.navigationItem.hidesBackButton = true
        
        searchBar.delegate = self
        
        // Read database to load info.
        readDatabase()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Functions
    
    /// Search for music when search button is clicked.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Search for music.
        lookupMusic(title: searchBar.text!)
        
        // Dismiss keyboard.
        view.endEditing(true)
        
        // Empty search bar.
        searchBar.text = ""
    }
    
    /// Allows user to sign out.
    func signOut() {
        do {
            try FIRAuth.auth()?.signOut()
            performSegue(withIdentifier: "signOut", sender: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    /// Allows user to search for music.
    func lookupMusic(title: String) {
        
        // Replace spaces with "+" to create proper url.
        let search = title.components(separatedBy: " ").joined(separator: "+")
        
        // Url that is used to search for music. Search is limited to one result.
        let url = URL(string: "https://itunes.apple.com/search?term="+search+"&limit=1")
        
        //
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            do {
                let musicObject = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                
                // If there are no results, alert user.
                if (musicObject?["resultCount"] as! Int) == 0 {
                    self.alertUser(title: "Whoops!", message: "Song not found")
                }
                // If there is a result, call addMusic function.
                else {
                    if let musicDictionary = (musicObject?["results"] as? [NSDictionary])?.first {
                        // If search is part of album (and thus has no trackName), warn user.
                        if musicDictionary["trackName"] == nil {
                            self.alertUser(title: "Whoops!", message: "Unable to find song. :(")
                        }
                        // If track has no album, warn user.
                        else if musicDictionary["collectionName"] == nil {
                            self.alertUser(title: "WHoops!", message: "Unable to find song. :(")
                        }
                        // If search has no artist, warn user.
                        else if musicDictionary["artistName"] == nil {
                            self.alertUser(title: "Whoops!", message: "Unable to find song. :(")
                        }
                        // If search entered is not a song.
                        else if (musicDictionary["trackName"] as! String) != title {
                            self.alertUser(title: "Whoops!", message: "Please enter a song name.")
                        }
                        // If everything went right, add song to Firebase.
                        else {
                            self.addMusic(musicDictionary: musicDictionary)
                        }
                    }
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
    
    /// Adds music to Firebase Database.
    func addMusic(musicDictionary: NSDictionary) {
        
        // Get the name of the song from dictionary.
        let musicID = musicDictionary["trackName"] as! String
        
        // Name the new child in Firebase with the name of song.
        self.ref.child(musicID).setValue(musicDictionary)
    }
    
    /// Function to alert users with a custom message.
    func alertUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Dismiss alert when "Ok" is pressed.
        alert.addAction(UIAlertAction(title: "Ok.", style: .cancel) { (action:UIAlertAction!) in
        })
        
        // Present alert.
        self.present(alert, animated: true, completion: nil)
        
    }

    /// Reads information from Firebase Database.
    func readDatabase() {
        
        ref.observe(.value, with: { snapshot in
            
            // Initialise new items with use of struct.
            var newItems: [MusicItem] = []
            
            // Get information for each of the children in the "music" table
            for item in snapshot.children {
                
                let musicItem = MusicItem(snapshot: item as! FIRDataSnapshot)
                
                // Add new item to struct.
                newItems.append(musicItem)
            }
            
            // Add "newItem" to items struct.
            self.items = newItems
            
            // Reload tableView.
            self.tableView.reloadData()

        })
    }
    
    // MARK: - Table View Functions
    
    /// Determines number of rows in tableView.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    /// Populates cell in each row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Initialise reference to cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell") as! MusicViewCell
        
        // Select correct information for row.
        let musicItem = items[indexPath.row]
        
        // Populate elements in cell.
        cell.trackNameLabel.text = musicItem.trackName
        cell.artistNameLabel.text = musicItem.artistName
        
        // Get the image from url [1].
        let getArtwork = URLSession.shared.dataTask(with: URL(string: musicItem.artworkUrl30)!) { (data, response, error) in
            
            // If no image was found, display default image
            if error != nil {
                DispatchQueue.main.async {
                    if let filePath = Bundle.main.path(forResource: "default-artwork", ofType: "png"), let image = UIImage(contentsOfFile: filePath) {
                        cell.albumArtwork.image = image
                    }
                }
            // if image succeeds give image to movieImage
            } else {
                if let data = data {
                    let image = UIImage(data: data)
                    
                    DispatchQueue.main.async {
                        cell.albumArtwork.image = image
                    }
                }
            }
        }
        getArtwork.resume()

        
        return cell
    }
    
    /// When selecting a row, information for that specific row is selected.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detail", sender: self)
    }
    
    /// Allows user to edit rows.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    /// Allows user to swipe left to delete items.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let musicItem = items[indexPath.row]
            musicItem.ref?.removeValue()
        }
    }
    
    // MARK: - Segues
    
    /// Prepare information for next view.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // If the segue is towards DetailViewController [2].
        if segue.identifier == "detail" {
            // Determine destination.
            let viewMusic = segue.destination as! DetailViewController
            
            // Create indexPath for selected row.
            let musicItem = items[tableView.indexPathForSelectedRow!.row]
            
            // Convert trackCount integer to String.
            let tracount = String(musicItem.trackCount)
            
            // Take information from cell with you to next view.
            viewMusic.album = musicItem.collectionName
            viewMusic.artist = musicItem.artistName
            viewMusic.name = musicItem.trackName
            viewMusic.count = tracount
            viewMusic.buy = musicItem.trackViewUrl
            
            // Get the image from url.
            let getArtwork = URLSession.shared.dataTask(with: URL(string: musicItem.artworkUrl100)!) { (data, response, error) in
                
                // If no image was found, display default image
                if error != nil {
                    DispatchQueue.main.async {
                        if let filePath = Bundle.main.path(forResource: "default-artwork", ofType: "png"), let image = UIImage(contentsOfFile: filePath) {
                            viewMusic.albumArtwork.image = image
                        }
                    }
                }
                // If image was succesfully found, give that image to next view.
                else {
                    if let data = data {
                        let image = UIImage(data: data)
                        
                        DispatchQueue.main.async {
                            viewMusic.albumArtwork.image = image
                        }
                    }
                }
            }
            getArtwork.resume()
            
        }
        // If segue is towards LoginViewController.
        else if segue.identifier == "signOut" {
            let signOut = segue.destination as! LogInViewController
        }
        
    }
    
    

    // MARK: - Sources
    // [1] http://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
    // [2] https://stackoverflow.com/questions/31457300/swift-prepareforsegue-with-two-different-segues
    
    
    
}
