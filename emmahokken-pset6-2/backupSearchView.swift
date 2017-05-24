////
////  SearchViewController.swift
////  emmahokken-pset6-2
////
////  Created by Emma Hokken on 18-05-17.
////  Copyright © 2017 Emma Hokken. All rights reserved.
////
//
//import UIKit
//import Firebase
//
///// View Controller allows user to search for music
//class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
////    
//    // MARK: Variales
//    let ref = Database.database().reference()
//    
//    let searches = [String]()
//    
//    //    let toListen = UserDefaults.standard
//    
//    var items: [MusicItem] = []
//    
//    //    var music = [String]()
//    //    var years = [String]()
//    //    var artwork = [String]()
//    //    var songs = [Int]()
//    //    var albums = [String]()
//    //    var artists = [String]()
//    
//    var currentIndex: Int?
//    
//    
//    // MARK: - Outlets
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var searchBar: UISearchBar!
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut))
//        
//        searchBar.delegate = self
//        
//        // 1
//        ref.observe(.value, with: { snapshot in
//            // 2
//            var newItems: [MusicItem] = []
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
//        
//        //        ref.observe(.value, with: { snapshot in
//        //            // 2
//        //            var newItems: [Dictionary] = []
//        //
//        //            // 3
//        //            for item in snapshot.children {
//        //                // 4
//        //                let groceryItem = MusicViewCell(snapshot: item as! DataSnapshot)
//        //                newItems.append(groceryItem)
//        //            }
//        //
//        //            // 5
//        //            self.items = newItems
//        //            self.tableView.reloadData()
//        //        })
//        
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    // MARK: - Functions
//    
//    /// search for music when search button clicked
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        lookupMusic(title: searchBar.text!)
//        view.endEditing(true)
//        searchBar.text = ""
//        reloadTableView()
//    }
//    
//    /// allows user to sign out
//    func signOut() {
//        let firebaseAuth = Auth.auth()
//        do {
//            try firebaseAuth.signOut()
//            performSegue(withIdentifier: "signout", sender: self)
//        } catch let signOutError as NSError {
//            print ("Error signing out: %@", signOutError)
//        }
//        
//    }
//    
//    /// allows user to search for music
//    func lookupMusic(title: String) {
//        let search = title.components(separatedBy: " ").joined(separator: "+")
//        let url = URL(string: "https://itunes.apple.com/search?term="+search+"&limit=1")
//        //        print(url)
//        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
//            do {
//                let musicObject = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
//                print(musicObject!["results"]!)
//                if let musicDictionary = (musicObject?["results"] as? [NSDictionary])?.first {
//                    self.addMusic(musicDictionary: musicDictionary)
//                }
//                
//                DispatchQueue.main.async {
//                    self.reloadTableView()
//                }
//            }
//            catch {
//                print(error)
//            }
//        }
//        task.resume()
//    }
//    
//    
//    func reloadTableView() {
//        self.tableView.reloadData()
//    }
//    
//    func addMusic(musicDictionary: NSDictionary) {
//        
//        let musicID = musicDictionary["trackName"] as! String
//        self.ref.child("music").child(musicID).setValue(musicDictionary)
//    }
//    
//    /// alert users
//    func alertUser(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        
//        
//        alert.addAction(UIAlertAction(title: "Ok.", style: .cancel) { (action:UIAlertAction!) in
//            print("Cancel button tapped");
//        })
//        
//        self.present(alert, animated: true, completion: nil)
//        
//    }
//    
//    /// get poster from url [1]
//    func getArtwork (art: String) -> UIImage {
//        let url = URL(string: (art))
//        let data = try! Data(contentsOf: url!)
//        let image = UIImage(data: data)
//        return image!
//    }
//    
//    
//    func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
//        if !isCompleted {
//            cell.accessoryType = .none
//            cell.textLabel?.textColor = UIColor.black
//            cell.detailTextLabel?.textColor = UIColor.black
//        } else {
//            cell.accessoryType = .checkmark
//            cell.textLabel?.textColor = UIColor.gray
//            cell.detailTextLabel?.textColor = UIColor.gray
//        }
//    }
//    
//    /// read data
//    //    func read() {
//    //        let userID = Auth.auth().currentUser?.uid
//    //        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
//    //            // Get user value
//    //            let value = snapshot.value as? NSDictionary
//    //            let username = value?["username"] as? String ?? ""
//    //            let user = User.init(username: username)
//    //
//    //            // ...
//    //        }) { (error) in
//    //            print(error.localizedDescription)
//    //        }
//    //    }
//    
//    
//    // MARK: - TABLE VIEW FUNCTIONS
//    
//    /// Number of rows
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return searches.count
//    }
//    
//    /// Cell for row
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        let musicItem = items[indexPath.row]
//        
//        cell.textLabel?.text = musicItem.name
//        cell.detailTextLabel?.text = musicItem.addedByUser
//        
//        toggleCellCheckbox(cell, isCompleted: musicItem.completed)
//        
//        return cell
//        
//        
//                let newCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MusicViewCell
//        
//        
//                newCell.artistLabel.text = artists[indexPath.row]
//                newCell.albumLabel.text = albums[indexPath.row]
//        
//                if artwork[indexPath.row] != "N/A" {
//                    newCell.albumArtwork.image = getArtwork(art: artwork[indexPath.row])
//                }
//                else {
//                    newCell.albumArtwork.image = UIImage(named: "default-artwork")
//                }
//        
//                currentIndex = indexPath.row
//                return newCell
//    }
//    
//    /// Did select row at
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//    }
//    
//    /// Can edit row
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return true
//    }
//    
//    /// Comit editing
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        
//    }
//    
//    // MARK: - Segues
//    // take info with you to next window
//    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    //        let viewMusic = segue.destination as! DetailViewController
//    //
//    //        if artwork[tableView.indexPathForSelectedRow!.row] != "N/A" {
//    //            viewMusic.albumArtwork = getArtwork(art: self.artwork[tableView.indexPathForSelectedRow!.row])
//    //        }
//    //        else {
//    //            viewMusic.albumArtwork = UIImage(named: "default_poster")
//    //        }
//    //
//    //        viewMusic. = self.movies[tableView.indexPathForSelectedRow!.row]
//    //        viewMusic.movieYear = self.years[tableView.indexPathForSelectedRow!.row]
//    //        viewMusic.movieDirector = self.directors[tableView.indexPathForSelectedRow!.row]
//    //        viewMusic.movieDescription = self.plots[tableView.indexPathForSelectedRow!.row]
//    //        viewMusic.currentIndex = currentIndex
//    //
//    //
//    //    }
//    
//    
//    // MARK: - Sources
//    // [1] http://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
//    
//    
//    // MARK: - Removed code
//    // lookUpMusic
//    
//    //                    let response = musicDictionary["response"] as? String
//    //                    if response == "False" || search == "" {
//    //                        self.alertUser(title: "Sorry!", message: "Music not found!")
//    //                    }
//    //                    else if self.music.contains(musicDictionary["trackName"] as! String) == true {
//    //                        self.alertUser(title: "Sorry!", message: "This music is already on your to-listen list!")
//    //                    }
//    //                    else {
//    //                        self.addMusic(musicDictionary: musicDictionary)
//    
//}
