//
//  QAHelperController.swift
//  QAHelper
//
//  Created by Sarath Vijay on 15/11/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit

public enum TriggerMode {
    case DeviceShake, TakeScreenshot
}

public enum HelperControllerConstnt {
    static let deviceShakeNotificationName = "QAHelperDeviceShakeNotification"
}

class QAHelperController: NSObject {
    
    public var isActive: Bool {
        get {
            return UIViewController.frontViewController()?.navigationController is QAHelperNavigationController
        }
    }

    //MARK:- Variables
    fileprivate var currentTrigger = TriggerMode.DeviceShake

    //MARK:- Initialisation
    public init(triggerMode: TriggerMode) {
        super.init()
        currentTrigger = triggerMode
        addListenerForTriggerMode()
        CrashController.activate()
    }
}

fileprivate extension QAHelperController {

    fileprivate func addListenerForTriggerMode() {
        switch currentTrigger {
        case .DeviceShake: addDeviceShakeNotificationObserver()
        case .TakeScreenshot: addScreenShotCaptureNotificationObserver()
        }
    }

    fileprivate func addScreenShotCaptureNotificationObserver() {
        let mainQueue = OperationQueue.main
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationUserDidTakeScreenshot,
                                               object: nil,
                                               queue: mainQueue) { notification in
                                                self.showLandingConfirmationAlert()
        }
    }

    fileprivate func addDeviceShakeNotificationObserver() {
        let mainQueue = OperationQueue.main
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: HelperControllerConstnt.deviceShakeNotificationName),
                                               object: nil,
                                               queue: mainQueue) { notification in
                                                self.showLandingConfirmationAlert()
        }
    }

    fileprivate func showLandingConfirmationAlert() {
        if !isActive {
            let alertController = UIAlertController(title: "QAHelper",
                                                    message: "Are you sure you want to mark an issue?",
                                                    preferredStyle: .alert)
        
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                let storyBoard = UIStoryboard(name: "QAHelper", bundle: nil)
                let landingNav = storyBoard.instantiateInitialViewController()
                let navOld: UINavigationController = (landingNav as? UINavigationController)!
                let imageProcessingVC : ImageProcessingContainer = navOld.topViewController as! ImageProcessingContainer
                let nav: QAHelperNavigationController = QAHelperNavigationController(rootViewController: imageProcessingVC)
                imageProcessingVC.screenShot = UIViewController.frontViewController()?.view.snapshot()
                UIViewController.frontViewController()?.present(nav, animated: true, completion: nil)
                Util.deleteSavedImageDirectory()
            })
            
            let noAction = UIAlertAction(title: "No", style: .default, handler: { (action) in
            })
            
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            UIViewController.frontViewController()?.present(alertController,
                                                            animated: true,
                                                            completion: nil)
        }
    }
}

extension UIViewController {
    override open func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: HelperControllerConstnt.deviceShakeNotificationName), object: nil)
        }
    }

    //TODO : Check method properly
    public class func frontViewController() -> UIViewController? {
        var viewController = UIApplication.shared.windows.first?.rootViewController
        while let vc = viewController?.presentedViewController {
            if vc is UINavigationController == false {
                viewController = vc
                break
            } else {
                let nav : UINavigationController = (vc as? UINavigationController)!
                viewController = nav.topViewController
                break
            }
        }
        return viewController
    }
}

extension UIView {
    //TODO : Check method properly
    func snapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false,  UIScreen.main.scale)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
