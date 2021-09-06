//
//  String+EmojiImage.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-31.
//  Credit to https://stackoverflow.com/questions/38809425/convert-apple-emoji-string-to-uiimage

import Foundation
import SwiftUI

// Used to create an image from an emoji
extension String {
    func image() -> UIImage? {
        let size = CGSize(width: 30, height: 35)
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        UIColor.clear.set()
        let rect = CGRect(origin: CGPoint(), size: size)
        UIRectFill(CGRect(origin: CGPoint(), size: size))
        (self as NSString).draw(in: rect, withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
