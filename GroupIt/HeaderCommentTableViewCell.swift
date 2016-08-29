//
//  HeaderCommentTableViewCell.swift
//  GroupIt
//
//  Created by Ally Koo on 4/24/16.
//  Copyright © 2016 Akkshay Khoslaa. All rights reserved.
//

import UIKit

class HeaderCommentTableViewCell: UITableViewCell {
    @IBOutlet weak var classTitle: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var postBodyText: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
