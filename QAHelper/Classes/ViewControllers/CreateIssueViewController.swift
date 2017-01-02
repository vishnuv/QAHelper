//
//  CreateIssueViewController
//  QAHelper
//
//  Created by Vishnu Vardhan PV on 12/12/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import Foundation
import UIKit
import KMPlaceholderTextView

fileprivate enum CellTypes:Int {
    case SummaryCell, DescriptionCell, ImagePreviewCell, AssigneeCell
}

fileprivate enum CellHeight: CGFloat {
    case NormalCell = 80
    case ImagePreviewCell = 160
}

fileprivate enum Placeholders: String {
    case SummaryPlaceholder = "Summary"
    case DescriptionPlaceholder = "Description"
    case AssigneePlaceholder = "Assignee"
}

class CreateIssueViewController: UITableViewController {

    var assignee: User?
    var issueSummary: String?
    var issueDescription: String?
    var currentTextView: UITextView?
    var keyboardHeight: CGFloat?
    var issueTypeBugId: String?
    var attachmentUrl: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        customizeNavigationBar()
        if let path = Util.getSavedImageFilePath() {
            attachmentUrl = URL.init(fileURLWithPath: path)
        }
        self.tableView?.estimatedRowHeight = CellHeight.NormalCell.rawValue
        self.tableView?.rowHeight = UITableViewAutomaticDimension
    }
}

