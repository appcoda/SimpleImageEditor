//
//  ImageEditorViewController.swift
//  Image Filter
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Cocoa

class ImageEditorViewController: NSViewController {

    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var imageView: NSImageView!
    
    @IBOutlet weak var colorFilters: NSPopUpButton!
    
    @IBOutlet weak var imageNameLabel: NSTextField!
    
    @IBOutlet weak var imageSizeLabel: NSTextField!
    
    
    
    // MARK: - Properties
    
    var imageEditorViewModel = ImageEditorViewModel()
    
    
    
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Populate the available filters to the colorFilters popup button.
        colorFilters.removeAllItems()
        colorFilters.addItems(withTitles: imageEditorViewModel.availableFilters)
        
        
        // The following closure is called when an image is loaded.
        // In it:
        // - Show the image to the imageView.
        // - Show the image name and size to the respective labels.
        // - Make sure that the shown filter is "none" in the colorFilters popup.
        imageEditorViewModel.imageDidLoadHandler = { [unowned self] (imageData) in
            guard let image = NSImage(data: imageData) else { return }
            self.imageView?.image = image
            self.imageNameLabel.stringValue = self.imageEditorViewModel.imageName ?? ""
            self.imageSizeLabel.stringValue = self.imageEditorViewModel.displayedImageSizeString
            self.colorFilters.selectItem(at: 0)
        }
        
        
        // Originally the name and size labels shouldn't show anything.
        imageNameLabel.stringValue = ""
        imageSizeLabel.stringValue = ""
    }
    
    
    
    // MARK: - Custom Methods
    
    /**
     It creates a CIFilter using the displayed image and produces a new image.
     
     The CIFilter to create is specified in the `appliedImageFilter` of the `imageEditorViewModel` object.
     This method is using the `createFilter(forImageWithData:additionalParameters:)` method of the
     `ImageFilter` enum to create the actual filter. If creating it fails, then the original image is
     set to the image view. On success it calls the `showFiltered(image:)` to display the new image
     after applying the filter effect.
     
     - Parameter params: A dictionary that contains the parameter names and values for filters that require
     parameters to be set. It can be nil, which means that no parameters are required by the filter, or the
     default values shoule be used.
     
    */
    func applyFilter(usingParameters params: [String: Any]?) {
        guard let originalImageData = imageEditorViewModel.originalImageData else { return }
        guard let filter = imageEditorViewModel.appliedImageFilter.createFilter(forImageWithData: originalImageData, additionalParameters: params) else {
            imageView.image = NSImage(data: originalImageData)
            return
        }
        
        showFiltered(image: filter.outputImage)
    }
    
    
    
    /**
     It gets the a CIImage, it converts it to a NSImage and it assigns it to the image view.
     
     The input image is a CIImage as created after applying the selected filter. The process shown
     in code is necessary to create a NSImage out of the given CIImage.
     
     Once the NSImage is created and assigned to the image view, the displayed image object is also
     updated in the `imageEditorViewModel` object through the `updateDisplayedImage(withImageData:)`.
     
     - Parameter image: The CIImage produced by the applied CIFilter to the displayed image.
    */
    func showFiltered(image: CIImage?) {
        guard let image = image else { return }
        let renderedImage = NSCIImageRep(ciImage: image)
        let displayImage = NSImage()
        displayImage.addRepresentation(renderedImage)
        imageView.image = displayImage
        
        // Convert the NSImage object to a data object using the tiffRepresentation
        // and update the displayed image object in the imageEditorViewModel object.
        guard let imageData = displayImage.tiffRepresentation else { return }
        imageEditorViewModel.updateDisplayedImage(withImageData: imageData)
        imageSizeLabel.stringValue = imageEditorViewModel.displayedImageSizeString
    }
    
    
    
    /**
     It initiates the resizing process of the displayed image using the given new size.
     
     Resizing is being initiated in the `resize(toSize:)` method of the `imageEditorViewModel`
     object.
     
     Note that along with the image view that is updated after the resize if finished, the
     `imageSizeLabel` is updated with the new size too.
     
     - Parameter newSize: The new size to resize to as it's taken from the `ResizeViewController`.
     
    */
    func resize(toSize newSize: CGSize) {
        imageEditorViewModel.resize(toSize: newSize) { [unowned self] in
            DispatchQueue.main.async { [unowned self] in
                guard let imageData = self.imageEditorViewModel.displayedImageData else { return }
                self.imageView.image = NSImage(data: imageData)
                self.imageSizeLabel.stringValue = self.imageEditorViewModel.displayedImageSizeString
            }
        }
    }
    
    
    
    func showNoImageAlert() {
        if imageEditorViewModel.showNoImageAlert {
            let alert = NSAlert()
            alert.messageText = "Missing image"
            alert.informativeText = "There is no image to apply the filter to."
            
            alert.showsSuppressionButton = true
            alert.suppressionButton?.title = "I got it, don't show me this message again."
            alert.suppressionButton?.target = self
            alert.suppressionButton?.action = #selector(handleNoImageAlertSuppressionButtonClick(_:))
            
            alert.beginSheetModal(for: self.view.window!) { (response) in
                
            }
        }
    }
    
    
    @objc func handleNoImageAlertSuppressionButtonClick(_ suppressionButton: NSButton) {
        imageEditorViewModel.showNoImageAlert = suppressionButton.state == .on ? false : true
    }
    
    
    
    func showAlert(withFilterValues filterValues: AlertFilterValues) {
        let alert = NSAlert()
        alert.messageText = "Apply Image Filter"
        alert.informativeText = "Enter a value between \(filterValues.minValue) and \(filterValues.maxValue) for the [\(filterValues.paramName)] parameter:"
        
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Use default value")
        
        let textfield = NSTextField(frame: NSRect(x: 0.0, y: 0.0, width: 80.0, height: 24.0))
        textfield.alignment = .center
        alert.accessoryView = textfield
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            
            if let value = Double(textfield.stringValue) {
                if imageEditorViewModel.isValid(value: value) {
                    
                    let paramDict = [filterValues.paramName: value]
                    applyFilter(usingParameters: paramDict)
                    
                } else {
                    applyFilter(usingParameters: nil)
                }
            } else {
                applyFilter(usingParameters: nil)
            }
            
        } else if response == .alertThirdButtonReturn {
            applyFilter(usingParameters: nil)
        }
    }
    
    
    
    // MARK: - IBAction Methods
    
    @IBAction func openImage(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = imageEditorViewModel.supportedImageFormats
        panel.message = "Select an image to open."
        
        // Show the panel modally.
        let response = panel.runModal()
        
        if response == NSApplication.ModalResponse.OK {
            guard let selectedURL = panel.url else { return }
            imageEditorViewModel.setSelectedImage(atURL: selectedURL)
        }
        
    }
    
    
    
    @IBAction func saveImage(_ sender: Any) {
        guard let _ = imageEditorViewModel.displayedImageData, let imageExtension = imageEditorViewModel.imageExtension else { return }
        
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = [imageExtension]
        savePanel.nameFieldStringValue = imageEditorViewModel.imageName ?? "untitled"
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        
        let response = savePanel.runModal()
        
        if response == NSApplication.ModalResponse.OK {
            guard let targetURL = savePanel.url else { return }
            _ = self.imageEditorViewModel.saveImage(toURL: targetURL)
        }
    }
    
    
    
    @IBAction func clearImage(_ sender: Any) {
        imageEditorViewModel.clearImage()
        imageView.image = nil
        imageNameLabel.stringValue = ""
        imageSizeLabel.stringValue = ""
        colorFilters.selectItem(at: 0)
    }
    
    
    
    
    @IBAction func selectImageFilter(_ sender: Any) {
        guard let _ = imageEditorViewModel.displayedImageData else {
            showNoImageAlert()
            colorFilters.selectItem(at: 0)
            return
        }
        
        let selectedFilter = colorFilters.itemTitle(at: colorFilters.indexOfSelectedItem)
        imageEditorViewModel.appliedImageFilter = ImageFilter.filter(fromString: selectedFilter)
        
        if !imageEditorViewModel.shouldSetFilterValue() {
            applyFilter(usingParameters: nil)
        } else {
            if let alertFilterValues = imageEditorViewModel.getAlertFilterValues() {
                showAlert(withFilterValues: alertFilterValues)
            }
        }
    }
    
    
    
    @IBAction func resizeImage(_ sender: Any) {
        let storyboardName = NSStoryboard.Name(stringLiteral: "Main")
        let storyboard = NSStoryboard(name: storyboardName, bundle: nil)
        
        let sceneIdentifier = NSStoryboard.SceneIdentifier(stringLiteral: "ResizeWindowController")
        guard let windowController = storyboard.instantiateController(withIdentifier: sceneIdentifier) as? NSWindowController,
            let resizeWindow = windowController.window,
            let resizeViewController = windowController.contentViewController as? ResizeViewController,
            let displayedImageSize = imageEditorViewModel.displayedImageSize else { return }
        
        resizeViewController.resizeViewModel.set(originalSize: displayedImageSize)
        
        self.view.window?.beginSheet(resizeWindow, completionHandler: { (response) in
            if response == NSApplication.ModalResponse.OK {
                guard let newSize = resizeViewController.resizeViewModel.editedSize else { return }
                self.resize(toSize: newSize)
            }
        })
    }
    
    
}
