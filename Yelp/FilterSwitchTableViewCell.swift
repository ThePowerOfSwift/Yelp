//
//  FilterSwitchTableViewCell.swift
//  Yelp
//
//  Created by Jonathan Cheng on 10/24/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

protocol FilterSwitchCellDelegate: class {
    func filterSwitchCellDidToggle(cell: FilterSwitchTableViewCell, to newValue: Bool)
}

class FilterSwitchTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var onSwitch: UISwitch!

    weak var delegate: FilterSwitchCellDelegate?
    var prefRowIdentifier: PrefRowIdentifier = .Deals
    var row = -1
    
    @IBAction func didToggleSwitch(_ sender: UISwitch, forEvent event: UIEvent) {
        delegate?.filterSwitchCellDidToggle(cell: self, to: sender.isOn)
    }
}
