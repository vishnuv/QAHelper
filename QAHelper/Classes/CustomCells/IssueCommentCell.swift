//
//  IssueCommentCell.swift
//  QAHelper
//
//  Created by Denow on 06/Dec/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit

fileprivate struct CommentCellConstants {
    static let timeFormatApi = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
}

class IssueCommentCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var commentAuthor: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var comment: UILabel!

    fileprivate var commentDetails: Comment?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

fileprivate extension IssueCommentCell {
    func setupUI() {
        commentAuthor.textColor = UIColor.black
        commentAuthor.textAlignment = .left
        timeLabel.textColor = Util.Color.colorRGB(red: 163, green: 168, blue: 173, withAplha: 1)
        timeLabel.textAlignment = .left
        comment.textColor = UIColor.black
    }

    func updateCommentBodyWithTagsAndWithoutAttachments(body: String, userList: [User]?) {
        var trimmedArr: [String] = []
        let arr = body.components(separatedBy: "!")
        let query = body
        let regex = try! NSRegularExpression(pattern:"!(.*?)!", options: [])
        let tmp = query as NSString
        var results: [String] = []

        regex.enumerateMatches(in: query, options: [], range: NSMakeRange(0, query.characters.count)) { result, flags, stop in
            if let range = result?.rangeAt(1) {
                results.append(tmp.substring(with: range))
            }
        }
        for(_, item1) in arr.enumerated() {
            var exists = false
            for(_, item2) in results.enumerated() {
                if item1 == item2 {
                    exists = true
                    break
                }
            }
            if exists == false {
                trimmedArr.append(item1)
            }
        }
        let trimmedString = trimmedArr.joined(separator: "")
        var updatedBody = trimmedString.trimmingCharacters(in: .whitespacesAndNewlines)
        // Updating comment with tagged user's displayName *****
        if let users = userList {
            // "[~denow]" => "Denow Cleetus" // "name" => "displayName"
            for(_, item) in users.enumerated() {
                let str = "[~" + item.name! + "]"
                if updatedBody.contains(str) == true {
                    let newName = "@" + item.displayName!
                    updatedBody = updatedBody.replacingOccurrences(of: str, with: newName)
                }
            }
            comment.text = updatedBody

        } else {
            comment.text = updatedBody
        }
    }
}

extension IssueCommentCell {
    func loadData(details: Comment, usersList: [User]?) {
        commentDetails = details
        if let details = commentDetails {
            commentAuthor.text = details.author?.displayName
            if let time = details.updated {
                let formatter = DateFormatter()
                formatter.dateFormat = CommentCellConstants.timeFormatApi
                if let date = formatter.date(from: time) {
                    let strTime = Util.date.timeAgoSinceDate(dateParam: date, numericDates: true)
                    timeLabel.text = strTime
                }
            }
            comment.text = details.body
            if let body = details.body {
                updateCommentBodyWithTagsAndWithoutAttachments(body: body, userList: usersList)
            }
        }
        setupUI()
    }
}
