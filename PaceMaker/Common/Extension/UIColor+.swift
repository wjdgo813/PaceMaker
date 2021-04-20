//
//  Color+.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/04/20.
//

import UIKit

extension UIColor {
    public convenience init(hexStr:String, alpha:CGFloat = 1.0){
        var rgbValue:UInt32 = 0
        let trimedHexStr = hexStr.trimmingCharacters(in: CharacterSet.whitespaces)
        let scanner:Scanner = Scanner(string:trimedHexStr)
        scanner.scanLocation = 1    //by pass '#'
        scanner.scanHexInt32(&rgbValue)
        let rgbRed:CGFloat = CGFloat((rgbValue & 0xFF0000)>>16)/255.0
        let rgbGreen:CGFloat = CGFloat((rgbValue & 0x00FF00)>>8)/255.0
        let rgbBlue:CGFloat = CGFloat(rgbValue & 0x0000FF)/255.0
        
        self.init(red: rgbRed, green: rgbGreen, blue: rgbBlue, alpha: alpha)
    }
}
