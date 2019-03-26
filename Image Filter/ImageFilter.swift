//
//  ImageFilter.swift
//  Image Filter
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Foundation
import AppKit

enum ImageFilter: CaseIterable {
    case none
    case sepia
    case mono
    case blur
    case comic
    
    
    
    /**
     It returns the ImageFilter value matching to the given filter name.
     
     - Parameter fromString: The filter name as a String value.
     - Returns: An ImageFilter value.
    */
    static func filter(fromString string: String) -> ImageFilter {
        return ImageFilter.allCases.filter { "\($0)" == string.lowercased() }[0]
    }
    
    
    
    /**
     It creates a CIFilter object for the given image data and a dictionary with filter parameters
     and their values as an optional.
     
     - Parameter imageData: The source image data (a `Data` object).
     - Parameter additionalParameters: A dictionary with parameters and values for the filter
     described by self value.
     
     - Returns: A CIFilter object or nil if the filter object cannot be created.
    */
    func createFilter(forImageWithData imageData: Data, additionalParameters params: [String: Any]?) -> CIFilter? {
        guard let filterName = getFilterName(), let ciImage = getCIImage(fromImageData: imageData) else { return nil }
        if let filter = CIFilter(name: filterName) {
            
            filter.setValue(ciImage, forKey: "inputImage")
            
            if let params = params {
                for (key, value) in params {
                    filter.setValue(value, forKey: key)
                }
            }
            
            return filter
            
        } else {
            return nil
        }
    }
    
    
    
    /**
     It returns a tuple that contains the accepted minimum and maximum
     value of the parameter for the filter described by self.
    */
    func getMinMax() -> (min: Double, max: Double)? {
        switch self {
        case .sepia:
            return (0.0, 0.1)
            
        case .blur:
            return (0.0, 100.0)
            
        default:
            return nil
            
        }
    }
    
    
    
    /**
     It returns the proper parameter name based on the filter
     described by self.
    */
    func getParameterName() -> String? {
        switch self {
        case .sepia:
            return "inputIntensity"
            
        case .blur:
            return "inputRadius"
            
        default:
            return nil
        }
    }
    
    
    
    /**
     It returns the actual CIFilter name as a String based on self value.
    */
    private func getFilterName() -> String? {
        switch self {
        case .sepia:
            return "CISepiaTone"
            
        case .mono:
            return "CIPhotoEffectMono"
            
        case .blur:
            return "CIDiscBlur"
            
        case .comic:
            return "CIComicEffect"
            
        default:
            return nil
        }
    }
    
    
    
    /**
     It creates and returns a CIImage object from the given image data.
     
     - Parameter imageData: The source image as a Data object.
     - Returns: A CIImage object or nil if the CIImage object cannot be created.
    */
    private func getCIImage(fromImageData imageData: Data) -> CIImage? {
        guard let image = NSImage(data: imageData) else { return nil }
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        return CIImage(cgImage: cgImage)
    }
}

