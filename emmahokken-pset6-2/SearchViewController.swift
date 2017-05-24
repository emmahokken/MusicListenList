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
    let ref = Database.database().reference()

    let searches = [String]()
    
    var items: [MusicItem] = []
    
    var henk = [NSDictionary]()
    
//    var items = [String]()
    var currentIndex: Int?

    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut))
        
        searchBar.delegate = self
        
        
        
//        // 1
//        ref.observe(.value, with: { snapshot in
//            // 2
//            var newItems: [MusicItem] = []
//            
//            if snapshot is NSDictionary {
//                
//            }
//           
//            
//            // 3
//            for item in snapshot.children {
//                // 4
//                let musicItem = MusicItem(snapshot: item as! DataSnapshot)
//                newItems.append(musicItem)
//            }
//            
//            // 5
//            self.items = newItems
//            self.tableView.reloadData()
//        })

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
        reloadTableView()
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
    
    /// allows user to search for music
    func lookupMusic(title: String) {
        let search = title.components(separatedBy: " ").joined(separator: "+")
        let url = URL(string: "https://itunes.apple.com/search?term="+search+"&limit=1")
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            do {
                let musicObject = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                print(musicObject!["results"]!)
                if let musicDictionary = (musicObject?["results"] as? [NSDictionary])?.first {
                    self.addMusic(musicDictionary: musicDictionary)
                }
                
                DispatchQueue.main.async {
                    self.reloadTableView()
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }

    
    func reloadTableView() {
        self.tableView.reloadData()
    }
    
    func addMusic(musicDictionary: NSDictionary) {
        
        let musicID = musicDictionary["trackName"] as! String
        self.ref.child("music").child(musicID).setValue(musicDictionary)
    }
    
    /// alert users
    func alertUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        
        alert.addAction(UIAlertAction(title: "Ok.", style: .cancel) { (action:UIAlertAction!) in
            print("Cancel button tapped");
        })
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    /// get poster from url [1]
    func getArtwork (art: String) -> UIImage {
        let url = URL(string: (art))
        let data = try! Data(contentsOf: url!)
        let image = UIImage(data: data)
        return image!
    }

    
    func readDatabase() {
        Database.database().reference().child("music").observe(.childAdded, with: { (dataSnapshot) in
            if let henk = (dataSnapshot.value as? NSDictionary) {
                print("Hier stat HENK!!!!!!!!")
                
                self.henk.append(["artistName" : henk["artistName"]!])
                self.tableView.reloadData()
            }
            
        }) { (Error) in
            return
        }
    }
    
    
    // MARK: TABLE VIEW FUNCTIONS
    
    /// Number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return henk.count
    }
    
    /// Cell for row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MusicViewCell
        
        // let musicItem = henk[indexPath.row]
        cell.artistLabel.text = henk[indexPath.row] as? String
        // cell.albumLabel.text = henk["collectionName"] as? String
        
        return cell
            
//        currentIndex = indexPath.row

    }
    
    /// Did select row at
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    /// Can edit row
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    /// Comit editing
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - Segues

    // MARK: - Sources
    // [1] http://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
    
}
