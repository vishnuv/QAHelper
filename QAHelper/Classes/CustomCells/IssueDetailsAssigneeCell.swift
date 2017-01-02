//
//  IssueDetailsAssigneeCell.swift
//  QAHelper
//
//  Created by Sarath Vijay on 01/12/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import AlamofireImage

class IssueDetailsAssigneeCell: UITableViewCell {

    @IBOutlet weak var assigneeTitle: UILabel!
    @IBOutlet weak var assigneeValueLabel: UILabel!
    @IBOutlet weak var assigneeImageView: UIImageView!

    fileprivate var userDetails: User?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

fileprivate extension IssueDetailsAssigneeCell { 
    func setupUI() {
        assigneeTitle.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
        assigneeTitle.textColor = Util.Color.colorRGB(red: 163, green: 168, blue: 173, withAplha: 1)
        assigneeTitle.textAlignment = .left

        assigneeTitle.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
        assigneeValueLabel.textColor = UIColor.black
        assigneeValueLabel.textAlignment = .left

        func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
            URLSession.shared.dataTask(with: url) {
                (data, response, error) in
                completion(data, response, error)
                }.resume()
        }


        //TODO: - TEST_MODE Update with original image [.svg file]
        if let details = userDetails {
            let url = details.avatarUrls?.icon48
            let urll = URL(string: url!)
//            assigneeImageView.af_setImage(withURL: urll!)
//            assigneeImageView.backgroundColor = Util.Color.randomColor()
            getDataFromUrl(url: urll!, completion: { (data, resp, error) in
                if let dt = data{
                    debugPrint("data: \(dt)")
                    self.assigneeImageView.backgroundColor = Util.Color.randomColor()
                }
            })
        }
        //TODO: - TEST_MODE Update with original image [.svg file]
    }
}

extension IssueDetailsAssigneeCell {
    func loadData(user: User?) {
        userDetails = user
        if let details = userDetails {
            assigneeValueLabel.text = details.displayName
        }
        setupUI()
    }
}
