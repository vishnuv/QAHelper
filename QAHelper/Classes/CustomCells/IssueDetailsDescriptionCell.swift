//
//  IssueDetailsDescriptionCell.swift
//  QAHelper
//
//  Created by Sarath Vijay on 01/12/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit

class IssueDetailsDescriptionCell: UITableViewCell {

    fileprivate var issueDetails: IssueDetailsResponse?

    @IBOutlet weak var issueDescriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension IssueDetailsDescriptionCell {

    func loadData(details: IssueDetailsResponse) {
        issueDetails = details
        if let details = issueDetails {
            issueDescriptionLabel.text = details.fields?.issueDescription
        }
        setupUI()
    }
}

fileprivate extension IssueDetailsDescriptionCell {
    func setupUI() {
        issueDescriptionLabel.font = UIFont.systemFont(ofSize: 18.0, weight: UIFontWeightRegular)
        issueDescriptionLabel.textColor = Util.Color.colorRGB(red: 51, green: 51, blue: 51, withAplha: 1)
        issueDescriptionLabel.textAlignment = .left
    }
}
