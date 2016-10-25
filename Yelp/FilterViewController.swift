//
//  FilterViewController.swift
//  Yelp
//
//  Created by Jonathan Cheng on 10/23/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

enum PrefRowIdentifier: String {
    case Deals = "Offering a Deal"
    case Distance = "Distance"
    case SortBy = "Sort By"
    case Category = "Category"
}

protocol FilterViewControllerDelegate: class {
    func updateFilterSettings(with newFilter:FilterSettings)
}

class FilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FilterSwitchCellDelegate {

    @IBOutlet weak var filterTableView: UITableView!
    weak var delegate : FilterViewControllerDelegate?
    
    let tableSectionTitles = [" ", "Distance", "Sort By", "Category"]
    let tableStructure: [PrefRowIdentifier] = [.Deals, .Distance, .SortBy, .Category]
    var filterValues: [PrefRowIdentifier: Bool] = [:]
    var categoryFilterValues: [[String: String]] = [[:]]
    var distanceFilterValues: [[String: String]] = [[:]]
    var sortbyFilterValues: [[String: String]] = [[:]]

    var isShowingDistance = false
    var isShowingSortBy = false
    var isShowingCategories = false
    let rowHiddenAfterIndex = 5
    var showMoreIndexPath : IndexPath = IndexPath(row: 0, section: 0)
    
    // Should be (pre)set by presenting VC
    var currentFilter: FilterSettings! {
        didSet {
            // Deals
            filterValues[.Deals] = currentFilter.deals
            
            // Categories
            categoryFilterValues = currentFilter.categories
            distanceFilterValues = currentFilter.distance
            sortbyFilterValues = currentFilter.sortby
            
            filterTableView?.reloadData()
        }
    }

    func filterSettingsFromTableData() -> FilterSettings {
        let settings = FilterSettings()
        
        // Deal
        settings.deals = filterValues[.Deals] ?? settings.deals
        
        // Categories
        settings.categories = categoryFilterValues
        
        // Distance
        settings.distance = distanceFilterValues
        
        // Sort By
        settings.sortby = sortbyFilterValues
        
        return settings
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        filterTableView.dataSource = self
        filterTableView.delegate = self
        
        currentFilter = currentFilter ?? FilterSettings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true) {
        }
    }
    
    @IBAction func searchButtonTapped(_ sender: UIBarButtonItem) {
        delegate?.updateFilterSettings(with: filterSettingsFromTableData())
        dismiss(animated: true) {
        }
    }

    
    // MARK: TableView Methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let prefRowIdentifier = tableStructure[indexPath.section]

        switch prefRowIdentifier {
        case .Deals:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FilterSwitchCell", for: indexPath) as! FilterSwitchTableViewCell
            
            cell.titleLabel.text = prefRowIdentifier.rawValue
            cell.onSwitch.setOn(filterValues[prefRowIdentifier]!, animated: true)
            cell.delegate = self
            cell.prefRowIdentifier = prefRowIdentifier
            cell.row = indexPath.row
            
            return cell
        case .Category:
            // Return a "show more" cell
            if !isShowingCategories && indexPath.row > rowHiddenAfterIndex-1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ShowMoreCell", for: indexPath) 
                cell.textLabel?.text = "Show more categories..."
                cell.textLabel?.textColor = UIColor.gray
                showMoreIndexPath = indexPath
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FilterSwitchCell", for: indexPath) as! FilterSwitchTableViewCell
                cell.titleLabel.text = categoryFilterValues[indexPath.row]["name"]!
                cell.onSwitch.setOn(Bool(categoryFilterValues[indexPath.row]["value"]!)!, animated: true)
                cell.delegate = self
                cell.prefRowIdentifier = prefRowIdentifier
                cell.row = indexPath.row
                
                return cell
            }
        case .SortBy:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FilterSelectCell", for: indexPath) as! FilterSelectTableViewCell
            
            var selectedIndex = indexPath.row
            // Determine if all options are showing or just currently selected option
            // Find the index of the currently selected option if only showing selected option
            if !isShowingSortBy {
                for index in 0..<sortbyFilterValues.count {
                    if Bool(sortbyFilterValues[index]["value"]!)! {
                        selectedIndex = index
                    }
                }
            }
            // Otherwise just proceed and show the row according to indexPath.row
            cell.titleLabel.text = sortbyFilterValues[selectedIndex]["name"]
            cell.accessoryType = Bool(sortbyFilterValues[selectedIndex]["value"]!)! ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
            cell.prefRowIdentifier = prefRowIdentifier
            cell.row = indexPath.row
            
            return cell
        case .Distance:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FilterSelectCell", for: indexPath) as! FilterSelectTableViewCell
            var selectedIndex = indexPath.row
            if !isShowingDistance {
                for index in 0..<distanceFilterValues.count {
                    if Bool(distanceFilterValues[index]["value"]!)! {
                        selectedIndex = index
                    }
                }
            }
            cell.titleLabel.text = distanceFilterValues[selectedIndex]["name"]
            cell.accessoryType = Bool(distanceFilterValues[selectedIndex]["value"]!)! ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
            cell.prefRowIdentifier = prefRowIdentifier
            cell.row = indexPath.row
            
            return cell
        }        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableStructure.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableSectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableStructure[section] {
        case .Deals:
            return 1
        case .Category:
            return isShowingCategories ? categoryFilterValues.count : (rowHiddenAfterIndex + 1)
        case .Distance:
            return isShowingDistance ? distanceFilterValues.count : 1
        case .SortBy:
            return isShowingSortBy ? sortbyFilterValues.count : 1
//        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch tableStructure[indexPath.section] {
        case .Distance:
            // Only select an option if all options are showing (i.e. selection mode)
            // Otherwise it's only displaying the prevailing option (and not in selection mode)
            if isShowingDistance {
                for i in 0..<distanceFilterValues.count {
                    distanceFilterValues[i]["value"] = "false"
                }
                distanceFilterValues[indexPath.row]["value"] = "true"
            }
            isShowingDistance = !isShowingDistance
        case .SortBy:
            // Only select an option if all options are showing (i.e. selection mode)
            // Otherwise it's only displaying the prevailing option (and not in selection mode)
            if isShowingSortBy {
                for i in 0..<sortbyFilterValues.count{
                    sortbyFilterValues[i]["value"] = "false"
                }
                sortbyFilterValues[indexPath.row]["value"] = "true"
            }
            isShowingSortBy = !isShowingSortBy
            
        default:
            //Check for the "Show more cell"
            if !isShowingCategories && indexPath == showMoreIndexPath {
                isShowingCategories = !isShowingCategories
            }
        }
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: UITableViewRowAnimation.fade)
    }
    
    func animatedReload(_ tableView: UITableView) {
        let range = NSMakeRange(0, tableView.numberOfSections)
        let sections = NSIndexSet(indexesIn: range)
        tableView.reloadSections(sections as IndexSet, with: .automatic)
    }
    
// MARK: Cell delegate methods
    
    func filterSwitchCellDidToggle(cell: FilterSwitchTableViewCell, to newValue: Bool) {
        switch cell.prefRowIdentifier {
        case .Deals:
            filterValues[cell.prefRowIdentifier] = newValue
        case .Category:
            categoryFilterValues[cell.row]["value"] = String(newValue)
        default: break
        }
    }
}
