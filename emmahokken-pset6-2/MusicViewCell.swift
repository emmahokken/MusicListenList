//
//  MusicViewCell.swift
//  emmahokken-pset6-2
//
//  Created by Emma Hokken on 18-05-17.
//  Copyright © 2017 Emma Hokken. All rights reserved.
//

import UIKit

class MusicViewCell: UITableViewCell {

    @IBOutlet weak var albumArtwork: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
