//
//  ViewController.swift
//  QAHelper
//
//  Created by Sarath Vijay on 10/11/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showJiraIssues(_ sender: AnyObject) {
        let jiraSB: UIStoryboard = Util.getStoryboard(Constants.Storyboards.jira)
        let navJira = jiraSB.instantiateInitialViewController()
        if let nav = navJira {
            self.present(nav, animated: true, completion: nil)
        }
    }
}

extension ViewController {

    func getIssueStatusTypes() {
        GetIssueStatusTypesAPIManager.getIssueStatusTypes(userName: JiraAccountDetails.sharedInstance.username, password: JiraAccountDetails.sharedInstance.password) { (details, error) in
            debugPrint("details: \(details)")

            if let data = details {
                let predicate:NSPredicate = NSPredicate(format:"statusId == \"10001\"")
                let subPredicate = [predicate]
                let finalPredicate = NSCompoundPredicate.init(orPredicateWithSubpredicates: subPredicate)

                let filteredArray = (data as NSArray).filtered(using: finalPredicate) as! [IssueStatus]
                print(filteredArray)
                var issue = filteredArray[0] as IssueStatus
                print(issue.name)
                print(issue.statusId)
            }
        }
    }

    func getIssueDetails() {
        IssueDetailsApiManager.getIssueDetails(issueId: "QAH1-2", userName: JiraAccountDetails.sharedInstance.username, password: JiraAccountDetails.sharedInstance.password) { (details, error) in
            debugPrint("details: \(details)")
            debugPrint("error: \(error)")
            debugPrint("detailsComment: \(details?.fields?.issueComment?.comments?[1].body)")
        }
    }

    func createIssue() {
        CreateIssueAPIManager.createIssue(userName: JiraAccountDetails.sharedInstance.username, password: JiraAccountDetails.sharedInstance.password, issueTypeId: "", summary: "1 Test summary 1", description: "1 Test description 1", assigneeName: "admin") { (details, error) in
            debugPrint("details: \(details)")
            debugPrint("error: \(error)")
        }
    }

    func getIssueTypes() {
        GetIssueTypesAPIManager.getIssueTypes(userName: JiraAccountDetails.sharedInstance.username, password: JiraAccountDetails.sharedInstance.password) { (details, error) in
            debugPrint("details: \(details)")

            if let data = details {
                let predicate:NSPredicate = NSPredicate(format:"issueName == \"Bug\"")
                let subPredicate = [predicate]
                let finalPredicate = NSCompoundPredicate.init(orPredicateWithSubpredicates: subPredicate)

                let filteredArray = (data as NSArray).filtered(using: finalPredicate) as! [IssueType]
                print(filteredArray)
                var issue = filteredArray[0] as IssueType
                print(issue.issueName)
                print(issue.issueid)
            }

            debugPrint("error: \(error)")
        }
    }

    func addCommentToIssue() {
        AddCommentApiManager.addComment(comment: "Test Comment chumma", ToIssue: "QAH1-1", userName: JiraAccountDetails.sharedInstance.username, password: JiraAccountDetails.sharedInstance.password) { (comment, error) in
            debugPrint("comment: \(comment)")
            debugPrint("comment: \(comment?.body)")
        }
    }

    func addAttachmentAndCommentToIssue() {
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        debugPrint("docDir: \(docDir)")

        //TODO: - TEST_MODE
        let path = docDir! + "/sambu.png" // 'sambu.png' will be the name for image there, so the name should be 'screenshot-2016-11-23 18:14:52.png'[sample name] while saving in our directory
        let fileUrl = URL.init(fileURLWithPath: path)
        //TODO: - TEST_MODE

        AddAttachmentApiManger.addAttachment(fileUrl, issueId: "QAH1-5", userName: JiraAccountDetails.sharedInstance.username, password: JiraAccountDetails.sharedInstance.password) { (response, error) in
            if let error = error {
                debugPrint("Error: \(error)")
            } else {
                debugPrint("Attachment and comment succesfully added")
            }
        }
    }

    func updateAssignee(){

        //TODO: - TEST_MODE
        //note: "newAssigneeName" is not "email" or "displayName", its "name"
        //TODO: - TEST_MODE

        EditIssueApiManager.updateAssignee(newAssigneeName: "sarath", ToIssue: "QAH1-1", userName: JiraAccountDetails.sharedInstance.username, password: JiraAccountDetails.sharedInstance.password) { (editResp, error) in
            if let error = error {
                debugPrint("error: \(error)")
            } else {
                debugPrint("response: \(editResp?.isSuccess)")
            }
        }
    }

    func getStatusTypes() {
        GetStatusTypesApiManager.getStatusTypesForProject(projectId: "10000", userName: JiraAccountDetails.sharedInstance.username, password: JiraAccountDetails.sharedInstance.password) { (resp, error) in
            if let err = error {
                debugPrint("err: \(err)");
            } else {
                debugPrint("resp: \(resp)");
            }
        }
    }
}

