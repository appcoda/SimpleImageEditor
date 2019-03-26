//
//  ResizeViewModel.swift
//  Image Filter
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Foundation

typealias AutoCalculatedWidth = ((_ width: String) -> Void)
typealias AutoCalculatedHeight = ((_ height: String) -> Void)

class ResizeViewModel: NSObject {
    
    // MARK: - Properties
    
    /// An `ImageSize` instance which is the model.
    private(set) var imageSize = ImageSize()
    
    
    /// The original image size as a String value.
    var originalImageSizeString: String {
        guard let originalSize = imageSize.originalSize else {
            return "Original Image Size: -"
        }
        
        return "Original Image Size: \(Int(originalSize.width)) x \(Int(originalSize.height))"
    }
    
    
    /// Indicates whether the original aspect ratio should be kept
    /// when typing custom values for the width and height.
    ///
    /// If `true`, width and height are calculated automatically using
    /// the `autoCalculateWidth(usingHeight:)` and `autoCalculateHeight(usingWidth:)`
    /// methods respetively that are called from the view.
    ///
    /// The value of this property get changed when the "Maintain Aspect Ratio"
    /// check box state gets changed.
    var keepAspectRatio = true
    
    
    /// The available scale-down percentage options displayed to the user.
    ///
    /// Feel free to add more values.
    let availableResizePercentValues = ["100%", "75%", "60%", "50%", "25%", "10%"]
    
    
    /// A closure to pass the width to the view as a String value
    /// after having calculated it automatically.
    var autoCalculatedWidth: AutoCalculatedWidth?
    
    
    /// A closure to pass the height to the view as a String value
    /// after having calculated it automatically.
    var autoCalculatedHeight: AutoCalculatedHeight?
    
    
    /// The edited size as a CGSize value.
    var editedSize: CGSize? {
        return imageSize.editedSize
    }
    
    
    
    // MARK: - Init
    
    override init() {
        super.init()
    }
    
    
    
    // MARK: - Custom Methods
    
    /**
     It keeps the given size as the original one.
     
     - Parameter originalSize: The original size of the image that should
     be kept in the `imageSize` object.
    */
    func set(originalSize: CGSize) {
        imageSize.originalSize = originalSize
        imageSize.editedSize = originalSize
    }
    
    
    
    /**
     It calculates the height automatically while the width is being edited.
     
     The height is calculated if only the `keepAspectRatio` flag is `true`.
     In that case, and after having calculated the height based on the given
     width and by using the original ratio, it's calling the `autoCalculatedHeight`
     closure to let the view update the height textfield accordingly.
     
     - Parameter width: The width of the image as typed by the user.
     */
    func autoCalculateHeight(usingWidth width: CGFloat) {
        if keepAspectRatio {
            guard let originalSize = imageSize.originalSize, let autoCalculatedHeight = autoCalculatedHeight else { return }
            let ratio = originalSize.width / originalSize.height
            let height = width / ratio
            autoCalculatedHeight("\(Int(height))")
            
            // Keep the edited width and height.
            imageSize.editedSize = CGSize(width: width, height: height)
        } else {
            // If keeping aspect ratio is off, then just keep
            // the edited width.
            imageSize.editedSize?.width = width
        }
    }
    
    
    
    /**
     It calculates the width automatically while the height is being edited.
     
     The width is calculated if only the `keepAspectRatio` flag is `true`.
     In that case, and after having calculated the width based on the given
     height and by using the original ratio, it's calling the `autoCalculatedWidth`
     closure to let the view update the width textfield accordingly.
     
     - Parameter height: The heigth of the image as typed by the user.
    */
    func autoCalculateWidth(usingHeight height: CGFloat) {
        if keepAspectRatio {
            guard let originalSize = imageSize.originalSize, let autoCalculatedWidth = autoCalculatedWidth else { return }
            let ratio = originalSize.width / originalSize.height
            let width = height * ratio
            autoCalculatedWidth("\(Int(width))")
            
            // Keep the edited width and height.
            imageSize.editedSize = CGSize(width: width, height: height)
        } else {
            // If keeping aspect ratio is off, then just keep
            // the edited height.
            imageSize.editedSize?.height = height
        }
    }
    
    
    
    /**
     Calculate the new width and height based on the percent matching
     to the given index in the `availableResizePercentValues` array.
     
     - Parameter index: The index of the percentage in the
     `availableResizePercentValues` array.
    */
    func resizeUsingPercentage(atIndex index: Int) {
        guard let originalSize = imageSize.originalSize, let autoCalculatedWidth = autoCalculatedWidth, let autoCalculatedHeight = autoCalculatedHeight else { return }
        
        // Get the actual percentage value as a CGFloat from the percentage string.
        // For example, the "25%" value will result to 0.25.
        let percentageString = availableResizePercentValues[index]
        let percentage = CGFloat((Double(String(percentageString.dropLast())) ?? 100) / 100)
        
        // Calculale the original ratio and then the width and height values.
        let ratio = originalSize.width / originalSize.height
        let width = originalSize.width * percentage
        let height = width / ratio
        
        // Keep the edited width and height.
        imageSize.editedSize = CGSize(width: width, height: height)
        
        // Call the following closures to update the textfields.
        autoCalculatedWidth("\(Int(width))")
        autoCalculatedHeight("\(Int(height))")
    }
    
}
