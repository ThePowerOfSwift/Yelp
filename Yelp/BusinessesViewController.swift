//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate, FilterViewControllerDelegate {
    
    var businesses: [Business]!
    var searchBar: UISearchBar!
    var loadingMoreView : InfiniteScrollActivityView!
    var isFetchingData = false
    var filterSettings = FilterSettings()
    
    // Map variables
    var isMapShowing = false
    
    @IBOutlet var businessTableView: UITableView!
    @IBOutlet weak var mapButton: UIBarButtonItem!
    @IBOutlet var mapView: MKMapView!
    
// MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        businessTableView.dataSource = self
        businessTableView.delegate = self
        businessTableView.estimatedRowHeight = 120
        businessTableView.rowHeight = UITableViewAutomaticDimension
        
        // Set up Infinite Scroll loading indicator
        loadingMoreView = InfiniteScrollActivityView(for: businessTableView)

        // Setup search bar
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        
        // Map
        let centerLocation = CLLocation(latitude: 37.7833, longitude: -122.4167)
        goToLocation(location: centerLocation)
        
        doSearch(with: searchBar.text!, offset: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? FilterViewController {
            destinationVC.currentFilter = filterSettings
            destinationVC.delegate = self
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        businessTableView.contentInset.top = topLayoutGuide.length
    }
    
// MARK: TableView methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
    }

// MARK: Search Bar Methods

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBarSearchButtonClicked(searchBar)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        doSearch(with: searchBar.text!, offset: 0)
    }
    
// MARK: ScrollView Delegate Methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isFetchingData) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollOffsetThreshold = businessTableView.contentSize.height - businessTableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && businessTableView.isDragging) {
                // Calculate the last fetched result and fetch next batch
                doSearch(with: searchBar.text!, offset: businesses.count)
            }
        }
    }
    
// MARK: Controller
    
    func doSearch(with searchTerm: String, offset: Int) {
        isFetchingData = true
        let frame = CGRect(x: 0, y: businessTableView.contentSize.height, width: businessTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView?.frame = frame
        loadingMoreView!.startAnimating()
        
        // Get filter settings
        let deals = filterSettings.deals
        var categories = [String]()
        for aCategory in filterSettings.categories {
            if Bool(aCategory["value"]!)! {
                categories.append(aCategory["code"]!)
            }
        }
        var radius = 0
        for aDistance in filterSettings.distance {
            if Bool(aDistance["value"]!)! {
                radius = Int(aDistance["code"]!)!
            }
        }
        
        Business.searchWithTerm(term: searchTerm, offset: offset, radius: radius, sort: filterSettings.sort(), categories: categories, deals: deals, completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            // If starting from 0 reset model
            if offset == 0 {
                self.businesses = nil
            }
            
            if let businesses = businesses {
                if self.businesses == nil {
                    self.businesses = businesses
                }
                else {
                    self.businesses.append(contentsOf: businesses)
                }
                
            }
            self.isFetchingData = false
            self.loadingMoreView?.stopAnimating()
            self.businessTableView.reloadData()
            
            // Place pins on Map
            self.populateMapView()
            }
        )
        
        /* Example of Yelp search with more search options specified
         Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
         self.businesses = businesses
         
         for business in businesses {
         print(business.name!)
         print(business.address!)
         }
         }
         */
    }
    
// MARK: FilterViewController Delegate methods
    
    func updateFilterSettings(with newFilter: FilterSettings) {
        filterSettings = newFilter
        doSearch(with: searchBar.text!, offset: 0)
        
    }
    
// MARK: Map methods
    func populateMapView() {
        for business in businesses {
            if business.location2D != nil {
                self.addAnnotationAtCoordinate(coordinate: business.location2D!, named:business.name!)
            }
        }
    }

    @IBAction func mapButtonTapped(_ sender: UIBarButtonItem) {
        let toView = isMapShowing ? businessTableView : mapView
        let fromView = isMapShowing ? mapView : businessTableView
        
        
        UIView.transition(from: fromView, to: toView, duration: 0.5, options: [UIViewAnimationOptions.transitionFlipFromLeft, UIViewAnimationOptions.showHideTransitionViews]) { (Bool) in            
        }
        self.isMapShowing = !self.isMapShowing
        self.mapButton.title = self.isMapShowing ? "List" : "Map"

    }
    
    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
    // add an Annotation with a coordinate: CLLocationCoordinate2D
    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D, named:String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = named
        mapView.addAnnotation(annotation)
    }
}
