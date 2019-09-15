//
//  UIView.swift
//  Rolique
//
//  Created by Bohdan Savych on 8/16/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

extension UIView {
    func addSubviewAndDisableMaskTranslate(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
    }
    
    func addBorder(width: CGFloat, color: UIColor, cornerRadius: CGFloat = 0) {
        layer.addBorder(width: width, color: color, cornerRadius: cornerRadius)
    }
    
    func roundCorner(radius: CGFloat) {
        layer.roundCorner(radius: radius)
    }
    
    func animateCornerRadius(to value: CGFloat, with interval: TimeInterval) {
        layer.animateCornerRadius(to: value, with: interval)
    }
    
    func toCirle() {
        layer.roundCorner(radius: bounds.height / 2)
    }
    
    func toFront() {
        self.superview?.bringSubviewToFront(self)
    }
    
    func createAndConfigureSubview(_ view: UIView?) {
        guard let view = view else { return }
        
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        view.frame = frame
        addSubview(view)
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGSize) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: radius)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func getSubviewsOf<T: UIView>(view: UIView) -> [T] {
        var subviews = [T]()
        
        for subview in view.subviews {
            subviews += getSubviewsOf(view: subview) as [T]
            
            if let subview = subview as? T {
                subviews.append(subview)
            }
        }
        
        return subviews
    }
    
    func addGradient(with colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0.5, y: 0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1)) {
        let gradeintLayer = CAGradientLayer()
        gradeintLayer.colors = colors.map { $0.cgColor }
        gradeintLayer.startPoint = startPoint
        gradeintLayer.endPoint = endPoint
        
        layer.insertSublayer(gradeintLayer, at: 0)
    }
    
    var leftSafeAreaOffset: CGFloat {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            return window?.safeAreaInsets.left ?? 0
        } else {
            return 0
        }
    }
    
    static var bottomSafeAreaOffset: CGFloat {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            return window?.safeAreaInsets.bottom ?? 0
        } else {
            return 0
        }
    }
    
    var rightSafeAreaOffset: CGFloat {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            return window?.safeAreaInsets.right ?? 0
        } else {
            return 0
        }
    }
}
