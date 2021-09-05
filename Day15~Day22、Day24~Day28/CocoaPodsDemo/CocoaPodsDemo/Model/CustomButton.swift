//
//  CustomButton.swift
//  CocoaPodsDemo
//
//  Created by Leo Ho on 2021/8/13.
//

import Foundation
import UIKit

@IBDesignable class CustomButton: UIButton {
    // MARK:- UIButton 圓角設定 #1
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    // MARK:- UIButton 框線設定 #2
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        } set {
            layer.borderWidth = newValue
        }
    }
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor!)
        } set {
            layer.borderColor = newValue.cgColor
        }
    }
}
