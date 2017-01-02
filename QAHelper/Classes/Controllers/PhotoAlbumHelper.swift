//
//  PhotoAlbumHelper.swift
//  QAHelper
//
//  Created by Sarath Vijay on 02/11/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import Photos

public enum PhotoAlbumHelperConstnt {
    static let albumName = "QAHelper"
}

class PhotoAlbumHelper {

    fileprivate var imageToSave : UIImage!
    fileprivate var eventAlbum: PHAssetCollection?

    public func savePhotoToAlbum(image: UIImage) {

        imageToSave = image

        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                if status == .authorized {
                    self.checkAndSaveImageToAlbum()
                } else {
                    PHPhotoLibrary.requestAuthorization(self.requestAuthorizationHandler)
                }
            })
        } else {
            self.checkAndSaveImageToAlbum()
        }
    }
}

fileprivate extension PhotoAlbumHelper {

    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            self.checkAndSaveImageToAlbum()
        } else {
            showAuthorizationDeniedAlert()
        }
    }

    func showAuthorizationDeniedAlert() {
        let alert = UIAlertController(title: "Not Authorized", message: "QAHelper is not authorized to access phots. Grant access from setting", preferredStyle: .alert)
        let settingsButtonAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            let settinsgURL: URL = URL(string: UIApplicationOpenSettingsURLString)!
            if UIApplication.shared.canOpenURL(settinsgURL) {
                UIApplication.shared.open(settinsgURL, options: [:], completionHandler: { (completed) in

                })
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in

        }
        alert.addAction(settingsButtonAction)
        alert.addAction(cancelAction)
        UIViewController.frontViewController()?.present(alert, animated: true, completion: nil)
    }

    func showErrorSavingPhotoAlert() {
        let alert = UIAlertController(title: "Error adding photo", message: nil, preferredStyle: .alert)
        let settingsButtonAction = UIAlertAction(title: "OK", style: .default) { (action) in
        }
        alert.addAction(settingsButtonAction)
        UIViewController.frontViewController()?.present(alert, animated: true, completion: nil)
    }

    func showSavingSuccessAlert() {
        let alert = UIAlertController(title: "Saved successfully", message: nil, preferredStyle: .alert)
        let settingsButtonAction = UIAlertAction(title: "OK", style: .default) { (action) in
        }
        alert.addAction(settingsButtonAction)
        UIViewController.frontViewController()?.present(alert, animated: true, completion: nil)
    }

    func checkAndSaveImageToAlbum() -> Void {
        if let collection = fetchAssetCollectionForAlbum() {
            savePhoto(collection: collection)
        } else {
            createAlbum()
        }
    }

    func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", PhotoAlbumHelperConstnt.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }

        func createAlbum() {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: PhotoAlbumHelperConstnt.albumName) }) { success, error in
                    if success {
                        let collection = self.fetchAssetCollectionForAlbum()
                        self.savePhoto(collection: collection!)
                    } else {
                        self.showErrorSavingPhotoAlert()
                    }
            }
        }

    func savePhoto(collection: PHAssetCollection) -> Void {

        self.eventAlbum = collection
        if let albumdex = self.eventAlbum {
            PHPhotoLibrary.shared().performChanges({
                let result = PHAssetChangeRequest.creationRequestForAsset(from: self.imageToSave)
                let assetPlaceholder = result.placeholderForCreatedAsset
                let albumChangeRequset = PHAssetCollectionChangeRequest(for: albumdex)
                let enumeration: NSArray = [assetPlaceholder!]
                albumChangeRequset!.addAssets(enumeration)

                }, completionHandler: { (succeeded, error) -> Void in
                    if succeeded {
                        self.showSavingSuccessAlert()
                    } else{
                        self.showErrorSavingPhotoAlert()
                    }
            })
        }
    }
}