extension CreateIssueViewController {
    // MARK: Customise navigation bar with title, search and add button.
    func customizeNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = Util.getApplicationBlueColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.black]
        Util.customizeNavigationBarWithTitle(title: Constants.NavigationBarTitles.newIssueTitle, rightButtons: [Constants.Images.createImage], rightButtonSelectors: [#selector(CreateIssueViewController.createNewIssue)], leftButtons: [Constants.Images.closeImage], leftButtonSelectors: [#selector(CreateIssueViewController.closeView)], forViewController:self)
    }

    func closeView() {
        self.navigationController!.popViewController(animated: true)
    }

    // MARK: Call Create issue API
    func createNewIssue() {
        if let errorMessage = validateData() {
            Util.showAlertWithTitle(title: Constants.AlertTitlesAndMessages.errorTitle, message: errorMessage, forViewController: self, okButtonAction: {})
        } else {
            CreateIssueAPIManager.createIssue(userName: JiraAccountDetails.sharedInstance.username, password: JiraAccountDetails.sharedInstance.password, issueTypeId: self.issueTypeBugId, summary: issueSummary!, description: issueDescription!, assigneeName: assignee?.name!) { (details, error) in
                if let error = error {
                    debugPrint("Error: \(error)")
                } else {
                    if let dict = details as? [String: Any] {
                        self.addAttachment(issueKey: dict["id"] as! String)
                    }
                }
            }
        }
    }

    // MARK: Call Add Attachment API
    func addAttachment(issueKey: String) {
        if let attachment = attachmentUrl {
            AddAttachmentApiManger.addAttachmentWithoutComment(attachment, issueId: issueKey, userName: JiraAccountDetails.sharedInstance.username, password: JiraAccountDetails.sharedInstance.password) { (response, error) in
                if let error = error {
                    debugPrint("Error: \(error)")
                } else {
                    Util.showAlertWithTitle(title: Constants.AlertTitlesAndMessages.successTitle, message: Constants.AlertTitlesAndMessages.issueCreatedSuccessMessage, forViewController: self, okButtonAction: {
                        self.navigationController!.popViewController(animated: true)
                    })
                }
            }
        }
    }

    func setTextViewData(textView:UITextView) {
        let cell = textView.superview?.superview as? UITableViewCell
        let indexPathOfCell = self.tableView?.indexPath(for: cell!)
        let cellType: CellTypes = CellTypes(rawValue: indexPathOfCell!.row)!
        switch cellType {
        case .SummaryCell:
            issueSummary = textView.text
            break
        case .DescriptionCell:
            issueDescription = textView.text
            break
        default:
            break
        }
    }

    func validateData() -> String? {
        var errorString: String?
        if (issueSummary ?? "").isEmpty {
            errorString = Constants.AlertTitlesAndMessages.summaryMissingMessage
        } else if (issueDescription ?? "").isEmpty {
            errorString = Constants.AlertTitlesAndMessages.descriptionMissingMessage
        } else if assignee == nil {
            errorString = Constants.AlertTitlesAndMessages.assigneeMissingMessage
        }
        return errorString
    }

    func summaryDescriptionCell() -> CreateIssueSummaryDescriptionCell {
        let cell: CreateIssueSummaryDescriptionCell = self.tableView?.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.CreateIssueSummaryDescriptionCell) as! CreateIssueSummaryDescriptionCell
        cell.textView?.autocorrectionType = UITextAutocorrectionType.no
        return cell
    }

    func assigneeCell() -> CreateIssueAssigneeCell {
        let cell: CreateIssueAssigneeCell = self.tableView?.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.AssigneeCell) as! CreateIssueAssigneeCell
        if let user = self.assignee {
            cell.assigneeNameLabel.text = user.displayName!
            cell.assigneeNameLabel.textColor = UIColor.black
        } else {
            cell.assigneeNameLabel?.text = Placeholders.AssigneePlaceholder.rawValue
            cell.assigneeNameLabel.textColor = UIColor.lightGray
        }
        return cell
    }

    func imagePreviewCell() -> CreateIssueImagePreviewCell {
        let cell: CreateIssueImagePreviewCell = self.tableView?.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.CreateIssueImagePreviewCell) as! CreateIssueImagePreviewCell
        if let attachment = attachmentUrl {
            cell.previewImageView?.af_setImage(withURL: attachment)
        }
        return cell
    }

    func navigateToAssigneesListView() {
        let assigneeListView: AssigneeListViewController = Util.getStoryboard(Constants.Storyboards.jira).instantiateViewController(withIdentifier: Constants.StorybordIDs.JiraAssigneeList) as? AssigneeListViewController ?? AssigneeListViewController()
        assigneeListView.selectAssignee = { user in
            if let data = user {
                self.assignee = data
                self.tableView?.reloadData()
            }
        }
        self.navigationController?.pushViewController(assigneeListView, animated: true)
    }

    // MARK: UITableView Delegate Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType: CellTypes = CellTypes(rawValue: indexPath.row)!
        switch cellType {
        case .SummaryCell:
            let cell = summaryDescriptionCell()
            cell.textView?.delegate = self
            cell.textView?.font = UIFont.boldSystemFont(ofSize: 18.0)
            cell.textView?.placeholderFont = UIFont.systemFont(ofSize: 18.0)
            cell.textView?.placeholder = Placeholders.SummaryPlaceholder.rawValue
            return cell
        case .DescriptionCell:
            let cell = summaryDescriptionCell()
            cell.textView?.delegate = self
            cell.textView?.placeholder = Placeholders.DescriptionPlaceholder.rawValue
            return cell
        case .ImagePreviewCell:
            return imagePreviewCell()
        case .AssigneeCell:
            return assigneeCell()
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType: CellTypes = CellTypes(rawValue: indexPath.row)!
        switch cellType {
        case .SummaryCell:
            return UITableViewAutomaticDimension
        case .DescriptionCell:
            return UITableViewAutomaticDimension
        case .ImagePreviewCell:
            return CellHeight.ImagePreviewCell.rawValue
        case .AssigneeCell:
            return CellHeight.NormalCell.rawValue
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellType: CellTypes = CellTypes(rawValue: indexPath.row)!
        if cellType == .AssigneeCell {
            navigateToAssigneesListView()
        } else if cellType == .ImagePreviewCell {
            let cell = imagePreviewCell()
            let storyBoard = Util.getStoryboard(Constants.Storyboards.jira)
            let fullScreenView = storyBoard.instantiateViewController(withIdentifier: "FullScreenImageViewController") as! FullScreenImageViewController
            fullScreenView.previewImage = cell.previewImageView?.image
            let navController = UINavigationController(rootViewController: fullScreenView)
            UIViewController.frontViewController()?.present(navController, animated: true, completion: nil)
        }
    }
}

extension CreateIssueViewController: UITextViewDelegate {

    public func textViewDidChange(_ textView: UITextView) {
        let currentOffset = self.tableView?.contentOffset
        UIView.setAnimationsEnabled(false)
        self.tableView?.beginUpdates()
        self.tableView?.endUpdates()
        UIView.setAnimationsEnabled(true)
        self.tableView?.setContentOffset(currentOffset!, animated: false)
        setTextViewData(textView: textView)
    }
}
