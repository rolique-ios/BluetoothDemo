//
//  UIFont.swift
//  Spyfall
//
//  Created by bbb on 11/5/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import UIKit

enum CustomFont: String {
    case productSansBold = "ProductSans-Bold",
    smartKid = "SmartKid",
    nanumPenScript = "NanumPen",
    productSansRegular = "ProductSans-Regular",
    shadowIntoLightRegular = "ShadowsIntoLightTwo-Regular"
}

extension UIFont {
    convenience init(font: CustomFont, with size: CGFloat) {
        self.init(name: font.rawValue, size: size)!
    }
}
