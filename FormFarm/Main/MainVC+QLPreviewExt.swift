//
//  MainVC+QLPreviewExt.swift
//  FormFarm
//
//  Created by a1 on 25.01.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import QuickLook

extension MainVC: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return startItems[index]
    }
    
    func showQLPreview(_ pdfPath: URL, _ title: String, _ spinner: UIView) {
        let qlController = QLPreviewController()
        qlController.dataSource = self
        let item = PreviewItemModel(pdfPath, title)
        startItems = [item]
        present(qlController, animated: false, completion: {
            UIApplication.shared.statusBarStyle = .default
            self.removeSpinner(spinner: spinner)
        })
    }
}
