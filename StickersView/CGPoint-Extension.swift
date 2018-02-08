//
//  Any-Extension.swift
//  image-tests
//
//  Created by Adela Toderici on 2018-01-24.
//  Copyright © 2018 Mykel. All rights reserved.
//

import Foundation
import UIKit

extension StickersView {

    func calculateAnchorPoint(angle: CGFloat, distance: CGFloat) -> CGPoint {

        let i:CGFloat = 0.707106 // (= √2 / 2)
        let x:CGFloat = cos(angle + (.pi / 4)) * (distance * i)
        let y:CGFloat = sin(angle + (.pi / 4)) * (distance * i)

        if angle == .pi {
            return CGPoint(x: 0, y: 0)
        } else if angle < 1 {
            return CGPoint(x: x, y: y)
        } else {
            return CGPoint(x: y, y: x)
        }
    }
    
    func calculateViewPosition(view: StickersView) -> CGPoint {
        let dist = ((view.frame.size.width * view.anchorsDist!) / view.basicFrame!.size.width) / (view.frame.size.width / view.basicFrame!.size.width)
        
        let basicX = view.basicFrame!.origin.x
        let basicY = view.basicFrame!.origin.y
        var xPos = view.frame.origin.x
        var yPos = view.frame.origin.y
        
        if (basicX < 0 && xPos < 0) {
            xPos = abs(MIN(a: basicX, b: xPos) / MAX(a: basicX, b: xPos))
        } else {
            xPos = abs(MAX(a: basicX, b: xPos) / MIN(a: basicX, b: xPos))
        }
        
        if (basicY < 0 && yPos < 0) {
            yPos = abs(MIN(a: basicY, b: yPos) / MAX(a: basicY, b: yPos))
        } else {
            yPos = abs(MAX(a: basicY, b: yPos) / MIN(a: basicY, b: yPos))
        }
        
        let x = (view.leftPoint!.y <  view.rightPoint!.y) ?
            view.frame.origin.x + (view.bounds.size.width / 2) - dist :
            view.frame.origin.x + (view.bounds.size.width / 2) + dist
        
        let y = view.frame.origin.y + (view.bounds.size.height / 2) + dist
        
        return CGPoint(x: x, y: y)
    }
}
