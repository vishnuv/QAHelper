//
//  IssueListCell.swift
//  QAHelper
//
//  Created by Denow on 24/Nov/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit

class IssueListCell: UITableViewCell {

    @IBOutlet weak var issueTitle: UILabel!
    @IBOutlet weak var issueDescription: UILabel!
    @IBOutlet weak var issueTypeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
}
