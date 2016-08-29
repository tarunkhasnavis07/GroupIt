//
//  CommentsTableViewCell.swift
//  GroupIt
//
//  Created by Ally Koo on 4/24/16.
//  Copyright © 2016 Akkshay Khoslaa. All rights reserved.
//

import UIKit
import Parse

class CommentsTableViewCell: UITableViewCell {

    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var commentBodyText: UITextView!
    
    @IBOutlet weak var profPic: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
