//
//  Constants.swift
//  QAHelper
//
//  Created by Denow on 15/Nov/16.
//  Copyright © 2016 QBurst. All rights reserved.
//
import Foundation

struct Constants {

    struct Api {
        static let jiraUrl = "https://qahelper2.atlassian.net/rest/api/2/"
    }

    struct ApiNames {
        static let issue = "issue"
        static let comment = "comment"
        static let allIssues = "search?"
        static let attachments = "attachments"
        static let allUsers = "user/assignable/search?project="
        static let issueType = "issuetype"
        static let issueStatus = "status"
        static let project = "project"
        static let statusTypes = "statuses"
    }

    struct Storyboards {
        static let jira = "Jira"
        static let qahelper = "QAHelper"
    }

    struct StorybordIDs {
        static let JiraIssueDetails = "IssueDetailViewController"
        static let JiraCreateIssue = "CreateIssueViewController"
        static let JiraAssigneeList = "AssigneeListViewController"
    }

    struct XIBNames {
        static let issueListCell = "IssueListCell"
        static let loadingView = "LoadingView"
        static let miscCell = "MiscCell"
    }

    struct CellIdentifiers {
        static let CreateIssueSummaryDescriptionCell = "CreateIssueSummaryDescriptionCell"
        static let CreateIssueImagePreviewCell = "CreateIssueImagePreviewCell"
        static let AssigneeCell = "AssigneeCell"
    }

    struct AlertTitlesAndMessages {
        static let sorryTitle: String = "Sorry"
        static let errorTitle: String = "Error"
        static let successTitle: String = "Success"
        static let noResultFoundMessage: String = "No result found"
        static let summaryMissingMessage: String = "Summary is missing"
        static let descriptionMissingMessage: String = "Description is missing"
        static let assigneeMissingMessage: String = "Assignee is missing"
        static let issueCreatedSuccessMessage: String = "Issue created successfully"
    }

    struct Images {
        static let addNewIssueImage: String = "addNew"
        static let searchImage: String = "search"
        static let closeImage: String = "close"
        static let createImage: String = "create"
        static let backImage: String = "back"
        static let backWhiteImage: String = "backWhite"
    }

    struct NavigationBarTitles {
        static let myIssuesTitle: String = "My Issues"
        static let newIssueTitle: String = "New Issue"
    }
}
