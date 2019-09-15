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
public typealias RSImage = NSImage
#endif

#if os(iOS)
import UIKit
public typealias RSImage = UIImage
#endif

public extension RSImage {

	func maskWithColor(color: CGColor) -> RSImage? {
		
		#if os(macOS)
		guard let maskImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
		#else
		guard let maskImage = cgImage else { return nil }
		#endif
		
		let width = size.width
		let height = size.height
		let bounds = CGRect(x: 0, y: 0, width: width, height: height)
		
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
		let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
		
		context.clip(to: bounds, mask: maskImage)
		context.setFillColor(color)
		context.fill(bounds)
		
		if let cgImage = context.makeImage() {
			#if os(macOS)
			let coloredImage = RSImage(cgImage: cgImage, size: CGSize(width: cgImage.width, height: cgImage.height))
			#else
			let coloredImage = RSImage(cgImage: cgImage)
			#endif
			return coloredImage
		} else {
			return nil
		}
		
	}

	func dataRepresentation() -> Data? {
		#if os(macOS)
			return tiffRepresentation
		#else
			return pngData()
		#endif
	}
		
	#if os(iOS)
	static func rs_image(with data: Data, imageResultBlock: @escaping (RSImage?) -> Void) {
		DispatchQueue.global().async {
			let image = UIImage(data: data)
			DispatchQueue.main.async {
				imageResultBlock(image)
			}
		}
	}
	#endif

	// Note: the returned image may be larger than maxPixelSize, but not more than maxPixelSize * 2.
	static func scaleImage(_ data: Data, maxPixelSize: Int) -> CGImage? {
		
		guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
			return nil
		}
		
		let numberOfImages = CGImageSourceGetCount(imageSource)

		// If the image size matches exactly, then return it.
		for i in 0..<numberOfImages {

			guard let cfImageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil) else {
				continue
			}

			let imageProperties = cfImageProperties as NSDictionary

			let imagePixelWidth = (imageProperties[kCGImagePropertyPixelWidth] as! NSNumber).intValue
			if imagePixelWidth != maxPixelSize {
				continue
			}
			let imagePixelHeight = (imageProperties[kCGImagePropertyPixelHeight] as! NSNumber).intValue
			if imagePixelHeight != maxPixelSize {
				continue
			}
			return CGImageSourceCreateImageAtIndex(imageSource, i, nil)
		}

		// If image height > maxPixelSize, but <= maxPixelSize * 2, then return it.
		for i in 0..<numberOfImages {

			guard let cfImageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil) else {
				continue
			}

			let imageProperties = cfImageProperties as NSDictionary

			let imagePixelWidth = (imageProperties[kCGImagePropertyPixelWidth] as! NSNumber).intValue
			if imagePixelWidth > maxPixelSize * 2 || imagePixelWidth < maxPixelSize {
				continue
			}
			let imagePixelHeight = (imageProperties[kCGImagePropertyPixelHeight] as! NSNumber).intValue
			if imagePixelHeight > maxPixelSize * 2 || imagePixelHeight < maxPixelSize {
				continue
			}
			return CGImageSourceCreateImageAtIndex(imageSource, i, nil)
		}


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
