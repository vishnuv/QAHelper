//
//  IssueDetilsAttachmentsCell.swift
//  QAHelper
//
//  Created by Sarath Vijay on 01/12/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit

class IssueDetilsAttachmentsCell: UITableViewCell {
    
    var attachments : [Attachment]! {
        didSet {
            print("-------------------------------------------------")
            collectionView.reloadData()
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    var shouldShowNewAttachment: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension IssueDetilsAttachmentsCell : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var numberOfItems = 0
        if let attachment = attachments , attachments.count > 0 {
            numberOfItems = attachment.count
        }
        if shouldShowNewAttachment {
            numberOfItems = numberOfItems + 1
        }
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if shouldShowNewAttachment == true, indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IssueAttachmentCollectionViewCell", for: indexPath) as! IssueAttachmentCollectionViewCell
            cell.newAttachment = Util.getSavedImage()
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IssueAttachmentCollectionViewCell", for: indexPath) as! IssueAttachmentCollectionViewCell
        var index = indexPath.row
        if shouldShowNewAttachment {
            index = index - 1
        }
        cell.attachment = attachments[index]
        return cell
    }
}

