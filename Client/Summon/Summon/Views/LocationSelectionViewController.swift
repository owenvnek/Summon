//
//  LocationSelectionViewController.swift
//  Summon
//
//  Created by Owen Vnek on 1/8/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class LocationSelectionViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var map_view: MKMapView!
    let locationManager = CLLocationManager()
    private var search_controller: UISearchController?
    var selectedPin:MKPlacemark? = nil
    private var create_summon_view_controller: CreateSummonViewController!
    @IBOutlet weak var submit_button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map_view.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "location_search_table") as! LocationSearchTable
        search_controller = UISearchController(searchResultsController: locationSearchTable)
        search_controller?.searchResultsUpdater = locationSearchTable
        let searchBar = search_controller!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        //navigationItem.titleView = search_controller?.searchBar
        view.addSubview(searchBar)
        let constraints = [
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            searchBar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
            //searchBar.bottomAnchor.constraint(equalTo: map_view.topAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        search_controller?.hidesNavigationBarDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = map_view
        locationSearchTable.handleMapSearchDelegate = self
        map_view.isScrollEnabled = false
        navigationItem.searchController = search_controller
        submit_button.titleLabel!.font = UIFont(name: SummonUserContext.bold_font_name, size: submit_button.titleLabel!.font!.pointSize)
    }
    
    func set(create_summon_view_controller: CreateSummonViewController) {
        self.create_summon_view_controller = create_summon_view_controller
    }
    
    @IBAction func submit_button_pressed(_ sender: Any) {
        if selectedPin != nil {
            let location = Location(name: selectedPin!.name, placemark: selectedPin!)
            create_summon_view_controller.set(location: location)
        }
        navigationController?.popViewController(animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            map_view.setRegion(region, animated: true)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: (error)")
    }
    
}

extension LocationSelectionViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        map_view.removeAnnotations(map_view.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality, let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        map_view.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        map_view.setRegion(region, animated: true)
    }
}

extension LocationSelectionViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), for: .normal)
        button.addTarget(self, action: #selector(pin_button_pressed), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
    
    @objc func pin_button_pressed() {
        
    }
    
}
