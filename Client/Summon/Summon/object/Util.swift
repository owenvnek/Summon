//
//  Util.swift
//  Summon
//
//  Created by Owen Vnek on 1/18/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import Foundation
import UIKit

class Util {
    
    static func binarySearch<T>(inputArr:Array<T>, searchItem: T, comparator: (T, T) -> Int) -> Int? {
        var lowerIndex = 0
        var upperIndex = inputArr.count - 1
        while true {
            let currentIndex = (lowerIndex + upperIndex)/2
            let item = inputArr[currentIndex]
            let comparison = comparator(item, searchItem)
            if(comparison == 0) {
                return currentIndex
            } else if (lowerIndex > upperIndex) {
                return nil
            } else {
                if (comparison > 0) {
                    upperIndex = currentIndex - 1
                } else {
                    lowerIndex = currentIndex + 1
                }
            }
        }
    }
    
}

extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}

extension UITextField {
  func setBottomBorder() {
    self.borderStyle = .none
    self.layer.backgroundColor = UIColor.white.cgColor
    self.layer.masksToBounds = false
    self.layer.shadowColor = UIColor.gray.cgColor
    self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
    self.layer.shadowOpacity = 1.0
    self.layer.shadowRadius = 0.0
  }
}
