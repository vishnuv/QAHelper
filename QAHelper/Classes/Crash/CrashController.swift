//
//  CrashController.swift
//  QAHelper
//
//  Created by Denow on 20/Dec/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import MessageUI

enum Crash {
    static let reason = "reason"
    static let logs = "logs"
    static let date = "date"
    static let directoryName = "CrashReports"
    static let fileName = "crashReport"

    static let alertTitle = "Crash"
    static let alertMessage = "The App has recently reported a crash. Do you want to share the crash details?"
}

let appDelegate = UIApplication.shared.delegate as! AppDelegate

class CrashController: NSObject {

    public static let sharedInstance = CrashController()

    override init() {
        debugPrint("Allocated")
    }

    deinit {
        debugPrint("Released")
    }

    //MARK: - Class functions
    static func activate() {
        NSSetUncaughtExceptionHandler { (exception) in
            debugPrint("exception: \(exception)")
            debugPrint("exception reason: \(exception.reason)")
            debugPrint("exception.callStackSymbols: \(exception.callStackSymbols)")
            let array = exception.callStackSymbols
            for str in array {
                print(str, #function, #line)
            }
            CrashController.saveCrashReport(exception)
        }
        CrashController.showCrashRelatedAlert()
    }

    static func crashFunction () {
        var i = 1
        while i>0 {
            print("i: \(i)")
            if i==500 {
                let a: NSArray = ["a"]
                print(a.object(at: 100))
            }
            i += 1
        }
    }

    static func getAllCrashReports() -> [String]? {
        let mgr = FileManager.default

        var reports: [String] = []
        if let dir = CrashController.savingDirectoryForCrashReport() {
            do {
                let files = try mgr.contentsOfDirectory(atPath: dir)
                for item in files {
                    let fileItem = item as NSString
                    let last = fileItem.lastPathComponent
                    if last.contains(Crash.fileName){
                        let actualPath = dir + "/" + item
                        reports.append(actualPath)
                    }
                }

                return reports
            } catch {
                print("Error: \(error)")
            }
        }

        return nil
    }

    static func saveCrashReport(_ exception: NSException) {
        let date = Date()
        print("date: \(date)")

        let obCrash: CrashReport = CrashReport()
        if let reason = exception.reason {
            obCrash.reason = reason
        }
        obCrash.logs = exception.callStackSymbols
        obCrash.date = date

        let reason = obCrash.reason
        let logs = obCrash.logs

        var logString = "Crash Report"
        logString += "\n\n"
        logString += "Date:- \n"
        logString += String(describing: date)
        logString += "\n\n"
        logString += "Reason:- \n"
        logString += reason
        logString += "\n\n"
        logString += "Logs:- \n"
        logString += (logs as! [String]).joined(separator: "\n")
        logString += "\n\n"

        if let data = logString.data(using: .utf8) {
            let savingPath = savingPathForNewCrashReport()

            let url = URL(fileURLWithPath: savingPath)
            do {
                try data.write(to: url)
            } catch {
                print(error)
            }
        }
    }

    static func savingPathForNewCrashReport() -> String {
        if let dir =  savingDirectoryForCrashReport() {
            let fileMgr = FileManager.default
            do {
                try fileMgr.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }

            var path = dir + "/" + Crash.fileName

            let filesCount = CrashController.getAllCrashReports()?.count
            if let filesCount = filesCount {
                path = path + String(filesCount) // updating file name with count
            }
            path = path + ".txt"

            return path
        }
        return ""
    }

    static func savingDirectoryForCrashReport() -> String? {
        if let docDir =  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let dir = docDir + "/" + Crash.directoryName
            return dir
        }
        return nil
    }

    static func showCrashRelatedAlert() {
        if let files = CrashController.getAllCrashReports() {
            if files.count>0 {
                let alertContr = UIAlertController(title: Crash.alertTitle, message: Crash.alertMessage, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Yes", style: .default, handler: { (alert) in
                    if MFMailComposeViewController.canSendMail() {
                        let mail = MFMailComposeViewController()
                        mail.mailComposeDelegate = CrashController.sharedInstance
                        mail.setSubject(Crash.alertTitle)

                        for (index, item) in files.enumerated() {
                            let url = URL(fileURLWithPath: item)
                            do {
                                let data = try Data.init(contentsOf: url)
                                let fileName = "crash" + String(index) + ".txt"
                                mail.addAttachmentData(data, mimeType: "txt", fileName: fileName)
                            } catch {
                                print("Error: \(error)")
                            }
                        }
                        DispatchQueue.main.async {
                            appDelegate.window?.rootViewController?.present(mail, animated: true, completion: {

                            })
                        }
                    } else {
                        debugPrint("Mail composer error")
                    }
                })
                alertContr.addAction(okAction)

                let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: { (alert) in
                    if let dirPath = self.savingDirectoryForCrashReport() {
                        let mgr = FileManager.default
                        do {
                            try mgr.removeItem(atPath: dirPath)
                        } catch {
                            print("Error: \(error)")
                        }
                    }
                })
                alertContr.addAction(cancelAction)

                DispatchQueue.main.async {
                    appDelegate.window?.rootViewController?.present(alertContr, animated: true, completion: nil)
                }
            }
        } else {
            print("Crash report don't exists")
        }
    }
}


//MARK: - MailComposerDelegate
extension CrashController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
        if result == MFMailComposeResult.sent {
            if let dirPath = CrashController.savingDirectoryForCrashReport() {
                let mgr = FileManager.default
                do {
                    try mgr.removeItem(atPath: dirPath)
                } catch {
                    print("Error: \(error)")
                }
            }
        }
    }
}

class CrashReport: NSObject, NSCoding {
    var reason: String
    var logs: Any
    var date: Date

    override init() {
        self.reason = ""
        self.logs = ""
        self.date = Date()
    }

    required init?(coder aDecoder: NSCoder) {
        reason = aDecoder.decodeObject(forKey: "reason") as? String ?? ""
        logs = aDecoder.decodeObject(forKey: "logs") ?? ""
        date = aDecoder.decodeObject(forKey: "date") as! Date
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(reason, forKey: "reason")
        aCoder.encode(logs, forKey: "logs")
        aCoder.encode(date, forKey: "date")
    }
}
