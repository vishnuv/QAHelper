//
//  IssuesListViewController.swift
//  QAHelper
//
//  Created by Vishnu Vardhan PV on 23/11/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import Foundation
import UIKit

struct IssueListConstants {
    static let issueListCellIdentifier = "IssueListCell"
    static let issueListCellHeight: CGFloat = 60.0
    static let searchBarHeight: CGFloat = 20.0
    static let searchCancelButtonWidth: CGFloat = 30.0
    static let searchBarPlaceholder: String = "Search by key"
    static let issueSearchPredicate = "key CONTAINS[cd] %@"
    static let issueTypeBugPredicate = "issueName == \"Bug\""
}

class IssuesListViewController: BaseViewController {
    @IBOutlet var issuesTableView: UITableView?
    var searchBar = UISearchBar()
    var issueDetailArray:Array = [IssueDetailsResponse]()
    var filteredIssueDetailArray:Array = [IssueDetailsResponse]()
    var total: Int? = 0
    var startIndex: Int = 0
    var isRefreshing = false
    var searchActive = false
    var issueTypeBugId: String?
    var issueStatusTypes = [IssueStatus]()
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(IssuesListViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeNavigationBar()
        self.issuesTableView?.addSubview(self.refreshControl)
        getAllIssues(withStartIndex:self.startIndex)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        customizeNavigationBarColors()
    }
}

