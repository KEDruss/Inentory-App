//
//  customTextView.swift
//  Inentory App
//
//  Created by Egor Kosmin on 30.11.2017.
//  Copyright © 2017 Egor Kosmin. All rights reserved.
//
import UIKit
import Foundation
@IBDesignable class CustomView: UITextView, UITextViewDelegate {
    @IBInspectable var borderWith: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWith
        }
    }
    @IBInspectable var borderRarius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = borderRarius
        }
    }
    @IBInspectable var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

}

