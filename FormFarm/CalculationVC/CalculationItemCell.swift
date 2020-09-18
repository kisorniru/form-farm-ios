//
//  CalculationItemCell.swift
//  FormFarm
//
//  Created by Studio Guatemala on 1/29/20.
//  Copyright © 2020 fruktorum. All rights reserved.
//

import UIKit

class CalculationItemCell: UITableViewCell {

    var descriptionLabel = UILabel()
    var infoLabel = UILabel()
    var totalLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubview(descriptionLabel)
        addSubview(infoLabel)
        addSubview(totalLabel)
        
        configureDescriptionLabel()
        configureTotalLabel()
        configureInfoLabel()
        
        setDescriptionLabelConstraints()
        setTotalLabelConstraints()
        setInfoLabelConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(item: CalculationItem) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let quantity = formatter.string(from: item.quantity! as NSNumber)!
        let price = formatter.string(from: item.price! as NSNumber)!
        let total = formatter.string(from: item.total! as NSNumber)!

        descriptionLabel.text = item.description
        infoLabel.text = "\(quantity) * $\(price)"
        totalLabel.text = "$\(total)"
    }
    
    func configureDescriptionLabel() {
        descriptionLabel.numberOfLines = 2
        descriptionLabel.adjustsFontSizeToFitWidth = true
        infoLabel.font = UIFont(name: FontName.montserratMedium.rawValue, size: 12.0)
    }
    
    func configureInfoLabel() {
        infoLabel.numberOfLines = 0
        infoLabel.font = UIFont(name: FontName.montserratMedium.rawValue, size: 11.0)
    }
    
    func configureTotalLabel() {
        totalLabel.numberOfLines = 0
        totalLabel.font = UIFont(name: FontName.montserratMedium.rawValue, size: 16.0)
        totalLabel.textAlignment = .right
    }
    
    func setDescriptionLabelConstraints() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        descriptionLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 4/6).isActive = true
    }
    
    func setInfoLabelConstraints() {
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        infoLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 6).isActive = true
        infoLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 4/6).isActive = true
    }

    func setTotalLabelConstraints() {
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        totalLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        totalLabel.leadingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor, constant: 12).isActive = true
        totalLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
        totalLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: (2/6)).isActive = true
    }
}