extension IssuesListViewController {
    // MARK: Customise navigation bar to add search bar.
    func addSearchBar() {
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.title = nil
        searchBar = UISearchBar(frame: CGRect(x:0, y:0, width:(self.navigationController?.navigationBar.frame.size.width)!, height:IssueListConstants.searchBarHeight))
        searchBar.placeholder = IssueListConstants.searchBarPlaceholder
        searchBar.showsCancelButton = true
        searchBar.becomeFirstResponder()
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
    }
    // MARK: Customise navigation bar with title, search and add button.
    func customizeNavigationBar() {
        Util.customizeNavigationBarWithTitle(title: Constants.NavigationBarTitles.myIssuesTitle, rightButtons: [Constants.Images.addNewIssueImage, Constants.Images.searchImage], rightButtonSelectors: [#selector(IssuesListViewController.createNewIssue), #selector(IssuesListViewController.addSearchBar)], leftButtons: [], leftButtonSelectors: [], forViewController:self)
    }
    // MARK: Customise navigation bar title and button colors.
    func customizeNavigationBarColors() {
        self.navigationController?.navigationBar.barTintColor = Util.getApplicationBlueColor()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
    }
    // MARK: Calls API to get all issues
    func getAllIssues(withStartIndex startIndex:Int) {
        GetAllIssuesApiManager.getAllIssues(userName: JiraAccountDetails.sharedInstance.username, password: JiraAccountDetails.sharedInstance.password, startIndex: self.startIndex) { (details, error) in
            if let errorResponse = error {
                print(errorResponse)
            } else if let issuesResponse = details as GetAllIssuesResponse? {
                self.getIssueTypes()
                self.total = issuesResponse.total
                if self.isRefreshing {
                    self.isRefreshing = false
                    self.issueDetailArray.removeAll()
                }
                self.issueDetailArray += issuesResponse.issues!
                self.issuesTableView?.tableFooterView = nil
                self.issuesTableView?.reloadData()
            }
        }
    }
    // MARK: Calls API to get the details of a specific issue key on search
    func getIssueDetail(issueKey: String) {
        IssueDetailsApiManager.getIssueDetails(issueId:issueKey, userName: JiraAccountDetails.sharedInstance.username, password: JiraAccountDetails.sharedInstance.password) { (details, error) in
            if let issuesResponse = details as IssueDetailsResponse? {
                self.filteredIssueDetailArray.removeAll()
                self.filteredIssueDetailArray = [issuesResponse]
            } else {
                Util.showAlertWithTitle(title: Constants.AlertTitlesAndMessages.sorryTitle, message: Constants.AlertTitlesAndMessages.noResultFoundMessage, forViewController: self, okButtonAction: {
                })
                self.searchBar.becomeFirstResponder()
            }
            self.issuesTableView?.reloadData()
        }
    }
    // MARK: Calls API to get the issue types
    func getIssueTypes() {
        GetIssueTypesAPIManager.getIssueTypes(userName: JiraAccountDetails.sharedInstance.username, password: JiraAccountDetails.sharedInstance.password) { (details, error) in
            if let errorData = error {
                debugPrint("error: \(errorData)")
            } else if let data = details {
                self.getStatusTypes()
                let predicate:NSPredicate = NSPredicate(format:IssueListConstants.issueTypeBugPredicate)
                let filteredArray = (data as NSArray).filtered(using: predicate) as! [IssueType]
                let issue = filteredArray[0] as IssueType
                self.issueTypeBugId = issue.issueid
            }
        }
    }
    // MARK: Calls API to get the issue status types
    func getStatusTypes() {
        GetIssueStatusTypesAPIManager.getIssueStatusTypes(userName: JiraAccountDetails.sharedInstance.username, password: JiraAccountDetails.sharedInstance.password) { (details, error) in
            debugPrint("details: \(details)")
            if let data = details {
                self.issueStatusTypes = data
            }
        }
    }
    // MARK: Refresh table method
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        isRefreshing = true
        self.startIndex = 0
        getAllIssues(withStartIndex:self.startIndex)
        self.issuesTableView?.reloadData()
        refreshControl.endRefreshing()
    }
    // MARK: Method to navigate to issue detail
    func showIssueDetails(indexPath: IndexPath) {

        var issueDetailResponse: IssueDetailsResponse = IssueDetailsResponse()
        if searchActive == true {
            issueDetailResponse = filteredIssueDetailArray[indexPath.row]

        } else {
            issueDetailResponse = issueDetailArray[indexPath.row]
        }

        if let key = issueDetailResponse.key{
            IssueDetailsApiManager.getIssueDetails(issueId: key, userName: JiraAccountDetails.sharedInstance.username, password: JiraAccountDetails.sharedInstance.password) { (details, error) in
                if let error = error {
                    debugPrint("Error: \(error)")
                } else {
                    // fetch userList
                    GetAllUsersAPIManager.getAllUsers(userName: JiraAccountDetails.sharedInstance.username, password: JiraAccountDetails.sharedInstance.password) { (users, error) in
                        if let err = error {
                            debugPrint("error: \(err)")
                        } else {
                            // show issue detaisl
                            let issueDetail: IssueDetailViewController = Util.getStoryboard(Constants.Storyboards.jira).instantiateViewController(withIdentifier: Constants.StorybordIDs.JiraIssueDetails) as? IssueDetailViewController ?? IssueDetailViewController()
                            issueDetail.issueDetail = details
                            issueDetail.userList = users
                            issueDetail.issueAssignee = details?.fields?.assignee
                            issueDetail.issueStatusTypes = self.issueStatusTypes
                            self.navigationController?.pushViewController(issueDetail, animated: true)
                        }
                    }
                }
            }
        }
    }
    func createNewIssue() {
        let createIssueView: CreateIssueViewController = Util.getStoryboard(Constants.Storyboards.jira).instantiateViewController(withIdentifier: Constants.StorybordIDs.JiraCreateIssue) as? CreateIssueViewController ?? CreateIssueViewController()
        createIssueView.issueTypeBugId = self.issueTypeBugId
        self.navigationController?.pushViewController(createIssueView, animated: true)
    }
}

extension IssuesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filteredIssueDetailArray.count
        }
        return issueDetailArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: IssueListCell! = tableView.dequeueReusableCell(withIdentifier: IssueListConstants.issueListCellIdentifier) as? IssueListCell
        if cell == nil {
            let arr = Bundle.main.loadNibNamed(Constants.XIBNames.issueListCell, owner: nil
                , options: nil)
            cell = arr?[0] as? IssueListCell
        }
        if issueDetailArray.isEmpty == false {
            if(searchActive){
                let issueDetailResponse: IssueDetailsResponse = filteredIssueDetailArray[indexPath.row]
                cell.issueTitle.text = issueDetailResponse.fields?.summary
                cell.issueDescription.text = issueDetailResponse.key
            } else {
                let issueDetailResponse: IssueDetailsResponse = issueDetailArray[indexPath.row]
                cell.issueTitle.text = issueDetailResponse.fields?.summary
                cell.issueDescription.text = issueDetailResponse.key
            }
        }
        return cell
    }
}

extension IssuesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return IssueListConstants.issueListCellHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showIssueDetails(indexPath: indexPath)
    }
}

extension IssuesListViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !searchActive {
            if scrollView == self.issuesTableView {
                if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
                    if self.total! > issueDetailArray.count {
                        let loadingView = UINib(nibName: Constants.XIBNames.loadingView, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
                        self.issuesTableView?.tableFooterView = loadingView

                        self.startIndex += issueDetailArray.count
                        getAllIssues(withStartIndex:self.startIndex)
                    }
                }
            }
        }
    }
}

extension IssuesListViewController: UISearchBarDelegate {
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let predicate:NSPredicate = NSPredicate(format:IssueListConstants.issueSearchPredicate, searchText)
        let subPredicate = [predicate]
        let finalPredicate = NSCompoundPredicate.init(orPredicateWithSubpredicates: subPredicate)

        filteredIssueDetailArray = (issueDetailArray as NSArray).filtered(using: finalPredicate) as! [IssueDetailsResponse]
        self.issuesTableView?.reloadData()
    }
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = true
        if filteredIssueDetailArray.isEmpty {
            getIssueDetail(issueKey: searchBar.text!)
        }
    }
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        self.issuesTableView?.reloadData()
        customizeNavigationBar()
    }
}
