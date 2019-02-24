//
//  Static.swift
//  RemindMe
//
//  Created by Dhia Elhaq Rzig on 7/6/17.
//  Copyright © 2017 devagnos. All rights reserved.
//

import Foundation
import Parse

class Shared
{
    static var twitterUsers = [twitterUser] ()
}
class Colors {
    var gl:CAGradientLayer!
    init() {
        let colorTop = UIColor(red: 255.0 / 255.0, green: 246.0 / 255.0, blue: 183.0 / 255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 246.0 / 255.0, green: 65.0 / 255.0, blue: 2.0 / 108.0, alpha: 1.0).cgColor
        self.gl = CAGradientLayer()
        self.gl.colors = [colorTop, colorBottom]
        self.gl.locations = [0.0, 1.0]
    }
}
