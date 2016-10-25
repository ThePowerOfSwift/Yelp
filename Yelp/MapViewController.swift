//
//  MapViewController.swift
//  Yelp
//
//  Created by Jonathan Cheng on 10/25/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager : CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Set up location manager
//        locationManager = CLLocationManager()
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//        locationManager.distanceFilter = 200
//        locationManager.requestWhenInUseAuthorization()
        
        // set the region to display, this also sets a correct zoom level
        // set starting center location in San Francisco
        let centerLocation = CLLocation(latitude: 37.7833, longitude: -122.4167)
        goToLocation(location: centerLocation)
        
        
        // draw circular overlay centered in San Francisco
        let coordinate = CLLocationCoordinate2D(latitude: 37.7833, longitude: -122.4167)
//        let circleOverlay: MKCircle = MKCircle(center: coordinate, radius: 1000)
//        mapView.add(circleOverlay)
        
        addAnnotationAtCoordinate(coordinate: coordinate)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
//MARK: Location manager authorization delegate methods
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.1, 0.1)
            let region = MKCoordinateRegionMake(location.coordinate, span)
            mapView.setRegion(region, animated: false)
        }
    }
    
//MARK: Annotation methods

    // add an Annotation with a coordinate: CLLocationCoordinate2D
    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "An annotation!"
        mapView.addAnnotation(annotation)
    }
    
    // add an annotation with an address: String
    func addAnnotationAtAddress(address: String, title: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count != 0 {
                    let coordinate = placemarks.first!.location!
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate.coordinate
                    annotation.title = title
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    
    // Annotation with custom views
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "customAnnotationView"
        
        // custom image annotation
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if (annotationView == nil) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        else {
            annotationView!.annotation = annotation
        }
        annotationView!.image = UIImage(named: "customAnnotationImage")
        
        return annotationView
    }
    
/*
     // Annotation with custom pins
     func mapView(_ mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKPinAnnotationView? {
         let identifier = "customAnnotationView"
        
        // custom pin annotation
         var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
         if (annotationView == nil) {
         annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
         }
         else {
         annotationView!.annotation = annotation
         }
         annotationView!.pinTintColor = UIColor.green
        
         return annotationView
     }
 */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleView = MKCircleRenderer(overlay: overlay)
        circleView.strokeColor = UIColor.red
        circleView.lineWidth = 1
        return circleView
    }
}
