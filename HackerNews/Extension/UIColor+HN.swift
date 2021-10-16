//
//  UIColor+HN.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 10/16/21.
//  Copyright © 2021 Kenichi Fujita. All rights reserved.
//

import UIKit

extension UIColor {
    func adjustAlpha(to percent: CGFloat) -> UIColor? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(
            red: red,
            green: green,
            blue: blue,
            alpha: percent/100
        )
    }
}
