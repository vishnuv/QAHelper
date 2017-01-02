//
//  IssueDetailsHeaderCellTableViewCell.swift
//  QAHelper
//
//  Created by Sarath Vijay on 30/11/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit

fileprivate enum IssueStatusTypes: String {
    case ToDo = "To Do", InProgress = "In Progress", Done = "Done"
}

class IssueDetailsHeaderCell: UITableViewCell {

    fileprivate var issueDetails: IssueDetailsResponse?
    var issueStatusTypes = [IssueStatus]()

    @IBOutlet weak var issueTitleLabel: UILabel!
    @IBOutlet weak var issueStatusLabel: UILabel!
    @IBOutlet weak var issueKeyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        issueStatusLabel.layer.cornerRadius = 3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

// MARK: - Public Extensions
extension IssueDetailsHeaderCell {

    func loadData(details: IssueDetailsResponse) {
        issueDetails = details
        if let details = issueDetails {
            issueTitleLabel.text = details.fields?.summary
            issueKeyLabel.text = details.key

            if let statusId = details.fields?.status?.statusId {
                setIssueStatus(statusId:statusId)
            }
            issueStatusLabel.text = details.fields?.status?.name?.uppercased()
        }
        setupUI()
    }
}

// MARK: - Private Extensions
fileprivate extension IssueDetailsHeaderCell {

    func setIssueStatus(statusId: String) {
        let issue = getIssueStatus(statusId: statusId)
        issueStatusLabel.backgroundColor = UIColor(red: 20/255, green: 137/255, blue: 40/255, alpha: 1)
        if let nameValue = issue.name {
            switch nameValue {
            case IssueStatusTypes.ToDo.rawValue:
                issueStatusLabel.backgroundColor = UIColor(red: 74/255, green: 103/255, blue: 133/255, alpha: 1)
            case IssueStatusTypes.InProgress.rawValue:
                issueStatusLabel.backgroundColor = UIColor(red: 255/255, green: 226/255, blue: 140/255, alpha: 1)
            case IssueStatusTypes.Done.rawValue:
                issueStatusLabel.backgroundColor = UIColor(red: 20/255, green: 137/255, blue: 40/255, alpha: 1)
            default:
                break
            }
        }
    }

    func getIssueStatus(statusId: String) -> IssueStatus {
        let predicate:NSPredicate = NSPredicate(format:"statusId == \"\(statusId)\"")
        let subPredicate = [predicate]
        let finalPredicate = NSCompoundPredicate.init(orPredicateWithSubpredicates: subPredicate)

        let filteredArray = (self.issueStatusTypes as NSArray).filtered(using: finalPredicate) as! [IssueStatus]
        print(filteredArray)
        let issue = filteredArray[0] as IssueStatus
        return issue
    }

    func setupUI() {
        issueTitleLabel.font = UIFont.systemFont(ofSize: 20.0, weight: UIFontWeightMedium)
        issueTitleLabel.textColor = UIColor.black
        issueTitleLabel.textAlignment = .left

        issueStatusLabel.font = UIFont.systemFont(ofSize: 10.0, weight: UIFontWeightSemibold)
        issueStatusLabel.textColor = Util.Color.colorRGB(red: 51, green: 51, blue: 51, withAplha: 1)

        issueKeyLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightRegular)
        issueKeyLabel.textColor = Util.Color.colorRGB(red: 163, green: 168, blue: 173, withAplha: 1)
        issueKeyLabel.backgroundColor = UIColor.clear
    }
}
