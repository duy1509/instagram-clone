//
//  CommentTBVCell.swift
//  demo_instagram
//
//  Created by DUY on 6/12/17.
//  Copyright © 2017 duyhandsome. All rights reserved.
//

import UIKit

class CommentTBVCell: UITableViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblComent: UILabel!

    @IBOutlet weak var imgHinhProfile: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layoutIfNeeded()
        self.imgHinhProfile.layer.cornerRadius = 25
        self.imgHinhProfile.layer.masksToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
