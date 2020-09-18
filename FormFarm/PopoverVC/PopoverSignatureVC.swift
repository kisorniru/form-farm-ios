//
//  PopoverSignatureVC.swift
//  FormFarm
//
//  Created by a1 on 12.02.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import UIKit
import EPSignature
import Realm
import RealmSwift

class PopoverSignatureVC: UIViewController {

    @IBOutlet weak var signImageView: UIImageView!
    
    var signatureImg: UIImage?
    var signaturesForServer = [String: UIImage]()
    var line: FormModel?
    var infoLine: InfoModel?
    let realm = try! Realm()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signImageView.image = signatureImg
    }

    @IBAction func deleteActionBtn(_ sender: Any) {
        signImageView.image = nil
        signatureImg = nil
        if let line = line {
            signaturesForServer.removeValue(forKey: line.slug)
            try! realm.write {
                line.answerImage = nil
            }
        } else if let infoLine = infoLine {
            signaturesForServer.removeValue(forKey: infoLine.variable)
            try! realm.write {
                infoLine.answerImage = nil
            }
        }
        presentingViewController!.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func editActionBtn(_ sender: Any) {
        if let line = line {
            showSignatureView(for: line.slug)
        } else if let infoLine = infoLine {
            showSignatureView(for: infoLine.variable)
        }
    }
    
    func epSignature(_: EPSignatureViewController, didCancel error: NSError) {
        print("User tap CANCEL sign FROM POPOVER")
    }
    
    func epSignature(_: EPSignatureViewController, didSign signatureImage: UIImage, boundingRect: CGRect) {
        print("User tap DONE sign FROM POPOVER")
        
        if let line = line {
            try! realm.write {
                line.answerImage = signatureImage.pngData()
            }
        } else if let infoLine = infoLine {
            try! realm.write {
                infoLine.answerImage = signatureImage.pngData()
            }
        }
        signatureImg = signatureImage
        presentingViewController!.dismiss(animated: false, completion: nil)
    }
    
}
