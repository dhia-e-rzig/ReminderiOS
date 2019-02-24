//
//  ReminderTableViewCell.swift
//  
//
//  Created by Dhia Elhaq Rzig on 6/14/17.
//
//

import UIKit

class ReminderTableViewCell: UITableViewCell {

    @IBOutlet weak var ReminderNameText: UILabel!
    
    @IBOutlet weak var ReminderContentText: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
