//
//  AssigneeListViewController.swift
//  QAHelper
//
//  Created by Vishnu Vardhan PV on 05/12/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

typealias SelectedAssignee = (User?) -> ()

struct AssigneeListConstants {
    static let searchBarPlaceholder: String = "Search people"
    static let assigneeSearchPredicate = "displayName CONTAINS[cd] %@"
}

class AssigneeListViewController: UIViewController {
    var assigneeList: Array = [User]()
    var selectAssignee: SelectedAssignee?
    var searchBar = UISearchBar()
    var searchActive = false
    var filteredArray = [User]()
    @IBOutlet var assigneeListTableView: UITableView?

    override func viewDidLoad() {
        super.viewDidLoad()
        customizeNavigationBar()

        if assigneeList.count == 0 {
            self.getAllUsers()
        }
    }
}

extension AssigneeListViewController {

    func customizeNavigationBar() {
        Util.customizeNavigationBarWithTitle(title: nil, rightButtons: [], rightButtonSelectors: [], leftButtons: [Constants.Images.backImage], leftButtonSelectors: [#selector(AssigneeListViewController.closeView)], forViewController:self)
        addSearchBar()
    }

    func closeView() {
        self.navigationController!.popViewController(animated: true)
    }

    // MARK: Customise navigation bar to add search bar.
    func addSearchBar() {
        searchBar = UISearchBar(frame: CGRect(x:0, y:0, width:(self.navigationController?.navigationBar.frame.size.width)!, height:IssueListConstants.searchBarHeight))
        searchBar.placeholder = AssigneeListConstants.searchBarPlaceholder
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.showsCancelButton = true
        self.navigationItem.titleView = searchBar
    }

    func getAllUsers() {
        GetAllUsersAPIManager.getAllUsers(userName: JiraAccountDetails.sharedInstance.username, password: JiraAccountDetails.sharedInstance.password) { (details, error) in
            if let assigneeResponse = details {
                debugPrint("details: \(details)")
                self.assigneeList = assigneeResponse
                self.assigneeListTableView?.reloadData()
            } else {
                debugPrint("error: \(error)")
            }
        }
    }
}

extension AssigneeListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filteredArray.count
        }
        return assigneeList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: IssueListCell! = tableView.dequeueReusableCell(withIdentifier: IssueListConstants.issueListCellIdentifier) as? IssueListCell
        if cell == nil {
            let arr = Bundle.main.loadNibNamed(Constants.XIBNames.issueListCell, owner: nil
                , options: nil)
            cell = arr?[0] as? IssueListCell
        }
        if assigneeList.isEmpty == false {
            let assignee: User
            if(searchActive) {
                assignee = filteredArray[indexPath.row]
            } else {
                assignee = assigneeList[indexPath.row]
            }
            cell.issueTitle.text = assignee.displayName
            cell.issueDescription.text = assignee.emailAddress
            cell.issueTypeImageView.af_setImage(withURL: URL(string:"https://qahelper1.atlassian.net/secure/useravatar?avatarId=10345")!)
        }
        return cell
    }
}

extension AssigneeListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return IssueListConstants.issueListCellHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(searchActive) {
            self.selectAssignee?(filteredArray[indexPath.row])
        } else {
            self.selectAssignee?(assigneeList[indexPath.row])
        }
        self.navigationController!.popViewController(animated: true)
    }
}

extension AssigneeListViewController: UISearchBarDelegate {
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let predicate:NSPredicate = NSPredicate(format:AssigneeListConstants.assigneeSearchPredicate, searchText)
        let subPredicate = [predicate]
        let finalPredicate = NSCompoundPredicate.init(orPredicateWithSubpredicates: subPredicate)

        filteredArray = (self.assigneeList as NSArray).filtered(using: finalPredicate) as! [User]
        self.assigneeListTableView?.reloadData()
    }
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = true
        searchBar.resignFirstResponder()
    }
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
        searchBar.text = nil
        self.assigneeListTableView?.reloadData()
    }
}
