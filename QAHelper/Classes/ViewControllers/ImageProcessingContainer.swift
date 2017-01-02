//
//  ImageProcessingContainer.swift
//  QAHelper
//
//  Created by Sarath Vijay on 18/11/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import SnapKit
import LiquidFloatingActionButton

public enum QAHelperMenuOptions : Int {
    case QuitApp, QAHelperDraw , QAHelperComment, QAHelperCompare, QAHelperColor, QAHelperShare, QAHelperJira
}

class ImageProcessingContainer: BaseViewController {

    //MARK:- Variables
    internal var screenShot: UIImage?
    
    //MARK:- IBOutlets
    @IBOutlet weak var referenceImageView: UIImageView!
    @IBOutlet weak var annotationViewContainer: UIView!
    @IBOutlet weak var screenShotImageView: UIImageView!
    
    //MARK:- Private Variables
    fileprivate var adapter : AnnotationViewAdapter!
    fileprivate var cells: [LiquidFloatingCell] = []
    fileprivate var floatingActionButton: CustomDrawingActionButton!
    fileprivate var opacitySlider: OpacitySelectionSlider!
    fileprivate var colorSelectionView: ColorPickerOptionsView!
    
    fileprivate var helperMode: QAHelperMenuOptions = .QAHelperDraw {
        didSet {
            if !floatingActionButton.isClosed {
                floatingActionButton.close()
            }
        }
    }
    
    //MARK:- Override methods implementation
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUISetUp()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch helperMode {
        case .QAHelperCompare: opacitySlider.switchSliderVisibility(visible: opacitySlider.isHidden)
        case .QAHelperColor, .QAHelperJira, .QAHelperShare :
            willSelectNewMenuOptions()
            helperMode = .QAHelperDraw
            adapter.switchToDrawingState()
            break
        default: break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
}

fileprivate extension ImageProcessingContainer {
    
    func initialUISetUp() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.isNavigationBarHidden = true
        screenShotImageView.image = screenShot
        addAnnotationView()
        addFloatingButton()
        addOpacitySelectionSlider()
        addColorPickerView()
    }
    
    func addAnnotationView() {
        adapter = AnnotationViewAdapter()
        adapter.addAnnotationView(toContainerView: annotationViewContainer, andParantController: self)
    }
    
    func showImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func addFloatingButton() {
        let createButton: (CGRect, LiquidFloatingActionButtonAnimateStyle) -> LiquidFloatingActionButton = { (frame, style) in
            let floatingActionButton = CustomDrawingActionButton(frame: frame)
            floatingActionButton.animateStyle = style
            floatingActionButton.dataSource = self
            floatingActionButton.delegate = self
            floatingActionButton.color = UIColor(red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 1.0)
            self.floatingActionButton = floatingActionButton
            return floatingActionButton
        }
        
        let cellFactory: (String) -> LiquidFloatingCell = { (iconName) in
            let cell = CustomCell(icon: UIImage(named: iconName)!, name: iconName)
            cell.selectedCellColor = UIColor(red: 232 / 255.0, green: 36 / 255.0, blue: 50 / 255.0, alpha: 1.0)
            return cell
        }
        
        cells.append(cellFactory("Quit App"))
        cells.append(cellFactory("Draw"))
        cells.append(cellFactory("Comment"))
        cells.append(cellFactory("Compare"))
        cells.append(cellFactory("Color"))
        cells.append(cellFactory("Share"))
        cells.append(cellFactory("Jira"))
        let floatingFrame = CGRect(x: self.view.frame.width - 56 - 16, y: self.view.frame.height - 56 - 16, width: 56, height: 56)
        let bottomRightButton = createButton(floatingFrame, .up)
        self.view.addSubview(bottomRightButton)
    }
    
    func addOpacitySelectionSlider() {
        opacitySlider = OpacitySelectionSlider(frame: CGRect(x: 0, y: (view.frame.height * 0.5), width: view.frame.width, height: 50))
        opacitySlider.sliderValueChangeBlock = { value in
            self.annotationViewContainer.alpha = value
        }
        opacitySlider.uploadButtonTapBlock = {
            self.showUploadImageAlert()
        }
        view.addSubview(opacitySlider)
        view.bringSubview(toFront: opacitySlider)
        opacitySlider.isHidden = true
    }
    
    func addColorPickerView() {
        colorSelectionView = ColorPickerOptionsView.addColorPickerView(parantViewController: self, textColorChangeBlock: textColorChanged, pencilColorChangeBlock: pencilColorChanged)
    }
    
    func pencilColorChanged(_ color : UIColor)-> Void {
        adapter.setPencilColor(color)
    }
    
    func textColorChanged(_ color : UIColor)-> Void {
        adapter.setTextColor(color)
    }
    
    func showOpacitySelectionSlider() {
        if let _ = referenceImageView.image {
            self.annotationViewContainer.alpha = 0.5
            opacitySlider.displaySliderForCompare()
        } else {
            showUploadImageAlert()
        }
    }
    
    func quitHelperApp() {
        Util.deleteSavedImageDirectory()
        self.dismiss(animated: true, completion: nil)
    }
    
    func showColorOptions() {
        colorSelectionView.show()
    }
    
