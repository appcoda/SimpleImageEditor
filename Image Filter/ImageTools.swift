//
//  ImageTools.swift
//  Image Filter
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Foundation
import AppKit


class ImageTools {
    
    /**
     It returns the size of the image whose data is given as a parameter value.
     
     - Parameter imageData: The source image as a Data object.
     - Returns: A CGSize value or nil if no NSImage can be created from the
     parameter data.
    */
    class func getImageSize(forImageWithData imageData: Data) -> CGSize? {
        guard let image = NSImage(data: imageData) else { return nil }
        return image.size
    }


    
    /**
     It resizes an image whose data is given as a parameter value to the given size.
     
     - Parameter imageData: The source image as a Data object.
     - Parameter newSize: The new size that the original image should be resized to.
     - Parameter completion: The completion handler to call upon finish resizing.
     - Parameter resizedImageData: The resized image as a Data object that is returned to
     the caller through the completion handler, or nil if the resizing process fails.
    */
    class func resize(imageWithData imageData: Data, toSize newSize: CGSize, completion: (_ resizedImageData: Data?) -> Void) {
        guard let image = NSImage(data: imageData) else { completion(nil); return }
        let resizedImage = NSImage(size: newSize)
        resizedImage.lockFocus()
        let originalRect = NSRect(x: 0.0, y: 0.0, width: image.size.width, height: image.size.height)
        let finalRect = NSRect(origin: CGPoint(x: 0.0, y: 0.0), size: newSize)
        image.draw(in: finalRect, from: originalRect, operation: .sourceOver, fraction: 1.0)
        resizedImage.unlockFocus()
        completion(resizedImage.tiffRepresentation)
    }
 
    
    
    /**
     It saves the given image data to the specified URL.
     
     - Parameter imageData: The image as a Data object.
     - Parameter url: The URL where the image should be saved to.
     - Returns: `true` on successful saving, `false` otherwise.
    */
    class func save(_ imageData: Data, toURL url: URL) -> Bool {    // save(_ imageData: Data, toURL url: URL, imageExtension: String) -> Bool
        do {
            try imageData.write(to: url)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    
    
    /**
     It loads and image from the given URL and returns a Data object.
     
     - Parameter url: The source URL.
     - Returns: The image data as a Data object, or nil if loading the contents of
     the image data fails.
     
     */
    class func loadImageData(fromURL url: URL) -> Data? {
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
}
