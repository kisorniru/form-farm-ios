//
//  EditFormVC+Signature.swift
//  FormFarm
//
//  Created by a1 on 13.02.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import Eureka
import EPSignature

protocol SignatureProtocol {
    func createSignatureBtn(for line: FormModel) -> Section
}

extension EditFormVC: SignatureProtocol, UIPopoverPresentationControllerDelegate {
    
    func createSignatureBtn(for line: FormModel) -> Section {
        return Section(line.name) <<< ButtonRow(line.slug) { row in
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
    
    func initSignRow(with row: ButtonRow, on line: FormModel) {
        row.title = "Tap to add/delete/edit signature"
        if let answerImage = line.answerImage {
            guard let popoverSignVC = UIStoryboard(name: StoryboardNames.main.rawValue, bundle: nil).instantiateViewController(withIdentifier: IdentifierVC.popoverSignature.rawValue) as? PopoverSignatureVC else { return }
            popoverSignVC.line = line
            popoverSignVC.preferredContentSize = CGSize(width: 250, height: 200)
            popoverSignVC.modalPresentationStyle = UIModalPresentationStyle.popover
            popoverSignVC.signatureImg = UIImage(data: answerImage)
            popoversSign[line.slug] = popoverSignVC
        }
    }
    
    func configCellSelection(for cell: ButtonCellOf<String>, on line: FormModel, with signVariable: String) {
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
    
    func createNewPopoverSignatureVC(for line: FormModel) {
        if let popoverSignVC = UIStoryboard(name: StoryboardNames.main.rawValue, bundle: nil).instantiateViewController(withIdentifier: IdentifierVC.popoverSignature.rawValue) as? PopoverSignatureVC {
            popoverSignVC.line = line
            popoversSign[line.slug] = popoverSignVC
            showSignatureView(for: line.slug)
        }
    }
    
    func epSignature(_: EPSignatureViewController, didCancel error: NSError) {
        print("User tap CANCEL sign")
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        self.navigationController?.popViewController(animated: true)
    }
    
    func epSignature(_ epSignatureVC: EPSignatureViewController, didSign signatureImage: UIImage, boundingRect: CGRect) {
        print("User tap DONE sign")
        guard let variable = epSignatureVC.variableSign else { return }
        if let signLines = forms?.filter({ $0.slug == variable }), let signLine = signLines.first {
            updateSignatureInDB(for: signLine, with: signatureImage.pngData())
        }
        if let popoverSignVC = popoversSign[variable] {
            popoverSignVC.signatureImg = signatureImage
            popoverSignVC.signaturesForServer[variable] = signatureImage
            popoversSign[variable] = popoverSignVC
            emptyImageView.removeFromSuperview()
        }
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        self.navigationController?.popViewController(animated: true)
    }
    
    func updateSignatureInDB(for line: FormModel, with imageData: Data?) {
        try! realm.write {
            line.answerImage = imageData
        }
    }
}
