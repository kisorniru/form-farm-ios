//
//  MainCellModel.swift
//  FormFarm
//
//  Created by a1 on 23.01.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import UIKit
import QuickLook

extension UITableView {
    
    func reusableCell(cellModel model: MainCellModel, for indexPath: IndexPath) -> MainCell {
        let cell = dequeueReusableCell(withIdentifier: IdentifierCells.mainCell.rawValue, for: indexPath) as! MainCell
        cell.numberCell = indexPath.row
        model.setup(cell: cell, for: indexPath, viewWidth: self.frame.size.width)
        return cell
    }
}

struct MainCellModel {
    
    let document: DocumentModel?
    
    func setup(cell: MainCell, for indexPath: IndexPath, viewWidth: CGFloat) {
        if viewWidth < 415 {
            cell.widthFirstSpaceConstraint.constant = 0
            cell.widthSecSpaceConstraint.constant = 0
            cell.widthThirdSpaceConstraint.constant = 0
        }
        
        if (document != nil) {
            cell.titleDocument.text = document?.name
            cell.dataUpdateDocument.text = document?.updated_at.dataWithoutTime()
        }
    }
}
