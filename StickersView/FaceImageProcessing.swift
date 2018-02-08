//
//  VisionImageProcessing.swift
//  image-tests
//
//  Created by Adela Toderici on 2018-01-24.
//  Copyright © 2018 Mykel. All rights reserved.
//

import Foundation
import UIKit
import Vision

class FaceImageProcessing: UIImage {
    
    private let lineWidth:CGFloat = 3.0
    
    var finalImage: UIImage?
    var topLeftPoint:CGPoint?
    var topRightPoint:CGPoint?
    
    private var topMidPoint:CGPoint?
    
    init(_ face: VNFaceObservation, image: UIImage) {
        super.init()
        
        self.finalImage = addFaceLandmarksToImage(face, image: image)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required convenience init(imageLiteralResourceName name: String) {
        self.init(imageLiteralResourceName: name)
    }
    
    // MARK: Image process with Vision
    
    func addFaceLandmarksToImage(_ face: VNFaceObservation, image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, true, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        // draw the image
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        // get the face rect
        let w = face.boundingBox.size.width * image.size.width
        let h = face.boundingBox.size.height * image.size.height
        let x = face.boundingBox.origin.x * image.size.width
        let y = face.boundingBox.origin.y * image.size.height
        
        let faceRect = CGRect(x: x, y: y, width: w, height: h)
        
        // forehead points
        var faceLeftPoint:CGPoint = CGPoint(x: 0.0, y: 0.0)
        var faceRightPoint:CGPoint = CGPoint(x: 0.0, y: 0.0)
        
        // draw face box
        drawFaceBox(faceRect: faceRect)
        
        // face contour
        if let landmark = face.landmarks?.faceContour {
            faceLeftPoint = landmark.normalizedPoints[0]
            faceRightPoint = landmark.normalizedPoints[landmark.pointCount - 1]
            
            drawFaceWithClosePath(landmark: landmark, faceRect: faceRect, isClosedPath: true)
        }
        
        // outer lips
        if let landmark = face.landmarks?.outerLips {
            drawFaceWithClosePath(landmark: landmark, faceRect: faceRect, isClosedPath: true)
        }
        
        // inner lips
        if let landmark = face.landmarks?.innerLips {
            drawFaceWithClosePath(landmark: landmark, faceRect: faceRect, isClosedPath: true)
        }
        
        // left eye
        if let landmark = face.landmarks?.leftEye {
            drawFaceWithClosePath(landmark: landmark, faceRect: faceRect, isClosedPath: true)
        }
        
        // right eye
        if let landmark = face.landmarks?.rightEye {
            drawFaceWithClosePath(landmark: landmark, faceRect: faceRect, isClosedPath: true)
        }
        
        // left pupil
        if let landmark = face.landmarks?.leftPupil {
            drawFaceWithClosePath(landmark: landmark, faceRect: faceRect, isClosedPath: true)
        }
        
        // right pupil
        if let landmark = face.landmarks?.rightPupil {
            drawFaceWithClosePath(landmark: landmark, faceRect: faceRect, isClosedPath: true)
        }
        
        // left eyebrow
        if let landmark = face.landmarks?.leftEyebrow {
            drawFaceWithClosePath(landmark: landmark, faceRect: faceRect, isClosedPath: false)
        }
        
        // right eyebrow
        if let landmark = face.landmarks?.rightEyebrow {
            drawFaceWithClosePath(landmark: landmark, faceRect: faceRect, isClosedPath: false)
        }
        
        // nose
        if let landmark = face.landmarks?.nose {
            drawFaceWithClosePath(landmark: landmark, faceRect: faceRect, isClosedPath: true)
        }

        // nose crest
        if let landmark = face.landmarks?.noseCrest {
            drawFaceWithClosePath(landmark: landmark, faceRect: faceRect, isClosedPath: false)
        }
        
        // median line
        drawMedianLine(face, faceRect: faceRect, faceLeftPoint: faceLeftPoint, faceRightPoint: faceRightPoint)
        
        // get forehead line
        drawForeheadLine(faceRect: faceRect, faceLeftPoint: faceLeftPoint, faceRightPoint: faceRightPoint)
        
        // get the final image
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // end drawing context
        UIGraphicsEndImageContext()
        
        return finalImage
    }
    
    func drawFaceBox(faceRect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        context?.setStrokeColor(UIColor.red.cgColor)
        context?.setLineWidth(lineWidth)
        context?.addRect(faceRect)
        context?.drawPath(using: .stroke)
        context?.restoreGState()
    }
    
    func drawFaceWithClosePath(landmark: VNFaceLandmarkRegion2D, faceRect: CGRect, isClosedPath: Bool) {
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        context?.setStrokeColor(UIColor.yellow.cgColor)
        
        for i in 0...landmark.pointCount - 1 {
            let point = landmark.normalizedPoints[i]
            if i == 0 {
                context?.move(to: CGPoint(x: faceRect.origin.x + CGFloat(point.x) * faceRect.size.width,
                                          y: faceRect.origin.y + CGFloat(point.y) * faceRect.size.height))
            } else {
                context?.addLine(to: CGPoint(x: faceRect.origin.x + CGFloat(point.x) * faceRect.size.width,
                                             y: faceRect.origin.y + CGFloat(point.y) * faceRect.size.height))
            }
        }
        
        if isClosedPath {
            context?.closePath()
        }
        context?.setLineWidth(3.0)
        context?.drawPath(using: .stroke)
        context?.saveGState()
    }
    
    func drawMedianLine(_ face: VNFaceObservation, faceRect: CGRect, faceLeftPoint: CGPoint, faceRightPoint: CGPoint) {
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        context?.setStrokeColor(UIColor.blue.cgColor)
        if let landmark = face.landmarks?.medianLine {
            let point = landmark.normalizedPoints[0]
            // start median point
            context?.move(to: CGPoint(x: faceRect.origin.x + CGFloat(point.x) * faceRect.size.width,
                                      y: faceRect.origin.y + CGFloat(point.y) * faceRect.size.height))
            
            for i in 0...landmark.pointCount - 1 { // last point is 0,0
                let point = landmark.normalizedPoints[i]
                context?.addLine(to: CGPoint(x: faceRect.origin.x + CGFloat(point.x) * faceRect.size.width,
                                             y: faceRect.origin.y + CGFloat(point.y) * faceRect.size.height))
            }
            
            let startPoint = landmark.normalizedPoints[0]
            topMidPoint = calculateTopMidPoint(startPoint: landmark.normalizedPoints[0],
                                               endPoint: landmark.normalizedPoints[landmark.pointCount - 1])
            
            context?.move(to: CGPoint(x: faceRect.origin.x + CGFloat(startPoint.x) * faceRect.size.width,
                                      y: faceRect.origin.y + CGFloat(startPoint.y) * faceRect.size.height))
            context?.addLine(to: CGPoint(x: faceRect.origin.x + CGFloat(topMidPoint!.x) * faceRect.size.width,
                                         y: faceRect.origin.y + CGFloat(topMidPoint!.y) * faceRect.size.height))
        }
        context?.setLineWidth(lineWidth)
        context?.drawPath(using: .stroke)
        context?.saveGState()
    }
    
    func drawForeheadLine(faceRect: CGRect, faceLeftPoint: CGPoint, faceRightPoint: CGPoint) {
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        context?.setStrokeColor(UIColor.green.cgColor)
        
        calculateLeftRightPoints(faceLeftPoint: faceLeftPoint, faceRightPoint: faceRightPoint, faceRect: faceRect)
        context?.move(to: topLeftPoint!)
        context?.addLine(to: topRightPoint!)
        
        context?.setLineWidth(lineWidth)
        context?.drawPath(using: .stroke)
        context?.saveGState()
    }
    
    func calculateLeftRightPoints(faceLeftPoint: CGPoint, faceRightPoint: CGPoint, faceRect: CGRect) {
        
        let faceYDist = (MAX(a: faceLeftPoint.y, b: faceRightPoint.y) - MIN(a: faceLeftPoint.y, b: faceRightPoint.y))/2
        var yLeftPos: CGFloat = 0.0
        var yRightPos: CGFloat = 0.0
        var xLeftPos: CGFloat = 0.0
        var xRightPos: CGFloat = 0.0
        if faceLeftPoint.y < faceRightPoint.y - 0.02 {
            yLeftPos = topMidPoint!.y - faceYDist
            yRightPos = topMidPoint!.y + faceYDist
            
            xLeftPos = faceLeftPoint.x - faceYDist
            xRightPos = faceRightPoint.x - faceYDist
        } else if faceLeftPoint.y > faceRightPoint.y + 0.02 {
            yLeftPos = topMidPoint!.y + faceYDist
            yRightPos = topMidPoint!.y - faceYDist
            
            xLeftPos = faceLeftPoint.x + faceYDist
            xRightPos = faceRightPoint.x + faceYDist
        } else {
            yLeftPos = topMidPoint!.y
            yRightPos = yLeftPos
            
            xLeftPos = faceLeftPoint.x + faceYDist
            xRightPos = faceRightPoint.x + faceYDist
        }
        
        topLeftPoint = CGPoint(x: xLeftPos,
                               y: yLeftPos)
        topRightPoint = CGPoint(x: xRightPos,
                                y: yRightPos)
        
        topLeftPoint = CGPoint(x: faceRect.origin.x + CGFloat(topLeftPoint!.x) * faceRect.size.width,
                               y: faceRect.origin.y + CGFloat(topLeftPoint!.y) * faceRect.size.height)
        topRightPoint = CGPoint(x: faceRect.origin.x + CGFloat(topRightPoint!.x) * faceRect.size.width,
                                y: faceRect.origin.y + CGFloat(topRightPoint!.y) * faceRect.size.height)
    }
    
    func calculateTopMidPoint(startPoint: CGPoint, endPoint: CGPoint) -> CGPoint {
        let distance = (endPoint.y + startPoint.y)/2
        let topXDist = (MAX(a: startPoint.x, b: endPoint.x) - MIN(a: startPoint.x, b: endPoint.x))/2
        var xPos:CGFloat = 0.0
        
        if startPoint.x < endPoint.x - 0.02 {
            xPos = startPoint.x - topXDist
        } else if startPoint.y > endPoint.y + 0.02 {
            xPos = startPoint.x + topXDist
        } else {
            xPos = startPoint.x
        }
        
        return CGPoint(x: xPos, y: startPoint.y + distance)
    }
    
    func MIN <T : Comparable> (a: T, b: T) -> T {
        if a > b {
            return b
        }
        return a
    }
    
    func MAX <T : Comparable> (a: T, b: T) -> T {
        if a > b {
            return a
        }
        return b
    }
}
