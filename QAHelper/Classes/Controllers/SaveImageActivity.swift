//
//  SaveImageActivity.swift
//  QAHelper
//
//  Created by Vishnu Vardhan PV on 01/11/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import Foundation

class SaveImageActivity: UIActivity {

    fileprivate var imageToSave : UIImage!

    override open var activityTitle: String? {
        return "Save To Album"
    }

    override open var activityImage: UIImage? {
        return nil
    }

    override open func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }

    init(image: UIImage!) {
        imageToSave = image
    }

    override open func perform() {
        if let image = imageToSave {
            let photoAlbum = PhotoAlbumHelper()
            photoAlbum.savePhotoToAlbum(image: image)
        }
    }
}
