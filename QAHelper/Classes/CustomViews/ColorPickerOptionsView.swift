//
//  ColorPickerView.swift
//  QAHelper
//
//  Created by Sarath Vijay on 09/12/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit

typealias TextColorSelectionChanged = (_ color : UIColor)-> Void
typealias PencilColorSelectionChanged = (_ color: UIColor)-> Void

fileprivate enum ColorPickerViewConstant {
    static let colorPickerViewHeight: CGFloat = 250.0
    static let colorPickerOptionsViewHeight: CGFloat = 150.0
    static let animationDuration = 0.7
    static let viewPadding : CGFloat = 30.0
    static let labelWidth: CGFloat = 100.0
    static let sliderHeight: CGFloat = 31.0
    static let colorDisplayViewWidth: CGFloat = 75.0
    static let colorDisplayViewOriginY: CGFloat = 160
}

class ColorPickerOptionsView: UIView {
    
    public var textColorSelectionChanged: TextColorSelectionChanged?
    public var pencilColorSelectionChanged: PencilColorSelectionChanged?
    fileprivate var displayView: UIView!
    
    class func addColorPickerView(parantViewController: UIViewController, textColorChangeBlock: TextColorSelectionChanged?, pencilColorChangeBlock : PencilColorSelectionChanged?) -> ColorPickerOptionsView {
        let colorPickerView = ColorPickerOptionsView(frame: CGRect(x: 0, y: -ColorPickerViewConstant.colorPickerViewHeight , width: parantViewController.view.frame.width, height: ColorPickerViewConstant.colorPickerViewHeight))
        colorPickerView.textColorSelectionChanged = textColorChangeBlock
        colorPickerView.pencilColorSelectionChanged = pencilColorChangeBlock
        parantViewController.view.addSubview(colorPickerView)
        return colorPickerView
    }
    
    public func show() {
        var origin = self.frame.origin
        origin.y = 0
        UIView.animate(withDuration: ColorPickerViewConstant.animationDuration) {
            self.frame.origin = origin
        }
    }
    
    public func dismiss() {
        var origin = self.frame.origin
        origin.y = -ColorPickerViewConstant.colorPickerViewHeight
        UIView.animate(withDuration: ColorPickerViewConstant.animationDuration) {
            self.frame.origin = origin
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension ColorPickerOptionsView {
    
    func initializeView() {
        backgroundColor = UIColor.clear
        
        let optionsView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: ColorPickerViewConstant.colorPickerOptionsViewHeight))
        optionsView.backgroundColor = UIColor.black
        addSubview(optionsView)

        
        let textColorLabel = UILabel(frame: CGRect(x: ColorPickerViewConstant.viewPadding, y: ColorPickerViewConstant.viewPadding, width: ColorPickerViewConstant.labelWidth, height: ColorPickerViewConstant.sliderHeight))
        textColorLabel.text = "Text Color"
        textColorLabel.textColor = UIColor.white
        optionsView.addSubview(textColorLabel)
        
        let textColorSliderFrame = CGRect(x: (ColorPickerViewConstant.viewPadding + ColorPickerViewConstant.labelWidth), y: ColorPickerViewConstant.viewPadding, width: (self.frame.width - (2 * ColorPickerViewConstant.viewPadding + ColorPickerViewConstant.labelWidth)), height: ColorPickerViewConstant.sliderHeight)
        let textColorPicker = ColorPickerView(frame: textColorSliderFrame)
        textColorPicker.didChangeColor = { color in
            self.displayView.isHidden = false
            self.displayView.backgroundColor = color
            self.textColorSelectionChanged?(color!)
        }
        optionsView.addSubview(textColorPicker)
        
        
        let pencilColorLabel = UILabel(frame: CGRect(x: ColorPickerViewConstant.viewPadding, y: (ColorPickerViewConstant.viewPadding * 2) + ColorPickerViewConstant.sliderHeight, width: ColorPickerViewConstant.labelWidth, height: ColorPickerViewConstant.sliderHeight))
        pencilColorLabel.text = "Pencil Color"
        pencilColorLabel.textColor = UIColor.white
        optionsView.addSubview(pencilColorLabel)
        
        let pencilColorSliderFrame = CGRect(x: (ColorPickerViewConstant.viewPadding + ColorPickerViewConstant.labelWidth), y: (ColorPickerViewConstant.viewPadding * 2) + ColorPickerViewConstant.sliderHeight, width: (self.frame.width - (2 * ColorPickerViewConstant.viewPadding + ColorPickerViewConstant.labelWidth)), height: ColorPickerViewConstant.sliderHeight)
        let pencilColorPicker = ColorPickerView(frame: pencilColorSliderFrame)
        pencilColorPicker.didChangeColor = { color in
            self.displayView.isHidden = false
            self.displayView.backgroundColor = color
            self.pencilColorSelectionChanged?(color!)
        }
        optionsView.addSubview(pencilColorPicker)
        
        
        displayView = UIView(frame: CGRect(x: (self.frame.size.width - ColorPickerViewConstant.colorDisplayViewWidth) * 0.5, y: ColorPickerViewConstant.colorDisplayViewOriginY, width: ColorPickerViewConstant.colorDisplayViewWidth, height: ColorPickerViewConstant.colorDisplayViewWidth))
        displayView.layer.cornerRadius = ColorPickerViewConstant.colorDisplayViewWidth * 0.5
        displayView.layer.borderColor = UIColor.white.cgColor
        displayView.layer.borderWidth = 5
        displayView.isHidden = true
        addSubview(displayView)
    }
}
