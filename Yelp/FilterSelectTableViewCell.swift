//
//  FilterSelectTableViewCell.swift
//  Yelp
//
//  Created by Jonathan Cheng on 10/24/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

//protocol FilterSelectCellDelegate: class {
//    func filterSelectCellDidSelect(cell: FilterSelectTableViewCell)
//}

class FilterSelectTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    var prefRowIdentifier: PrefRowIdentifier = .Deals
    var row = -1
    
}
