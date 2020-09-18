//
//  MainCell.swift
//  FormFarm
//
//  Created by a1 on 23.01.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import UIKit
import QuickLook

class MainCell: UITableViewCell {
    
    @IBOutlet weak var titleDocument: UILabel!
    @IBOutlet weak var dataUpdateDocument: UILabel!
    @IBOutlet weak var trashView: UIView!
    
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var widthFirstSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthSecSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthThirdSpaceConstraint: NSLayoutConstraint!
    
    var numberCell: Int?
    var currentDocument: DocumentModel?
}


