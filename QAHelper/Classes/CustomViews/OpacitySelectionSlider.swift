//
//  ImageProcessControlsView.swift
//  QAHelper
//
//  Created by Sarath Vijay on 18/11/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit

fileprivate enum OpacitySelectionSliderConstant {
    static let sliderMinValue: Float = 0
    static let sliderMaxValue: Float  = 1
    static let sliderInitialValue :Float = 0.5
    static let padding: CGFloat = 15.0
    static let uploadButtonWidth: CGFloat = 40.0
}

typealias SliderValueChangeBlock = (_ value : CGFloat) -> Void
typealias UploadButtonTapped = ()-> Void

class OpacitySelectionSlider: UIView {

    fileprivate var slider: UISlider!
    fileprivate var timer: Timer?

    public var sliderValueChangeBlock :SliderValueChangeBlock?
    public var uploadButtonTapBlock: UploadButtonTapped?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeViewElements()
        initialiseTimer()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func handleCommentViewPanGesture(panGesture: UIPanGestureRecognizer) {
        initialiseTimer()
        switch panGesture.state {
        case .changed:
            let point = panGesture.location(in: self.superview)
            self.center.y = point.y
        default: break
        }
    }

    internal func sliderValueChanged(slider : UISlider) {
        initialiseTimer()
        self.sliderValueChangeBlock?(CGFloat(slider.value))
    }
    
    internal func uploadButtonTapped() {
        self.uploadButtonTapBlock?()
    }

    internal func switchSliderVisibility(visible : Bool) {
        isHidden = !visible
        if !isHidden {
            initialiseTimer()
        }
    }

    func displaySliderForCompare() {
        switchSliderVisibility(visible: true)
        slider.value = OpacitySelectionSliderConstant.sliderInitialValue
    }
}

fileprivate extension OpacitySelectionSlider {

    func initializeViewElements() {

        backgroundColor = UIColor.black
        alpha = 0.8
        layer.cornerRadius = 5
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleCommentViewPanGesture))
        addGestureRecognizer(panGesture)

        slider = UISlider(frame: CGRect(x: OpacitySelectionSliderConstant.padding, y: 0, width: bounds.width - ((2 * OpacitySelectionSliderConstant.padding) + OpacitySelectionSliderConstant.uploadButtonWidth), height: bounds.height))
        slider.minimumValue = OpacitySelectionSliderConstant.sliderMinValue
        slider.maximumValue = OpacitySelectionSliderConstant.sliderMaxValue
        slider.value = OpacitySelectionSliderConstant.sliderInitialValue
        slider.addTarget(self, action: #selector(sliderValueChanged), for: UIControlEvents.valueChanged)
        slider.tintColor = UIColor.white
        addSubview(slider)
        let uploadButton = UIButton(frame: CGRect(x: OpacitySelectionSliderConstant.padding + slider.frame.width, y: 0, width: OpacitySelectionSliderConstant.uploadButtonWidth, height: bounds.height))
        uploadButton.setImage(UIImage(named: "UploadButton"), for: .normal)
        uploadButton.addTarget(self, action: #selector(uploadButtonTapped), for: .touchUpInside)
        addSubview(uploadButton)
    }

    func initialiseTimer() {

        if let timer = timer , timer.isValid {
            timer.invalidate()
        }
        timer = nil

        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { timer in
            self.isHidden = true
        })
    }
}
