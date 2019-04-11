//
//  RSImage.swift
//  RSCore
//
//  Created by Maurice Parker on 4/11/19.
//  Copyright © 2019 Ranchero Software. All rights reserved.
//

import Foundation

#if os(macOS)
import AppKit

public class RSImage: NSImage {
	
}

#endif

#if os(iOS)
import UIKit

public class RSImage: UIImage {
	
}

#endif

public extension RSImage {
	
	static func scaleImage(_ data: Data, maxPixelSize: Int) -> CGImage? {
		
		guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
			return nil
		}
		
		let numberOfImages = CGImageSourceGetCount(imageSource)
		
		// If the image data contains a smaller image than the max size, just return it.
		for i in 0..<numberOfImages {
			
			guard let cfImageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil) else {
				continue
			}
			
			let imageProperties = cfImageProperties as NSDictionary
			
			let imagePixelWidth = (imageProperties[kCGImagePropertyPixelWidth] as! NSNumber).intValue
			if imagePixelWidth < 1 || imagePixelWidth > maxPixelSize {
				continue
			}
			
			let imagePixelHeight = (imageProperties[kCGImagePropertyPixelHeight] as! NSNumber).intValue
			if imagePixelHeight > 0 && imagePixelHeight <= maxPixelSize {
				if let image = CGImageSourceCreateImageAtIndex(imageSource, i, nil) {
					return image
				}
			}
			
		}
		
		return RSImage.createThumbnail(imageSource, maxPixelSize: maxPixelSize)
		
	}
	
	static func createThumbnail(_ imageSource: CGImageSource, maxPixelSize: Int) -> CGImage? {
		let options = [kCGImageSourceCreateThumbnailWithTransform : true,
					   kCGImageSourceCreateThumbnailFromImageIfAbsent : true,
					   kCGImageSourceThumbnailMaxPixelSize : NSNumber(value: maxPixelSize)]
		return CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)
	}
	
}
