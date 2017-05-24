//
//  MusicItem.swift
//  emmahokken-pset6-2
//
//  Created by Emma Hokken on 24-05-17.
//  Copyright © 2017 Emma Hokken. All rights reserved.
//

import Foundation
import Firebase


// Form of the Music Item that is needed throughout the app.
struct MusicItem {
    
    let key: String
    let artistName: String
    let collectionName: String
    let trackCount: Int
    let trackName: String
    let trackViewUrl: String
    let artworkUrl30: String
    let artworkUrl100: String
    
    let ref: FIRDatabaseReference?
    
    init(artistName: String, collectionName: String, trackCount: Int, trackName: String, trackViewUrl: String, artworkUrl30: String, artworkUrl100: String, key: String = "") {
        self.key = key
        self.artistName = artistName
        self.collectionName = collectionName
        self.trackCount = trackCount
        self.trackName = trackName
        self.trackViewUrl = trackViewUrl
        self.artworkUrl30 = artworkUrl30
        self.artworkUrl100 = artworkUrl100
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        artistName = snapshotValue["artistName"] as! String
        collectionName = snapshotValue["collectionName"] as! String
        trackCount = snapshotValue["trackCount"] as! Int
        trackName = snapshotValue["trackName"] as! String
        trackViewUrl = snapshotValue["trackViewUrl"] as! String
        artworkUrl30 = snapshotValue["artworkUrl30"] as! String
        artworkUrl100 = snapshotValue["artworkUrl100"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "artistName": artistName,
            "collectionName": collectionName,
            "trackCount": trackCount,
            "trackName": trackName,
            "trackViewUrl": trackViewUrl,
            "artworkUrl30": artworkUrl30,
            "artworkUrl100": artworkUrl100
        ]
    }

}
