//
//  CGFloat-Extensions.swift
//  image-tests
//
//  Created by Adela Toderici on 2018-01-24.
//  Copyright © 2018 Mykel. All rights reserved.
//

import Foundation
import UIKit

extension CGFloat {
    
    static func calculateAngle(leftPoint: CGPoint, rightPoint: CGPoint) -> CGFloat {
        // https://math.stackexchange.com/questions/1596513/find-the-bearing-angle-between-two-points-in-a-2d-space
        var theta:CGFloat = 0.0
        if (leftPoint.y > rightPoint.y) {
            theta = atan2(leftPoint.y - rightPoint.y, rightPoint.x - leftPoint.x)
        } else {
            theta = atan2(rightPoint.y - leftPoint.y, leftPoint.x - rightPoint.x)
            theta += .pi
        }
        
        if (theta < 0.0) {
            theta += (2.0 * .pi)
        }
        
        return theta
    }
}
