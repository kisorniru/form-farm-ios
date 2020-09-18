//
//  QRCodeDetailsVC+Signature.swift
//  FormFarm
//
//  Created by Maria on 21.09.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import Eureka
import EPSignature

protocol QRSignatureProtocol {
    func createSignatureBtn(for line: InfoModel) -> Section
}

extension QRCodeDetailsVC: QRSignatureProtocol, UIPopoverPresentationControllerDelegate {
    
    func createSignatureBtn(for line: InfoModel) -> Section {
        return Section(line.details) <<< ButtonRow(line.variable) { row in
            row.cellStyle = .value1
            self.initSignRow(with: row, on: line)
        }.onCellSelection { cell, row in
            for view in row.baseCell.subviews {
                if let emptyView = view as? UIImageView {
                    self.emptyImageView = emptyView
                }
            }
            guard let signVariable = row.tag else { return }
            self.configCellSelection(for: cell, on: line, with: signVariable)
        }
    }
    
    func initSignRow(with row: ButtonRow, on line: InfoModel) {
        row.title = "Tap to add/delete/edit signature"
        if let answerImage = line.answerImage {
            guard let popoverSignVC = UIStoryboard(name: StoryboardNames.main.rawValue, bundle: nil).instantiateViewController(withIdentifier: IdentifierVC.popoverSignature.rawValue) as? PopoverSignatureVC else { return }
            popoverSignVC.infoLine = line
            popoverSignVC.line = nil
            popoverSignVC.preferredContentSize = CGSize(width: 250, height: 200)
            popoverSignVC.modalPresentationStyle = UIModalPresentationStyle.popover
            popoverSignVC.signatureImg = UIImage(data: answerImage)
            popoversSign[line.variable] = popoverSignVC
        }
    }
    
    func configCellSelection(for cell: ButtonCellOf<String>, on line: InfoModel, with signVariable: String) {
        if let popoverSignVC = popoversSign[signVariable] {
            //if sign was create
            if popoverSignVC.signatureImg != nil {
                popoverSignVC.preferredContentSize = CGSize(width: 250, height: 200)
                popoverSignVC.modalPresentationStyle = UIModalPresentationStyle.popover
                guard let popover = popoverSignVC.popoverPresentationController else { return }
                popover.delegate = self
                popover.sourceView = cell.contentView
                popover.sourceRect = (popover.sourceView?.bounds)!
                present(popoverSignVC, animated: true, completion: nil)
            } else {
                //if delete sign
                popoversSign.removeValue(forKey: signVariable)
                createNewPopoverSignatureVC(for: line)
            }
        } else {
            //if not sign
            createNewPopoverSignatureVC(for: line)
        }
    }
    
    func createNewPopoverSignatureVC(for line: InfoModel) {
        if let popoverSignVC = UIStoryboard(name: StoryboardNames.main.rawValue, bundle: nil).instantiateViewController(withIdentifier: IdentifierVC.popoverSignature.rawValue) as? PopoverSignatureVC {
            popoverSignVC.infoLine = line
            popoverSignVC.line = nil
            popoversSign[line.variable] = popoverSignVC
            showSignatureView(for: line.variable)
        }
    }
    
    func epSignature(_: EPSignatureViewController, didCancel error: NSError) {
        print("User tap CANCEL sign")
    }
    
    func epSignature(_ epSignatureVC: EPSignatureViewController, didSign signatureImage: UIImage, boundingRect: CGRect) {
        print("User tap DONE sign")
        guard let variable = epSignatureVC.variableSign else { return }
        if let signLines = info?.filter({ $0.variable == variable }), let signLine = signLines.first {
            updateSignatureInDB(for: signLine, with: signatureImage.pngData())
        }
        if let popoverSignVC = popoversSign[variable] {
            popoverSignVC.signatureImg = signatureImage
            popoverSignVC.signaturesForServer[variable] = signatureImage
            popoversSign[variable] = popoverSignVC
            emptyImageView.removeFromSuperview()
        }
    }
    
    func updateSignatureInDB(for line: InfoModel, with imageData: Data?) {
        try! realm.write {
            line.answerImage = imageData
        }
    }
}
