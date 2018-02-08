//
//  StickerView.swift
//  image-tests
//
//  Created by Adela Toderici on 2018-01-26.
//  Copyright © 2018 Mykel. All rights reserved.
//

import UIKit

public class StickersView: UIView {
    
    public var imageView:UIImageView!
    var angle: CGFloat?
    var basicFrame: CGRect?
    var leftPoint: CGPoint?
    var rightPoint: CGPoint?
    var anchorsDist: CGFloat?
    public var stickerIsTapped: Bool? = false
    
    init(leftPoint: CGPoint, rightPoint: CGPoint, parentImageView: UIImageView) {
        super.init(frame: calculateViewFrame(leftPoint: leftPoint, rightPoint: rightPoint, parentImageView: parentImageView))
        
        self.basicFrame = frame
        self.leftPoint = leftPoint
        self.rightPoint = rightPoint
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        self.setupGestures()
        self.angle = calculateAngle(leftPoint: leftPoint, rightPoint: rightPoint)
        self.imageView = createImageView(size: frame.size)
        self.rotateView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK : Public Methods
    
    public func changeSticker(stickerView:StickersView,
                              aPoint: CGPoint,
                              bPoint: CGPoint,
                              stickerImageWidth: CGFloat,
                              stickerImageHeight: CGFloat) {
        
        stickerView.transform = CGAffineTransform.identity
        
        stickerView.frame = calculateRescaledFrame(stickerView: stickerView,
                                                          aPoint: aPoint,
                                                          bPoint: bPoint,
                                                          stickerImageWidth: stickerImageWidth,
                                                          stickerImageHeight: stickerImageHeight)
        
        stickerView.imageView.frame.size = CGSize(width: stickerView.frame.size.width ,
                                                  height: stickerView.frame.size.height)
        
        stickerView.layer.position = calculateViewPosition(view: stickerView)
        stickerView.transform = CGAffineTransform(rotationAngle: stickerView.angle!)
        
        drawBrowline(stickerView: stickerView,
                     aPoint: aPoint,
                     bPoint: bPoint,
                     stickerImageWidth: stickerImageWidth,
                     stickerImageHeight: stickerImageHeight)
    }
    
    // MARK : Private Methods
    
    private func rotateView() {
        let anchor = calculateAnchorPoint(angle: angle!, distance: self.frame.size.width)
        self.anchorsDist = (MAX(a: anchor.x, b: anchor.y) - MIN(a: anchor.x, b: anchor.y)) / 1.8
        
        let xPos = (leftPoint!.y < rightPoint!.y) ?
            self.frame.origin.x + (self.bounds.size.width / 2) - self.anchorsDist! :
            self.frame.origin.x + (self.bounds.size.width / 2) + self.anchorsDist!
        
        self.layer.position = CGPoint(x: xPos,
                                      y: self.frame.origin.y + (self.bounds.size.height / 2) + self.anchorsDist!)
        self.transform = CGAffineTransform(rotationAngle: angle!)
    }
    
    private func drawBrowline(stickerView: StickersView,
                              aPoint: CGPoint,
                              bPoint: CGPoint,
                              stickerImageWidth: CGFloat,
                              stickerImageHeight: CGFloat) {
        
        let frame = stickerView.frame
        let xAPos = (frame.size.width * aPoint.x) / stickerImageWidth
        let xBPos = (frame.size.width * bPoint.x) / stickerImageWidth
        let yPos = (frame.size.height * aPoint.y) / stickerImageHeight
        
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context!.setLineWidth(2.0)
        
        stickerView.imageView.image!.draw(in: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        
        context!.setStrokeColor(UIColor.yellow.cgColor)
        context?.move(to: CGPoint(x: xAPos, y: yPos))
        context?.addLine(to: CGPoint(x: xBPos, y: yPos))
        context!.strokePath()
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        stickerView.imageView.image = finalImage
    }
    
    private func createImageView(size: CGSize) -> UIImageView {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        imageView.isUserInteractionEnabled = true
        imageView.alpha = 0.5
        self.addSubview(imageView)
        
        return imageView
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(StickersView.handleTap(_:)))
        self.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(StickersView.handlePan(_:)))
        self.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(StickersView.handlePinch(_:)))
        self.addGestureRecognizer(pinchGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(StickersView.handleRotation(_:)))
        self.addGestureRecognizer(rotationGesture)
    }
    
    // MARK : CGRect
    
    private func calculateRectOfImageInImageView(imageView: UIImageView) -> CGRect {
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
    
    private func calculateViewFrame(leftPoint: CGPoint, rightPoint: CGPoint, parentImageView: UIImageView) -> CGRect {
        
        let pixelFrame = self.calculateViewPixelFrame(topLeftPoint: leftPoint, topRightPoint: rightPoint)
        let imageFrame = self.calculateRectOfImageInImageView(imageView: parentImageView)
        
        let ratio = parentImageView.image!.size.width/imageFrame.size.width
        
        let height = pixelFrame.size.height / ratio
        let x = pixelFrame.origin.x / ratio
        let y = ((parentImageView.image!.size.height - pixelFrame.origin.y) / ratio) + imageFrame.origin.y - parentImageView.frame.origin.y - height
        let width = pixelFrame.size.width / ratio
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    private func calculateViewPixelFrame(topLeftPoint: CGPoint, topRightPoint: CGPoint) -> CGRect {
        let x:CGFloat = topLeftPoint.x
        let y:CGFloat = (topLeftPoint.y > topRightPoint.y) ? topLeftPoint.y : topRightPoint.y
        let width = topRightPoint.x - topLeftPoint.x
        
        return CGRect(x: x, y: y, width: width, height: width)
    }
    
    private func calculateRescaledFrame(stickerView:StickersView,
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
    
    // MARK : Anchor point
    
    private func calculateAnchorPoint(angle: CGFloat, distance: CGFloat) -> CGPoint {
        
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
    
    private func calculateViewPosition(view: StickersView) -> CGPoint {
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
    
    // MARK : Angle
    
    private func calculateAngle(leftPoint: CGPoint, rightPoint: CGPoint) -> CGFloat {
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
    
    private func MIN <T : Comparable> (a: T, b: T) -> T {
        if a > b {
            return b
        }
        return a
    }
    
    private func MAX <T : Comparable> (a: T, b: T) -> T {
        if a > b {
            return a
        }
        return b
    }
    
    // MARK: Actions
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        stickerIsTapped = true
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)
        if let view = sender.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
        }
        
        sender.setTranslation(CGPoint.zero, in: self)
    }
    
    @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
        if let view = sender.view {
            view.transform = view.transform.scaledBy(x: sender.scale, y: sender.scale)
            sender.scale = 1
        }
    }
    
    @objc func handleRotation(_ sender: UIRotationGestureRecognizer) {
        if let view = sender.view {
            view.transform = view.transform.rotated(by: sender.rotation)
            sender.rotation = 0
        }
    }
}

extension StickersView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
