//
//  IssueDetailViewController.swift
//  QAHelper
//
//  Created by Denow on 25/Nov/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import KMPlaceholderTextView
import KRProgressHUD

fileprivate struct IssueDetailsConstants {
    static let sectionHeightComments: CGFloat = 50.0
    static let commentsLabelTag = 100
    static let commentsSectionTitle = "Comments"
    static let commentsSectionPlaceHolder = "Type a comment"

    enum IssueDetailsSectionType : Int {
        case IssueDetails, IssueComments
    }

    static let viewBottomDefaultHeight: CGFloat = 48.0
    static let viewBottomBottomDefaultSpace: CGFloat = 0.0
}

fileprivate enum IssueDetailsCellType : Int {
    case IssueDetailsHeader, IssueDetailsDescription, IssueDetailsAttachment, IssueDetailsAssignee
}

class IssueDetailViewController: BaseViewController {

    var issueDetail: IssueDetailsResponse?
    var userList: [User]?
    var issueAssignee: User?
    var attachmentUrl: URL?
    var issueStatusTypes = [IssueStatus]()
    fileprivate var issueAssigneeOld: User?
    fileprivate var isAttachmentUploaded: Bool = false


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewBottom: UIView!

    @IBOutlet weak var viewBottomHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewBottomBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableViewAutomaticDimension
        issueAssigneeOld = issueAssignee
        customizeNavigationBar()
        setupBottomView()
        
