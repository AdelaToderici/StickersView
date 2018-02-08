//
//  StickerView.swift
//  image-tests
//
//  Created by Adela Toderici on 2018-01-26.
//  Copyright © 2018 Mykel. All rights reserved.
//

import UIKit

public class StickersView: UIView {
    
    var imageView:UIImageView!
    var angle: CGFloat?
    var basicFrame: CGRect?
    var leftPoint: CGPoint?
    var rightPoint: CGPoint?
    var anchorsDist: CGFloat?
    var stickerIsTapped: Bool? = false
    
    init(leftPoint: CGPoint, rightPoint: CGPoint, parentImageView: UIImageView) {
        super.init(frame: CGRect.calculateViewFrame(leftPoint: leftPoint, rightPoint: rightPoint, parentImageView: parentImageView))
        
        self.basicFrame = frame
        self.leftPoint = leftPoint
        self.rightPoint = rightPoint
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        self.setupGestures()
        self.angle = CGFloat.calculateAngle(leftPoint: leftPoint, rightPoint: rightPoint)
        self.imageView = createImageView(size: frame.size)
        self.rotateView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK : Public Methods
    
    func changeSticker(stickerView:StickersView,
                       aPoint: CGPoint,
                       bPoint: CGPoint,
                       stickerImageWidth: CGFloat,
                       stickerImageHeight: CGFloat) {
        
        stickerView.transform = CGAffineTransform.identity
        
        stickerView.frame = CGRect.calculateRescaledFrame(stickerView: stickerView,
                                                          aPoint: aPoint,
                                                          bPoint: bPoint,
                                                          stickerImageWidth: stickerImageWidth,
                                                          stickerImageHeight: stickerImageHeight)
        
        stickerView.imageView.frame.size = CGSize(width: stickerView.frame.size.width ,
                                                  height: stickerView.frame.size.height)
        
        stickerView.layer.position = CGPoint.calculateViewPosition(view: stickerView)
        stickerView.transform = CGAffineTransform(rotationAngle: stickerView.angle!)
        
        drawBrowline(stickerView: stickerView,
                     aPoint: aPoint,
                     bPoint: bPoint,
                     stickerImageWidth: stickerImageWidth,
                     stickerImageHeight: stickerImageHeight)
    }
    
    // MARK : Private Methods
    
    private func rotateView() {
        let anchor = CGPoint.calculateAnchorPoint(angle: angle!, distance: self.frame.size.width)
        self.anchorsDist = (CompareT().MAX(a: anchor.x, b: anchor.y) - CompareT().MIN(a: anchor.x, b: anchor.y)) / 1.8
        
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
