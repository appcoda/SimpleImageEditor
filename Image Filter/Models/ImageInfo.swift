//
//  ImageInfo.swift
//  Image Filter
//
//  Created by Gabriel Theodoropoulos on 20/03/2019.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Foundation

struct ImageInfo {
    var originalImageURL: URL?
    var originalImageData: Data?
    var displayedImageData: Data?
    var imageName: String?
    
    init(withURL url: URL) {
        originalImageURL = url
    }
}
