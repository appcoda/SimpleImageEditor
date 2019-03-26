//
//  ResizeViewController.swift
//  Image Filter
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Cocoa



class ResizeViewController: NSViewController {

    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var originalImageSizeLabel: NSTextField!
    
    @IBOutlet weak var widthTextField: NSTextField!
    
    @IBOutlet weak var heightTextField: NSTextField!
    
    @IBOutlet weak var aspectRatioCheckBox: NSButton!
    
    @IBOutlet weak var percentagePopup: NSPopUpButton!
    
    
    
    // MARK: - Properties
    
    var resizeViewModel = ResizeViewModel()
    
    
    
    // MARK: - VC Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The following closure is called to update the width textfield
        // when the height is being edited and the option to maintain
        // the original aspect ratio is enabled.
        resizeViewModel.autoCalculatedWidth = { [unowned self] (width) in
            self.widthTextField.stringValue = width
        }
        
        // Similarly as above with aim to update the height textfield while
        // the width is being edited.
        resizeViewModel.autoCalculatedHeight = { [unowned self] (height) in
            self.heightTextField.stringValue = height
        }
    }
    
    
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        // Populate the available scale-down percentage values to the percentagePopup.
        percentagePopup.removeAllItems()
        percentagePopup.addItems(withTitles: resizeViewModel.availableResizePercentValues)
        
        // Set the initial state of the "Maintain Aspect Ratio" checkbox depending on the
        // keepAspectRatio flag in the resizeViewModel.
        aspectRatioCheckBox.state = resizeViewModel.keepAspectRatio ? .on : .off
        
        // Show the original image size as it's coming from the ImageEditorViewController.
        originalImageSizeLabel.stringValue = resizeViewModel.originalImageSizeString
        
        // Set self as the delegate for the textfields.
        widthTextField.delegate = self
        heightTextField.delegate = self
    }
    
    
    
    // MARK: - IBAction Methods
    
    @IBAction func resize(_ sender: Any) {
        guard let window = self.view.window, let parent = window.sheetParent else { return }
        parent.endSheet(window, returnCode: .OK)
    }
    
    
    @IBAction func cancelResizing(_ sender: Any) {
        guard let window = self.view.window, let parent = window.sheetParent else { return }
        parent.endSheet(window, returnCode: .cancel)
    }
    
    
    @IBAction func handleAspectRatioChange(_ sender: Any) {
        // Update the keepAspectRatio property of the resizeViewModel object according
        // to the "Maintain Aspect Ratio" check box state.
        resizeViewModel.keepAspectRatio = (aspectRatioCheckBox.state == .on) ? true : false
    }
    
    
    @IBAction func resizeOnPercentage(_ sender: Any) {
        // When resizing using a preset percentage value then keep the
        // aspect ratio no matter what user has set.
        aspectRatioCheckBox.state = .on
        resizeViewModel.keepAspectRatio = true
        
        // Resize using percentage.
        // Width and height values will be shown on the respective textfields
        // through the autoCalculatedWidth and autoCalculatedHeight properties
        // of the resizeViewModel object.
        resizeViewModel.resizeUsingPercentage(atIndex: percentagePopup.indexOfSelectedItem)
    }
    
}



extension ResizeViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        // The object of the notification contains the edited textfield.
        guard let textField = obj.object as? NSTextField else { return }
        
        // Determine which textfield was edited.
        if textField == widthTextField {
            // The width textfield was edited, so update the height textfield if maintining
            // the aspect ratio is enabled.
            guard let widthAsInt = Int(textField.stringValue) else { return }
            resizeViewModel.autoCalculateHeight(usingWidth: CGFloat(widthAsInt))
        } else {
            // The height textfield was edited.
            guard let heightAsInt = Int(textField.stringValue) else { return }
            resizeViewModel.autoCalculateWidth(usingHeight: CGFloat(heightAsInt))
        }
    }
}
