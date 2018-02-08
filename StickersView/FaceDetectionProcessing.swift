//
//  ImageProcessing.swift
//  StickersView
//
//  Created by Adela Toderici on 2018-02-07.
//  Copyright © 2018 Adela Toderici. All rights reserved.
//

import Foundation
import Vision
import UIKit

public class FaceDetectionProcessing: NSObject {
    
    var imageView: UIImageView!
    public var stickerViews:[StickersView] = []
    
    private var orientation:Int32 {
        switch imageView.image!.imageOrientation {
        case .right: return 6
        case .down: return 3
        case .left: return 8
        default: return 1
        }
    }
    
    public init(imageView: UIImageView) {
        self.imageView = imageView
        super.init()
    }
    
    public func processImage() {
        
        if imageView.subviews.count > 0 {
            imageView.subviews.forEach({ $0.removeFromSuperview() })
        }
        
        let faceLandmarksRequest = VNDetectFaceLandmarksRequest(completionHandler: self.handleFaceFeatures)
        let requestHandler = VNImageRequestHandler(cgImage: imageView.image!.cgImage!,
                                                   orientation: CGImagePropertyOrientation(rawValue: UInt32(orientation))! ,options: [:])
        do {
            try requestHandler.perform([faceLandmarksRequest])
        } catch {
            print(error)
        }
    }
    
    func handleFaceFeatures(request: VNRequest, errror: Error?) {
        guard let observations = request.results as? [VNFaceObservation] else {
            fatalError("unexpected result type!")
        }
        
        for face in observations {
            let faceImage = FaceImageProcessing(face, image: imageView.image!)
            imageView.image = faceImage.finalImage
            
            let stickerView = createStickerView(leftPoint: faceImage.topLeftPoint!, rightPoint:faceImage.topRightPoint!)
            imageView.addSubview(stickerView)
        }
    }
    
    func createStickerView(leftPoint: CGPoint, rightPoint: CGPoint) -> StickersView {
        let stickerView = StickersView(leftPoint: leftPoint, rightPoint: rightPoint, parentImageView: imageView)
        stickerViews.append(stickerView)
        
        return stickerView
    }
}
