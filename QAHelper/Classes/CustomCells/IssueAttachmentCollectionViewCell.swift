//
//  IssueAttachmentCollectionViewCell.swift
//  QAHelper
//
//  Created by Sarath Vijay on 05/12/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit

class IssueAttachmentCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var overlayView: UIImageView!
    
    var attachment :Attachment? {
        didSet {
            setThumbNail()
        }
    }
    
    var newAttachment : UIImage? {
        didSet {
            setNewAttachment()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 10
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 1
        overlayView.isHidden = true
    }
    
    func setThumbNail() {
        overlayView.isHidden = true
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        self.imageView.image = UIImage(named: "JiraAttachmentPlaceholder")
        if let url = attachment?.thumbnail {
            JiraImageDownloader.downloadImage(url: url) { (image, error) in
                if let img = image {
                    self.imageView.image = img
                }
            }
        }
    }
    
    func setNewAttachment() {
        imageView.layer.borderColor = UIColor.clear.cgColor
        if let previewImage = newAttachment {
            imageView.image = previewImage
            overlayView.isHidden = false
        }
    }
    
    @IBAction func attachmentIconTapped(_ sender: AnyObject) {
        
        if let attachment = attachment {
            let storyBoard = Util.getStoryboard(Constants.Storyboards.jira)
            let fullScreenView = storyBoard.instantiateViewController(withIdentifier: "FullScreenImageViewController") as! FullScreenImageViewController
            fullScreenView.imageUrl = attachment.content
            let navController = UINavigationController(rootViewController: fullScreenView)
            UIViewController.frontViewController()?.present(navController, animated: true, completion: nil)
        } else if let previewImage = newAttachment {
            let storyBoard = Util.getStoryboard(Constants.Storyboards.jira)
            let fullScreenView = storyBoard.instantiateViewController(withIdentifier: "FullScreenImageViewController") as! FullScreenImageViewController
            fullScreenView.previewImage = previewImage
            let navController = UINavigationController(rootViewController: fullScreenView)
            UIViewController.frontViewController()?.present(navController, animated: true, completion: nil)
        }
    }
}
