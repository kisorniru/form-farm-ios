//
//  EditFormVC+QLPreview.swift
//  FormFarm
//
//  Created by a1 on 26.01.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import QuickLook

extension EditFormVC: QLPreviewControllerDataSource {

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return finalItems[index]
    }
    
    func showQLPreview(_ pdfPath: URL, _ title: String, _ spinner: UIView) {
        DispatchQueue.main.async { // Correct
            let qlController = QLPreviewController()
            qlController.dataSource = self
            let item = PreviewItemModel(pdfPath, title)
            self.finalItems = [item]
            self.present(qlController, animated: false, completion: {
                UIApplication.shared.statusBarStyle = .default
                self.removeSpinner(spinner: spinner)
            })
        }
    }
}
