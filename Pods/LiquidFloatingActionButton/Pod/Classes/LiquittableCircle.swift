//
//  LiquittableCircle.swift
//  LiquidLoading
//
//  Created by Takuma Yoshida on 2015/08/17.
//  Copyright (c) 2015年 yoavlt. All rights reserved.
//

import Foundation
import UIKit


public struct LiquittableCircleConstant {
    static let selectedCellTag = 10001
    static let normalCellTag = 0
}

open class LiquittableCircle : UIView {
    
    public var selectedCellColor: UIColor?
    var points: [CGPoint] = []
    var radius: CGFloat {
        didSet {
            self.frame = CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
            setup()
        }
    }
    var color: UIColor = UIColor.red {
        didSet {
            setup()
        }
    }
    
    override open var center: CGPoint {
        didSet {
            self.frame = CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
            setup()
        }
    }

    let circleLayer = CAShapeLayer()
    init(center: CGPoint, radius: CGFloat, color: UIColor) {
        let frame = CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
        self.radius = radius
        self.color = color
        super.init(frame: frame)
        setup()
        self.layer.addSublayer(circleLayer)
        self.isOpaque = false
    }

    init() {
        self.radius = 0
        super.init(frame: CGRect.zero)
        setup()
        self.layer.addSublayer(circleLayer)
        self.isOpaque = false
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        self.frame = CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
        drawCircle()
    }

    func drawCircle() {
        let bezierPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: CGSize(width: radius * 2, height: radius * 2)))
        draw(bezierPath)
    }

    func draw(_ path: UIBezierPath) -> CAShapeLayer {
        circleLayer.lineWidth = 3.0
        //QAHElper
        if self.tag == LiquittableCircleConstant.selectedCellTag, let selectedColor = selectedCellColor {
            circleLayer.fillColor = selectedColor.cgColor
        } else {
            circleLayer.fillColor = self.color.cgColor
        }
        circleLayer.path = path.cgPath
        return circleLayer
    }
    
    func circlePoint(_ rad: CGFloat) -> CGPoint {
        return CGMath.circlePoint(center, radius: radius, rad: rad)
    }
    
    open override func draw(_ rect: CGRect) {
        drawCircle()
    }
    
    open func setSelected(isSelected: Bool) {
        if isSelected {
            self.tag = LiquittableCircleConstant.selectedCellTag
        } else {
            self.tag = LiquittableCircleConstant.normalCellTag
        }
    }
}
