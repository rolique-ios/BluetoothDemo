//
//  UIImage.swift
//  Rolique
//
//  Created by Andrii Narinian on 8/16/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    var png: Data? { return self.pngData() }

    func jpeg(with quality: JPEGQuality = .highest) -> Data? {
        return self.jpegData(compressionQuality: quality.rawValue)
    }
    
    func resized(with percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width / size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resized(toHeight height: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: CGFloat(ceil(height / size.height * size.width)), height: height)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func toRect(side: CGFloat, color: UIColor = .white, borderWidth: CGFloat, borderColor: UIColor) -> UIImage? {
        let canvasSize = CGSize(width: side, height: side)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }

        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        draw(in: CGRect(origin: .zero, size: canvasSize))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    static func generateImagePreviewForVideo(from url: URL, completion: @escaping ((UIImage?) -> Void)) {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let scale = 2
        let time = CMTimeMakeWithSeconds(1, preferredTimescale: Int32(scale))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: { // ¯\_(ツ)_/¯
            if let imageRef = try? generator.copyCGImage(at: time, actualTime: nil) {
                completion(UIImage(cgImage: imageRef))
                return
            }
            
            completion(nil)
        })
    }
}
