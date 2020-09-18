//
//  QRCodeDetailsVC+QRReaderExt.swift
//  FormFarm
//
//  Created by Maria on 20.09.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import QRCodeReader

extension QRCodeDetailsVC: QRCodeReaderViewControllerDelegate {
    
    func checkScanPermissions() -> Bool {
        do {
            return try QRCodeReader.supportsMetadataObjectTypes()
        } catch let error as NSError {
            let alert: UIAlertController
            switch error.code {
            case -11852:
                alert = UIAlertController(title: "Error", message: "This app is not authorized to use Back Camera", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
                    DispatchQueue.main.async {
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            default:
                alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            }
            present(alert, animated: true, completion: nil)
            return false
        }
    }
    
    func scanQRcode() {
        guard checkScanPermissions() else { return }
        readerVC.modalPresentationStyle = .formSheet
        readerVC.delegate = self
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            if let result = result {
                print("Completion with result: \(result.value) of type \(result.metadataType)")
            }
        }
        present(readerVC, animated: true, completion: nil)
    }
    
    // MARK: - QRCodeReader Delegate Methods
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        sendCodedQR(with: result.value)
        dismiss(animated: true, completion: nil)
    }
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        print("Switching capturing to: \(newCaptureDevice.device.localizedName)")
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        info = []
        dismiss(animated: true, completion: nil)
    }
    
    func sendCodedQR(with string: String) {
        let spinner = displaySpinner(onView: view)
        LibraryAPI.sharedInstance().postCodedQRString(codedString: string, success: { document in
            
            LibraryAPI.sharedInstance().duplicateFormInServer(for: document, success: { duplicate in
                self.removeSpinner(spinner: spinner)
                self.tableView.reloadData()
                let efVC = EditFormVC()
                efVC.startDocumentTitle = duplicate.name
                efVC.selectDocument = duplicate
                self.navigationController?.pushViewController(efVC, animated: true)
                self.showSuccessAlert(message: "QR code scanned successfully")
            }) { error in
                print(error)
                print("There was an error duplicating the document")
            }
        }, failure: { error in
            self.removeSpinner(spinner: spinner)
            self.showErrorAlert(message: error)
        })
    }
}
