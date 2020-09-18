//
//  PreviewItemModel.swift
//  FormFarm
//
//  Created by a1 on 25.01.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import QuickLook

class PreviewItemModel: NSObject, QLPreviewItem {
    
    let previewItemURL: URL?
    let previewItemTitle: String?
    
    init(_ previewItemURL: URL?, _ previewItemTitle: String?) {
        self.previewItemURL = previewItemURL
        self.previewItemTitle = previewItemTitle
    }
}
