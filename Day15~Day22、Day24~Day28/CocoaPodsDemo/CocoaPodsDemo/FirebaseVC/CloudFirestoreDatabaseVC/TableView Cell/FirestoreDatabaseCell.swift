//
//  FirestoreDatabaseCell.swift
//  CocoaPodsDemo
//
//  Created by Leo Ho on 2021/8/22.
//

import UIKit

class FirestoreDatabaseCell: UITableViewCell {

    @IBOutlet weak var messagePeople: UILabel!
    @IBOutlet weak var messageContent: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
