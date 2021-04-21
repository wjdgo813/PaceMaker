//
//  StrokeView.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/04/07.
//

import UIKit

@IBDesignable
open class StrokeView: UIView {
    @IBInspectable public var cornerRadius : CGFloat = 0 {
        didSet{ layer.cornerRadius = cornerRadius }
    }
    
    @IBInspectable public var borderWidth : CGFloat = 0 {
        didSet{ layer.borderWidth = borderWidth }
    }
    
    @IBInspectable public var borderColor : UIColor = .clear {
        didSet{ layer.borderColor = borderColor.cgColor }
    }
}

@IBDesignable
public class RoundButton: UIButton {
    @IBInspectable public var cornerRadius : CGFloat = 0 {
        didSet{ layer.cornerRadius = cornerRadius }
    }
    
    @IBInspectable public var borderWidth : CGFloat = 0 {
        didSet{ layer.borderWidth = borderWidth }
    }
    
    @IBInspectable public var borderColor : UIColor = .clear {
        didSet{ layer.borderColor = borderColor.cgColor }
    }
}
