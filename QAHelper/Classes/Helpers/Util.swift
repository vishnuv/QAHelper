//
//  Util.swift
//  QAHelper
//
//  Created by Denow on 28/Nov/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit

fileprivate struct UtilConstants {
    static let imageExtension = "png"
}

class Util {

    static func getStoryboard(_ storyboardName: String) -> UIStoryboard {
        return UIStoryboard(name: storyboardName, bundle: Bundle.main)
    }

    // To get the default blue color of application
    static func getApplicationBlueColor() -> UIColor {
        return UIColor(red: 0/255.0, green: 110/255.0, blue: 232/255.0, alpha: 1.0)
    }

    // Shows an alert with a title and message with an Ok button
    static func showAlertWithTitle(title:String, message:String, forViewController:UIViewController, okButtonAction:@escaping () -> ()) {
        let alert = UIAlertController(title:title, message:message, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction!) in
            okButtonAction()
        }
        alert.addAction(okAction)
        DispatchQueue.main.async {
            forViewController.present(alert, animated: true, completion: nil)
        }
    }

    // Customize navigation bar with title and buttons on passing button images and selectors as array.
    static func customizeNavigationBarWithTitle(title:String?, rightButtons:[String], rightButtonSelectors:[Selector], leftButtons:[String], leftButtonSelectors:[Selector], forViewController:UIViewController) {

        forViewController.navigationItem.rightBarButtonItem = nil
        forViewController.navigationItem.leftBarButtonItem = nil
        forViewController.navigationItem.titleView = nil
        forViewController.navigationItem.title = nil

        var rightBarButtons = [UIBarButtonItem]()
        for (button, selector) in zip(rightButtons, rightButtonSelectors) {
            var rightImage: UIImage = UIImage(named: button)!
            rightImage = rightImage.withRenderingMode(.alwaysOriginal)
            let rightButton = UIBarButtonItem(image: rightImage, style: .plain, target: forViewController, action: selector)
            rightBarButtons.append(rightButton)
        }

        var leftBarButtons = [UIBarButtonItem]()
        for (button, selector) in zip(leftButtons, leftButtonSelectors) {
            var leftImage: UIImage = UIImage(named: button)!
            leftImage = leftImage.withRenderingMode(.alwaysOriginal)
            let leftButton = UIBarButtonItem(image: leftImage, style: .plain, target: forViewController, action: selector)
            leftBarButtons.append(leftButton)
        }

        forViewController.navigationItem.setRightBarButtonItems(rightBarButtons, animated: true)
        forViewController.navigationItem.setLeftBarButtonItems(leftBarButtons, animated: true)
        forViewController.navigationItem.title = title
    }

    //MARK: - Color
    public struct Color {
        public static func colorRGB(red: CGFloat, green: CGFloat, blue: CGFloat, withAplha alpha: CGFloat) -> UIColor {
            return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
        }

        public static func randomColor() -> UIColor {
            let randomRed = CGFloat(drand48())
            let randomGreen = CGFloat(drand48())
            let randomBlue = CGFloat(drand48())
            return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        }
    }
    
    
    //MARK:- Read write image in documents directory.

    static func fileSavingDirectory() -> String{
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        let folder = paths + "/QAHelper"
        do {
            try! fileManager.createDirectory(atPath: folder, withIntermediateDirectories: true, attributes: nil)
        }
        return folder
    }

    static func saveImageToDocumentDirectory(image: UIImage) {
        Util.deleteSavedImageDirectory()
        let fileManager = FileManager.default
        let folder = Util.fileSavingDirectory()

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let time = formatter.string(from: Date())
        let filePath = folder + "/" + "screenshot-" + time + "." + UtilConstants.imageExtension

        do {
            let imageData = UIImageJPEGRepresentation(image, 1)
            fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil)
        }
    }

    static func getSavedImageFilePath() -> String? {
        let fileManager = FileManager.default
        let savingDir = Util.fileSavingDirectory()
        do {
            let arr = try! fileManager.contentsOfDirectory(atPath: savingDir)
            for(_, item) in arr.enumerated() {

                if (item as NSString).pathExtension == UtilConstants.imageExtension {
                    let filePath = savingDir + "/" + item
                    debugPrint("filePath: \(filePath)")
                    return filePath
                }
            }
        }
        return nil
    }
    
    static func getSavedImage() -> UIImage? {
        if let imagePath = Util.getSavedImageFilePath() {
            return UIImage(contentsOfFile: imagePath)
        }
        return nil
    }
    
    static func deleteSavedImageDirectory() {
        let fileManager = FileManager.default
        let dir = Util.fileSavingDirectory()
        if fileManager.fileExists(atPath: dir){
            try! fileManager.removeItem(atPath: dir)
        }
    }
}

extension Util {
    struct date {
        static func timeAgoSinceDate(dateParam: Date, numericDates:Bool) -> String {
            let date = dateParam as NSDate
            let calendar = NSCalendar.current
            let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
            let now = NSDate()
            let earliest = now.earlierDate(date as Date)
            let latest = (earliest == now as Date) ? date : now
            let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)

            if (components.year! >= 2) {
                return "\(components.year!) years ago"
            } else if (components.year! >= 1){
                if (numericDates){
                    return "1 year ago"
                } else {
                    return "Last year"
                }
            } else if (components.month! >= 2) {
                return "\(components.month!) months ago"
            } else if (components.month! >= 1){
                if (numericDates){
                    return "1 month ago"
                } else {
                    return "Last month"
                }
            } else if (components.weekOfYear! >= 2) {
                return "\(components.weekOfYear!) weeks ago"
            } else if (components.weekOfYear! >= 1){
                if (numericDates){
                    return "1 week ago"
                } else {
                    return "Last week"
                }
            } else if (components.day! >= 2) {
                return "\(components.day!) days ago"
            } else if (components.day! >= 1){
                if (numericDates){
                    return "1 day ago"
                } else {
                    return "Yesterday"
                }
            } else if (components.hour! >= 2) {
                return "\(components.hour!) hours ago"
            } else if (components.hour! >= 1){
                if (numericDates){
                    return "1 hour ago"
                } else {
                    return "An hour ago"
                }
            } else if (components.minute! >= 2) {
                return "\(components.minute!) minutes ago"
            } else if (components.minute! >= 1){
                if (numericDates){
                    return "1 minute ago"
                } else {
                    return "A minute ago"
                }
            } else if (components.second! >= 3) {
                return "\(components.second!) seconds ago"
            } else {
                return "Just now"
            }
        }
    }
}


class QAHelperNavigationController: UINavigationController {
    private var _orientations = UIInterfaceOrientationMask.portrait
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get { return self._orientations }
        set { self._orientations = newValue }
    }
}

