//
//  ConstantsManager.swift
//  FormFarm
//
//  Created by a1 on 22.01.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation

enum StoryboardNames: String {
    case main = "Main"
    case login = "Login"
}

enum IdentifierVC: String {
    case loginNavVC = "loginNVC"
    case login = "login"
    case mainNavVC = "mainNVC"
    case main = "main"
    case tabBarVC = "tabBarVC"
    case qrCodeVC = "qrCodeVC"
    case qrCodeDetailsVC = "qrCodeDetailsVC"
    case popoverLogout = "popoverLogoutVC"
    case popoverSignature = "popoverSignatureVC"
}

enum IdentifierCells: String {
    case mainCell = "mainCell"
    case qrCodeTitleCell = "qrCodeTitleCell"
    case qrCodeCompCell = "qrCodeCompCell"
    case qrCodeInfoCell = "qrCodeInfoCell"
    case qrCodeSendCell = "qrCodeSendCell"
}

enum IdentifierSegue: String {
    case showEditForm = "showEditForm"
    case locationSegue = "location"
}

enum ImageNames: String {
    case documentsTitleLogo = "doc_logo"
    case logoutIcon = "logout_icon"
    case emptyField = "empty_field"
    case formBackBtn = "form_btn_back"
    case trashBtn = "trash_btn"
    case selectMultiChecked = "form_select_checked"
    case selectMultiUnchecked = "form_select_unchecked"
    case docIconActive = "doc_icon_active"
    case qrCodeActive = "qr_code_active"
    case docIcon = "doc_icon"
    case qrCode = "qr_code"
    case plusIcon = "plus_icon"
}

enum FontName: String {
    case montserratMedium = "Montserrat-Medium"
    case montserratRegular = "Montserrat-Regular"
}

enum QRCodeTitle: String {
    case companyName = "Company name"
    case ppid = "Porto Potty ID"
    case location = "Location"
}

enum NotificationKeys: String {
    case documentWasSentKey = "document_was_sent"
}

enum DefaultColors: String {
    case mainGray = "main_gray"
}
