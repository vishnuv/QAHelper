//
//  FullScreenImageViewController.swift
//  QAHelper
//
//  Created by Sarath Vijay on 06/12/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import KRProgressHUD

class FullScreenImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var imageUrl : String?
    var previewImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
//        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.hidesBarsOnTap = true
        self.navigationController?.hidesBarsOnSwipe = true
        addCloseButton()
        loadFullScreenImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func dismissFullScreenView() {
        self.dismiss(animated: true, completion: nil)
    }
}


fileprivate extension FullScreenImageViewController {
    
    func loadFullScreenImage() {
        if let previewImg = previewImage {
            self.imageView.image = previewImg
        } else {
            KRProgressHUD.set(style:.black)
            KRProgressHUD.show()
            JiraImageDownloader.downloadImage(url: imageUrl!) { (image, error) in
                if let img = image {
                    self.imageView.image = img
                    KRProgressHUD.dismiss()
                }
            }
        }
    }
    
    func addCloseButton() {
        let leftBtn = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(dismissFullScreenView))
        navigationItem.leftBarButtonItem = leftBtn
    }
}