        if let path = Util.getSavedImageFilePath() {
            attachmentUrl = URL.init(fileURLWithPath: path)
        }
    }

    deinit {
        debugPrint("deallocated")
        NotificationCenter.default.removeObserver(self)
    }


    func popThisController() {
        _ = self.navigationController?.popViewController(animated: true)
    }

    func keyboardWillShow(not: NSNotification) {
        let keyboardFrame: CGRect = ((not.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue)!
        debugPrint("keyboardFrame: \(keyboardFrame)")

        UIView.animate(withDuration: 0.2, animations: {
            self.viewBottomBottomConstraint.constant = keyboardFrame.height
        })
    }

    func keyboardWillHide(not: NSNotification) {
        let keyboardFrame: CGRect = ((not.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue)!
        debugPrint("keyboardFrame2: \(keyboardFrame)")
        UIView.animate(withDuration: 0.2, animations: {
            self.viewBottomBottomConstraint.constant = 0
        })
    }

    func sendButtonClicked() {
        if var commentText = commentTextView().text {
            if commentText.characters.count < 1 {
                commentText = ""
            }
            if let key = self.issueDetail?.key, let attchUrl = attachmentUrl {
                if isAttachmentUploaded == true {
                    self.addCommentAndUpdateAssigneeWithoutAttachment(comment: commentText, issueKey: key)
                } else {
                    self.addCommentAndUpdateAssignee(comment: commentText, attachmentUrl: attchUrl, issueKey: key)
                }
            }
        }
    }
}


fileprivate extension IssueDetailViewController {

    func commentTextView() -> KMPlaceholderTextView {
        let txtView = self.viewBottom?.viewWithTag(100) as! KMPlaceholderTextView
        return txtView
    }

    func setupBottomView() {
        viewBottom.layer.borderWidth = 1.0
        viewBottom.layer.borderColor = UIColor.lightGray.cgColor
        let txtView = commentTextView()
        txtView.font = UIFont.systemFont(ofSize: 15.0, weight: UIFontWeightRegular)
        txtView.textColor = UIColor.black
        txtView.placeholderColor = Util.Color.colorRGB(red: 206, green: 209, blue: 212, withAplha: 1)
        txtView.textAlignment = .left

        txtView.text = ""
        txtView.placeholder = IssueDetailsConstants.commentsSectionPlaceHolder

        let sendButton = viewBottom.viewWithTag(101) as! UIButton

        sendButton.addTarget(self, action: #selector(IssueDetailViewController.sendButtonClicked), for: .touchUpInside)

        NotificationCenter.default.addObserver(self, selector: #selector(IssueDetailViewController.keyboardWillShow(not:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(IssueDetailViewController.keyboardWillHide(not:)), name: .UIKeyboardWillHide, object: nil)

    }

    func customizeNavigationBar() {
        Util.customizeNavigationBarWithTitle(title: Constants.NavigationBarTitles.myIssuesTitle, rightButtons: [], rightButtonSelectors: [], leftButtons: [Constants.Images.backWhiteImage], leftButtonSelectors: [#selector(IssueDetailViewController.popThisController)], forViewController:self)
    }

    func reloadIssueDetails() {
        if let key = issueDetail?.key{
            IssueDetailsApiManager.getIssueDetails(issueId: key, userName: JiraAccountDetails.sharedInstance.username, password: JiraAccountDetails.sharedInstance.password) { (details, error) in
                if let error = error {
                    debugPrint("Error: \(error)")
                } else {
                    // fetch userList
                    if let details = details {
                        self.issueDetail = details
                        self.issueAssignee = details.fields?.assignee
                        self.issueAssigneeOld = details.fields?.assignee
                        DispatchQueue.main.async {
                            debugPrint("Reload completed")
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }

    func getIssueDetailsHeaderCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IssueDetailsHeaderCell") as! IssueDetailsHeaderCell
        if let detail = issueDetail {
            cell.issueStatusTypes = self.issueStatusTypes
            cell.loadData(details: detail)
        }
        cell.selectionStyle = .none
        return cell
    }

    func  getIssueDetailsDescriptionCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IssueDetailsDescriptionCell") as! IssueDetailsDescriptionCell
        if let detail = issueDetail {
            cell.loadData(details: detail)
        }
        cell.selectionStyle = .none
        return cell
    }

    func getIssueDetailsAttachmentCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IssueDetilsAttachmentsCell") as! IssueDetilsAttachmentsCell
        cell.attachments = issueDetail?.fields?.attachments
        cell.shouldShowNewAttachment = !isAttachmentUploaded
        cell.selectionStyle = .none
        return cell
    }

    func getIssueDetailsAssigneeCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IssueDetailsAssigneeCell") as! IssueDetailsAssigneeCell
        cell.loadData(user: issueAssignee)
        cell.selectionStyle = .none
        return cell
    }

    func showAssigneeSelectionScreen() {
        let assigneeListView: AssigneeListViewController = Util.getStoryboard(Constants.Storyboards.jira).instantiateViewController(withIdentifier: Constants.StorybordIDs.JiraAssigneeList) as? AssigneeListViewController ?? AssigneeListViewController()

        if let list = userList {
            assigneeListView.assigneeList = list
        }

        assigneeListView.selectAssignee = { newAssignee in
            self.issueAssignee = newAssignee

            DispatchQueue.main.async {
                let section = IssueDetailsConstants.IssueDetailsSectionType.IssueDetails.rawValue
                let row = IssueDetailsCellType.IssueDetailsAssignee.rawValue
                let indx = IndexPath(row: row, section: section)
                self.tableView.reloadRows(at: [indx], with: .automatic)
            }

            //TODO: - TEST_MODE Sample
            //            self.sampleAttachmentWithCommentAndAssigneeUpdate()
            //TODO: - TEST_MODE Sample

        }
        self.navigationController?.pushViewController(assigneeListView, animated: true)
    }


    func sampleAttachmentWithCommentAndAssigneeUpdate() {
        let comment = "Comment"
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        debugPrint("docDir: \(docDir)")
        let path = docDir! + "/sample.png" // 'sample.png' will be the name for image there, so the name should be 'screenshot-2016-11-23 18:14:52.png'[sample name] while saving in our directory
        let fileUrl = URL.init(fileURLWithPath: path)
        //TODO: - TEST_MODE
        if let key = self.issueDetail?.key {
            self.addCommentAndUpdateAssignee(comment: comment, attachmentUrl: fileUrl, issueKey: key)
        }
    }

    func addCommentAndUpdateAssignee(comment: String, attachmentUrl: URL, issueKey: String) {
        KRProgressHUD.show()
        AddAttachmentApiManger.addAttachment(attachmentUrl, comment: comment, issueId: issueKey, userName: JiraAccountDetails.sharedInstance.username, password: JiraAccountDetails.sharedInstance.password) { (response, error) in
            KRProgressHUD.dismiss()
            
            if let error = error {
                debugPrint("Error: \(error)")
            } else {
                debugPrint("Attachment and comment succesfully added")
                self.isAttachmentUploaded = true
                if self.issueAssignee?.name == self.issueAssigneeOld?.name {
                    debugPrint("Assignee not updated - No need")
                    self.reloadIssueDetails()
                    self.commentTextView().text = ""
                } else {
                    debugPrint("New assignee: \(self.issueAssignee?.displayName)")
                    if let newName = self.issueAssignee?.name, let key = self.issueDetail?.key {
                        EditIssueApiManager.updateAssignee(newAssigneeName: newName, ToIssue: key, userName: JiraAccountDetails.sharedInstance.username, password: JiraAccountDetails.sharedInstance.password) { (editResp, error) in
                            if let error = error {
                                debugPrint("error: \(error)")
                            } else {
                                debugPrint("response: \(editResp?.isSuccess)")
                                debugPrint("Assignee updated")
                                self.reloadIssueDetails()
                                self.commentTextView().text = ""
                            }
                        }
                    }
                }
            }
        }
    }

    func addCommentAndUpdateAssigneeWithoutAttachment(comment: String, issueKey: String) {
        AddCommentApiManager.addComment(comment: comment, ToIssue: issueKey, userName: JiraAccountDetails.sharedInstance.username, password: JiraAccountDetails.sharedInstance.password, callback: { (response, error) in
            if let error = error {
                debugPrint("Error: \(error)")

            } else {
                debugPrint("Comment succesfully added")
                if self.issueAssignee?.name == self.issueAssigneeOld?.name {
                    debugPrint("Assignee not updated - No need")
                    self.reloadIssueDetails()
                    self.commentTextView().text = ""
                } else {
                    debugPrint("New assignee: \(self.issueAssignee?.displayName)")
                    if let newName = self.issueAssignee?.name, let key = self.issueDetail?.key {
                        EditIssueApiManager.updateAssignee(newAssigneeName: newName, ToIssue: key, userName: JiraAccountDetails.sharedInstance.username, password: JiraAccountDetails.sharedInstance.password) { (editResp, error) in
                            if let error = error {
                                debugPrint("error: \(error)")
                            } else {
                                debugPrint("response: \(editResp?.isSuccess)")
                                debugPrint("Assignee updated")
                                self.reloadIssueDetails()
                                self.commentTextView().text = ""
                            }
                        }
                    }
                }
            }
        })
    }
}

extension IssueDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let section: IssueDetailsConstants.IssueDetailsSectionType = IssueDetailsConstants.IssueDetailsSectionType(rawValue: section)!

        switch section {

        case .IssueDetails:
            return 4
        case .IssueComments:
            return issueDetail?.fields?.issueComment?.comments?.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let section: IssueDetailsConstants.IssueDetailsSectionType = IssueDetailsConstants.IssueDetailsSectionType(rawValue: indexPath.section)!

        if section == .IssueDetails {
            let cellType : IssueDetailsCellType = IssueDetailsCellType(rawValue: indexPath.row)!
            switch cellType {
            case .IssueDetailsHeader: return getIssueDetailsHeaderCell()
            case .IssueDetailsDescription: return getIssueDetailsDescriptionCell()
            case .IssueDetailsAttachment: return getIssueDetailsAttachmentCell()
            case .IssueDetailsAssignee: return getIssueDetailsAssigneeCell()
            }
        } else if section == .IssueComments {

            var cell: IssueCommentCell! = tableView.dequeueReusableCell(withIdentifier: "IssueCommentCell") as? IssueCommentCell
            let arr = Bundle.main.loadNibNamed("IssueCommentCell", owner: nil
                , options: nil)
            if cell == nil {
                cell = arr?[0] as? IssueCommentCell
            }
            if let details = issueDetail {
                let commentDetails = details.fields?.issueComment?.comments?[indexPath.row]
                cell.loadData(details: commentDetails!, usersList: userList)
            }
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}

extension IssueDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let cellType : IssueDetailsCellType = IssueDetailsCellType(rawValue: indexPath.row)!
            switch cellType {
            case .IssueDetailsDescription:
                if let detail = issueDetail {
                    guard let _ = detail.fields?.issueDescription else {
                        return 0
                    }
                }
            default:
                return tableView.rowHeight
            }
        }
        return tableView.rowHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?  {
        let section: IssueDetailsConstants.IssueDetailsSectionType = IssueDetailsConstants.IssueDetailsSectionType(rawValue: section)!
        if section == .IssueComments {
            let arr = Bundle.main.loadNibNamed(Constants.XIBNames.miscCell, owner: nil
                , options: nil)
            let cell: UITableViewCell! = arr?[0] as? UITableViewCell
            let v = cell.contentView
            if let lbl = v.viewWithTag(IssueDetailsConstants.commentsLabelTag) as? UILabel {
                lbl.text = IssueDetailsConstants.commentsSectionTitle
                lbl.font = UIFont.systemFont(ofSize: 18.0, weight: UIFontWeightMedium)
                lbl.textColor = UIColor.black
            }
            return v
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section: IssueDetailsConstants.IssueDetailsSectionType = IssueDetailsConstants.IssueDetailsSectionType(rawValue: section)!
        if section == .IssueComments {
            return IssueDetailsConstants.sectionHeightComments
        }
        return 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section: IssueDetailsConstants.IssueDetailsSectionType = IssueDetailsConstants.IssueDetailsSectionType(rawValue: indexPath.section)!
        if section == .IssueDetails {
            let row: IssueDetailsCellType = IssueDetailsCellType(rawValue: indexPath.row)!
            if row == .IssueDetailsAssignee {
                showAssigneeSelectionScreen()
            }
        }
    }
}