    func showUploadImageAlert() {
        var message = "Please upload a reference image"
        if referenceImageView.image != nil {
            message = "Would you like to re upload a reference image"
        }
        let uploadAlert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            self.showImagePicker()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        uploadAlert.addAction(okAction)
        uploadAlert.addAction(cancelAction)
        present(uploadAlert, animated: true, completion: nil)
    }
    
    func shareCurrentAnnotation() {
        let finalImage = adapter.draw(on: screenShot)
        //TODO : Correct this code.
        let objectsToShare: [Any] = ["", finalImage]
        let save = SaveImageActivity(image: finalImage)
        let activityVC = UIActivityViewController.init(activityItems: objectsToShare, applicationActivities: [save])
        activityVC.popoverPresentationController?.sourceView = UIViewController.frontViewController()?.view
        let viewBounds = UIViewController.frontViewController()?.view.bounds
        activityVC.popoverPresentationController?.sourceRect = CGRect(x: (viewBounds?.midX)!, y: (viewBounds?.height)!, width: 0, height: 0)

        self.present(activityVC, animated: true, completion: nil)
    }
    
    func shareToJira() {
        let finalImage = adapter.draw(on: screenShot)
        if let image = finalImage {
            Util.saveImageToDocumentDirectory(image: image)
            let jiraStoryBoard = UIStoryboard(name: "Jira", bundle: nil)
            let jiraListing = jiraStoryBoard.instantiateViewController(withIdentifier: "IssuesListViewController")
            navigationController?.pushViewController(jiraListing, animated: true)
        }
    }
    
    func willSelectNewMenuOptions() {
        colorSelectionView.dismiss()
        adapter.enableAnnotationView(false)
        self.annotationViewContainer.alpha = 1
    }
}

extension ImageProcessingContainer: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            referenceImageView.contentMode = .scaleAspectFit
            referenceImageView.image = pickedImage
            helperMode = .QAHelperCompare
            showOpacitySelectionSlider()
        }
        dismiss(animated: true, completion: nil)
    }
    
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension ImageProcessingContainer : LiquidFloatingActionButtonDataSource, LiquidFloatingActionButtonDelegate   {
    func numberOfCells(_ liquidFloatingActionButton: LiquidFloatingActionButton) -> Int {
        return cells.count
    }
    
    func cellForIndex(_ index: Int) -> LiquidFloatingCell {
        let cell: CustomCell = cells[index] as! CustomCell
        cell.isLeft = self.floatingActionButton.isPositionLeft
        cell.setSelected(isSelected: isCellSelected(index: index))
        return cell
    }
    
    func liquidFloatingActionButton(_ liquidFloatingActionButton: LiquidFloatingActionButton, didSelectItemAtIndex index: Int) {
        helperMode = QAHelperMenuOptions(rawValue: index)!
        willSelectNewMenuOptions()
        switch helperMode {
        case .QuitApp : quitHelperApp()
        case .QAHelperDraw: adapter.switchToDrawingState()
        case .QAHelperComment: adapter.switchToTextEditingState()
        case .QAHelperCompare: showOpacitySelectionSlider()
        case .QAHelperColor: showColorOptions()
        case .QAHelperShare: shareCurrentAnnotation()
        case .QAHelperJira: shareToJira()
        }
        liquidFloatingActionButton.close()
    }
    
    func isCellSelected(index : Int) -> Bool {
        return index == helperMode.rawValue
    }
}

public class CustomDrawingActionButton: LiquidFloatingActionButton {
    
    var isPositionLeft: Bool = false
    
    /**
     For fixing the menu button final position in bottom left/rignt corner with animation.
     */
    override public func handleButtonDragCompletion(touch : UITouch) {
        let padding: CGFloat = 45
        let touchLocation = touch.location(in: self.superview)
        var centerLocation = self.center
        if touchLocation.x < ((self.superview?.frame.size.width)! * 0.5) {
            centerLocation.x = padding
            isPositionLeft = true
        } else {
            centerLocation.x =  ((self.superview?.frame.size.width)! - padding)
            isPositionLeft = false
        }
        UIView.animate(withDuration: 0.7) {
            self.center = centerLocation
        }
    }
}

public class CustomCell: LiquidFloatingCell {
    var name: String = "sample"
    var isLeft: Bool = false
    
    init(icon: UIImage, name: String) {
        self.name = name
        super.init(icon: icon)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setupView(_ view: UIView) {
        super.setupView(view)
        let label = UILabel()
        label.text = name
        label.textColor = UIColor.white
        label.font = UIFont(name: "Helvetica-Neue", size: 12)
        label.tag = 100
        label.textColor = UIColor.black
        label.backgroundColor = UIColor.white
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.textAlignment = .center
        addSubview(label)
        var cellCenter = self.center
        cellCenter.y = view.center.y
        label.snp.makeConstraints { make in
            make.left.equalTo(self).offset(-120)
            make.width.equalTo(100)
            make.height.equalTo(32)
            make.centerY.equalTo(self)
        }
    }
    
    open override var frame: CGRect {
        didSet {
            adjustConstraints()
        }
    }
    
    public func adjustConstraints() {
        let offset = isLeft ? 80 : -120
        let label = self.viewWithTag(100)
        label?.snp.updateConstraints({ make in
            make.left.equalTo(self).offset(offset)
        })
    }
}
