//
//  CalculationVC+CalculationItems.swift
//  FormFarm
//
//  Created by Studio Guatemala on 1/29/20.
//  Copyright © 2020 fruktorum. All rights reserved.
//

import UIKit

extension CalculationVC: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalculationItemCell") as! CalculationItemCell
        let item = data.items[indexPath.row]
        cell.set(item: item)
        return cell
    }
}
