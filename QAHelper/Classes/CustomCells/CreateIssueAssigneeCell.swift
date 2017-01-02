//
//  CreateIssueAssigneeCell.swift
//  QAHelper
//
//  Created by Vishnu Vardhan PV on 05/12/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import Foundation
import UIKit

class CreateIssueAssigneeCell: UITableViewCell {

    @IBOutlet weak var assigneeNameLabel: UILabel!
    @IBOutlet weak var assigneeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
