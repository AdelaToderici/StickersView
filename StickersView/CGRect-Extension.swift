//
//  CGRect-Extension.swift
//  image-tests
//
//  Created by Adela Toderici on 2018-01-24.
//  Copyright © 2018 Mykel. All rights reserved.
//

import Foundation
import UIKit

extension StickersView {
    
    func calculateRectOfImageInImageView(imageView: UIImageView) -> CGRect {
        let imageViewSize = imageView.frame.size
        let imgSize = imageView.image?.size
        
        guard let imageSize = imgSize, imgSize != nil else {
            return CGRect.zero
        }
        
        let scaleWidth = imageViewSize.width / imageSize.width
        let scaleHeight = imageViewSize.height / imageSize.height
        let aspect = fmin(scaleWidth, scaleHeight)
        
        var imageRect = CGRect(x: 0, y: 0, width: imageSize.width * aspect, height: imageSize.height * aspect)
        // Center image
        imageRect.origin.x = (imageViewSize.width - imageRect.size.width) / 2
        imageRect.origin.y = (imageViewSize.height - imageRect.size.height) / 2
        
        // Add imageView offset
        imageRect.origin.x += imageView.frame.origin.x
        imageRect.origin.y += imageView.frame.origin.y
        
        return imageRect
    }
    
    func calculateViewFrame(leftPoint: CGPoint, rightPoint: CGPoint, parentImageView: UIImageView) -> CGRect {
        
        let pixelFrame = self.calculateViewPixelFrame(topLeftPoint: leftPoint, topRightPoint: rightPoint)
        let imageFrame = self.calculateRectOfImageInImageView(imageView: parentImageView)
        
        let ratio = parentImageView.image!.size.width/imageFrame.size.width
        
        let height = pixelFrame.size.height / ratio
        let x = pixelFrame.origin.x / ratio
        let y = ((parentImageView.image!.size.height - pixelFrame.origin.y) / ratio) + imageFrame.origin.y - parentImageView.frame.origin.y - height
        let width = pixelFrame.size.width / ratio
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func calculateViewPixelFrame(topLeftPoint: CGPoint, topRightPoint: CGPoint) -> CGRect {
        let x:CGFloat = topLeftPoint.x
        let y:CGFloat = (topLeftPoint.y > topRightPoint.y) ? topLeftPoint.y : topRightPoint.y
        let width = topRightPoint.x - topLeftPoint.x
        
        return CGRect(x: x, y: y, width: width, height: width)
    }
    
    func calculateRescaledFrame(stickerView:StickersView,
                                       aPoint: CGPoint,
                                       bPoint: CGPoint,
                                       stickerImageWidth: CGFloat,
                                       stickerImageHeight: CGFloat) -> CGRect {
        
        let frame = stickerView.basicFrame!
        let abDist = bPoint.x - aPoint.x
        let aDist = (aPoint.x * frame.size.width)/abDist
        let bDist = ((stickerImageWidth - bPoint.x) * frame.size.width)/abDist
        
        let rescaledFrame = CGRect(x: frame.origin.x - aDist,
                                   y: frame.origin.y - aDist - bDist,
                                   width: frame.size.width + aDist + bDist,
                                   height: frame.size.height + aDist + bDist)
        
        let height = (rescaledFrame.size.height * (stickerImageHeight - aPoint.y)) / stickerImageHeight
        
        let resultFrame = CGRect(x: rescaledFrame.origin.x,
                                 y: rescaledFrame.origin.y + height,
                                 width: rescaledFrame.size.width,
                                 height: rescaledFrame.size.height)
        
        stickerView.layer.position = CGPoint(x: resultFrame.origin.x + (resultFrame.size.width / 2),
                                             y: resultFrame.origin.y + (resultFrame.size.height / 2))
        
        return resultFrame
    }
}
