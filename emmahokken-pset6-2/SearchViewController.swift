//
//  SearchViewController.swift
//  emmahokken-pset6-2
//
//  Created by Emma Hokken on 18-05-17.
//  Copyright © 2017 Emma Hokken. All rights reserved.
//

import UIKit
import Firebase

/// View Controller allows user to search for music
class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    // MARK: Variales
    var ref = Database.database().reference().child("music")
//    var searches = [String]()
    
    var items: [MusicItem] = []
    
    var henk = [NSDictionary]()
    
    var currentIndex: Int?

    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut))
        
        searchBar.delegate = self
        

        readDatabase()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Functions
    
    /// search for music when search button clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        lookupMusic(title: searchBar.text!)
        view.endEditing(true)
        searchBar.text = ""
        readDatabase()
        self.tableView.reloadData()
    }
    
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
                print(musicObject!["results"]!)
                
                // If there is a result, call addMusic function.
                if let musicDictionary = (musicObject?["results"] as? [NSDictionary])?.first {
                    self.addMusic(musicDictionary: musicDictionary)
                }
                
                // Reload tableView.
                DispatchQueue.main.async {
                    self.tableView.reloadData()
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
            print("Cancel button tapped");
        })
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    /// Get poster from url [1].
    func getArtwork(art: String) -> UIImage {
        
        var address = art.replacingOccurrences(of: "http://", with: "https://")

        // Convert string to url.
        let url = URL(string: address)
        
        // Get contents of url.
        let data = try! Data(contentsOf: url!)
        
        // Convert data into image.
        let image = UIImage(data: data)
        
        return image!
    }

    /// Reads information from Firebase Database.
    func readDatabase() {
        
        ref.observe(.value, with: { snapshot in
            
            // Initialise new items with use of struct.
            var newItems: [MusicItem] = []
            
            // Get information for each of the children in the "music" table
            for item in snapshot.children {
                
                let musicItem = MusicItem(snapshot: item as! DataSnapshot)
                
                // Add new item to struct.
                newItems.append(musicItem)
            }
            
            // Add "newItem" to items struct.
            self.items = newItems
            
            // Reload tableView.
            self.tableView.reloadData()

        })
    }
    
    
    // MARK: TABLE VIEW FUNCTIONS
    
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
        cell.artistLabel.text = musicItem.artistName
        cell.albumLabel.text = musicItem.collectionName
        // Get the image from url.
        let getArtwork = URLSession.shared.dataTask(with: URL(string: musicItem.artworkUrl30)!) { (data, response, error) in
            
            // If no image was found, display default image
            if error != nil {
                DispatchQueue.main.async {
                    if let filePath = Bundle.main.path(forResource: "default-artwork", ofType: "jpg"), let image = UIImage(contentsOfFile: filePath) {
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
            items.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Determine destination.
        let viewMusic = segue.destination as! DetailViewController
        
        // Create indexPath for selected row.
        let musicItem = items[tableView.indexPathForSelectedRow!.row]
        
        // Convert trackCount integer to String.
        let tracount = String(musicItem.trackCount)
        print(musicItem.artistName, "+", musicItem.collectionName, "+ track: ", musicItem.trackName, "+", tracount, "+", musicItem.trackViewUrl)
        
        // Take information from cell with you to next view.
        viewMusic.album = musicItem.collectionName
        viewMusic.artist = musicItem.artistName
        viewMusic.name = musicItem.trackName
        viewMusic.count = tracount
        viewMusic.buy = musicItem.trackViewUrl
        
        // Get the image from url.
        let getArtwork = URLSession.shared.dataTask(with: URL(string: musicItem.artworkUrl30)!) { (data, response, error) in
            
            // If no image was found, display default image
            if error != nil {
                DispatchQueue.main.async {
                    if let filePath = Bundle.main.path(forResource: "default-artwork", ofType: "jpg"), let image = UIImage(contentsOfFile: filePath) {
                        viewMusic.albumArtwork.image = image
                    }
                }
            // If image was succesfully found, give that image to next view
            } else {
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
    
    

    // MARK: - Sources
    // [1] http://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
    
}
