//
//  SearchTBVCell.swift
//  demo_instagram
//
//  Created by DUY on 6/12/17.
//  Copyright © 2017 duyhandsome. All rights reserved.
//

import UIKit

class SearchTBVCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgHinh: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layoutIfNeeded()
        self.imgHinh.layer.cornerRadius = 25
        self.imgHinh.layer.masksToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
