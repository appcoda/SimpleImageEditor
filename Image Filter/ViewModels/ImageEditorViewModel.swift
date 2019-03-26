//
//  ViewModel.swift
//  Image Filter
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Foundation

typealias ImageDidLoadHandler = ((_ imageData: Data) -> Void)
typealias AlertFilterValues = (minValue: String, maxValue: String, paramName: String)


class ImageEditorViewModel: NSObject {
    
    // MARK: - Properties
    
    /// An `ImageInfo` instance (model instance).
    private var imageInfo: ImageInfo?
    
    
    /// The allowed image types to load through the Open Panel.
    ///
    /// Feel free to add more image types.
    var supportedImageFormats: [String] {
        return ["png", "jpg", "jpeg"]
    }
    
    
    /// The original image data.
    var originalImageData: Data? {
        return imageInfo?.originalImageData
    }
    
    
    /// The displayed image data.
    var displayedImageData: Data? {
        return imageInfo?.displayedImageData
    }
    
    
    /// The size of the displayed image as a CGSize image.
    var displayedImageSize: CGSize? {
        guard let imageData = displayedImageData else { return nil }
        return ImageTools.getImageSize(forImageWithData: imageData)
    }
    
    
    /// The size of the displayed image as a String value (W x H).
    var displayedImageSizeString: String {
        guard let imageSize = displayedImageSize else { return "" }
        return "\(Int(imageSize.width)) x \(Int(imageSize.height))"
    }
    
    
    /// An array with all the CIFilter filters available in the app.
    /// They are returned according to the declared cases in `ImageFilter`
    /// enum, with the first letter uppercased.
    var availableFilters: [String] {
        // Get all available image filters with the first letter uppercased.
        return ImageFilter.allCases.map{ "\($0)".prefix(1).uppercased() + "\($0)".lowercased().dropFirst() }
    }
    
    
    /// The image filter applied to the displayed image.
    /// Default value is `none`.
    var appliedImageFilter: ImageFilter = .none
    
    
    /// A closure that is called when the view should be notified that an image was loaded.
    var imageDidLoadHandler: ImageDidLoadHandler?
    
    
    /// The name and the extension of the loaded image file as taken from the loaded URL.
    var imageName: String? {
        return imageInfo?.originalImageURL?.lastPathComponent
    }
    
    
    /// The extension of the currently loaded image.
    var imageExtension: String? {
        return imageInfo?.originalImageURL?.pathExtension
    }
    
    
    /// It controls whether the no image alert should be shown or not in the view.
    /// Default value is `true`.
    var showNoImageAlert = true
    
    
    
    // MARK: - Init
    
    override init() {
        super.init()
    }
    
    
    
    // MARK: - Public Methods
    
    /**
     It initiates the loading of an image specified by the given URL.
     
     The `imageInfo` object is being initiated using the given URL, and the actual
     image data is loaded. This data is assigned in both the `originalImageData` and
     the `displayedImageData` properties of the `imageHandler` object, as the original
     is necessary to apply new filters.
     
     At the end, the `imageDidLoadHandler` closure is called to notify the View that an
     image has been loaded.
     
     - Parameter url: The URL to load an image from.
     
    */
    func setSelectedImage(atURL url: URL) {
        if imageInfo != nil {
            imageInfo = nil
        }
        
        imageInfo = ImageInfo(withURL: url)
        
        guard let handler = imageDidLoadHandler, let imageData = loadImageData() else { return }
        imageInfo?.originalImageData = imageData
        imageInfo?.displayedImageData = imageData
        handler(imageData)
    }
    
    
    
    /**
     It updates the displayed image data.
     
     - Parameter data: The image data to update with.
    */
    func updateDisplayedImage(withImageData data: Data) {
        imageInfo?.displayedImageData = data
    }
    
    
    
    /**
     It checks whether it's necessary a parameter value to be given
     by users for the image filter that will be applied.
     
     - Returns: `true` when parameter value should be set, `false` otherwise.
    */
    func shouldSetFilterValue() -> Bool {
        // If the getMinMax() method of the appliedImageFilter object returns nil,
        // then no parameter value should be entered by the user for the currently
        // applied filter.
        // If, however, getMinMax() returns a value, then users should enter an
        // image filter parameter.
        return appliedImageFilter.getMinMax() != nil
    }
    
    

    /**
     It returns the current filter's parameter range values and parameter's
     name as they should be displayed in the alert that user will use to
     specify parameter's value.
     
     - Returns: An `AlertFilterValues` value (a tuple with the min & max
     values that define the parameter value range, and the parameter name).
    */
    func getAlertFilterValues() -> AlertFilterValues? {
        guard let minMaxValues = appliedImageFilter.getMinMax(), let paramName = appliedImageFilter.getParameterName() else { return nil }
        return ("\(minMaxValues.min)", "\(minMaxValues.max)", paramName)
    }
    
    
    
    /**
     It checks whether a given value for a CIFilter parameter is within the
     accepted range.
     
     - Parameter value: The value to validate.
     - Returns: `true` if it's an acceptable value, `false` otherwise.
    */
    func isValid(value: Double) -> Bool {
        guard let minMaxValues = appliedImageFilter.getMinMax() else { return false }
        return value >= minMaxValues.min && value <= minMaxValues.max
    }
    
    
    
    /**
     It sets all values in the `imageInfo` object to nil.
    */
    func clearImage() {
        imageInfo?.originalImageData = nil
        imageInfo?.displayedImageData = nil
        imageInfo?.imageName = nil
        imageInfo?.originalImageURL = nil
    }
    
    
    
    /**
     It initiates an image resizing process.
     
     Actual resizing takes place in the `resize(imageWithData:toSize:completion:)`
     class method of the `ImageTools` class.
     
     - Parameter newSize: The size to resize the displayed image to.
     - Parameter completion: The completion handler to call upon finish resizing.
    */
    func resize(toSize newSize: CGSize, completion: @escaping () -> Void) {
        guard let displayedImageData = displayedImageData else { return }
        ImageTools.resize(imageWithData: displayedImageData, toSize: newSize) { (resizedImageData) in
            self.imageInfo?.displayedImageData = resizedImageData
            completion()
        }
    }
    
    
    /**
     It saves the displayed image data to the given URL.
     
     It calls the `save(_:toURL)` class method of the `ImageTools` class.
     
     - Parameter url: The URL to save the displayed image to.
     - Returns: `true` if saving the image data is successful, `false` if the
     displayed image data is nil or saving fails for some reason.
    */
    func saveImage(toURL url: URL) -> Bool {
        guard let displayedImageData = displayedImageData else { return false }
        return ImageTools.save(displayedImageData, toURL: url)
    }
    
    
    
    // MARK: - Private Methods
    
    /**
     It loads the image as a Data object from the URL set in the
     `originalImageURL` property of the `imageInfo` object.
     
     It calls the `loadImageData(fromURL:)` class method of the `ImageTools` class.
     
     - Returns: The loaded image as a Data object, or nil if loading fails or no URL has
     been specified.
    */
    private func loadImageData() -> Data? {
        guard let imageInfo = imageInfo, let imageURL = imageInfo.originalImageURL else { return nil }
        return ImageTools.loadImageData(fromURL: imageURL)
    }
}
