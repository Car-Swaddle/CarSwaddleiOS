//
//  SelectLocationViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/23/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import MapKit
import Store
import CoreLocation
//import CarSwaddleUI

private let losAngeleseCoordinates = CLLocationCoordinate2D(latitude: 34.052235, longitude: -118.243683)
private let defaultCoordinates = losAngeleseCoordinates


protocol SelectLocationViewControllerDelegate: class {
    func didSelect(location: Location, viewController: SelectLocationViewController)
}

/// Start with position set or current location
/// Let the user pan around with the location/pin set to the center of the screen
///
final class SelectLocationViewController: UIViewController, StoryboardInstantiating {
    
    static func create(delegate: SelectLocationViewControllerDelegate, autoService: AutoService, location: Location?) -> SelectLocationViewController {
        let viewController = SelectLocationViewController.viewControllerFromStoryboard()
        viewController.autoService = autoService
        viewController.location = location
        viewController.delegate = delegate
//        viewController.updateLocation()
        return viewController
    }
    
    weak var delegate: SelectLocationViewControllerDelegate?
    
    private var location: Location? {
        didSet {
            updateMap()
        }
    }
    
    private var autoService: AutoService!
    
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var confirmButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.promptUserForLocationAccess()
        setupLocation()
        styleView()
        setupBarButtons()
    }
    
    private var prev: NSLayoutConstraint? {
        didSet {
            if let prev = prev {
                centerView.removeConstraint(prev)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        styleView()
        let theView: UIView = self.view
        let constant = ((theView.frame.height+(theView.safeAreaInsets.top/2))/2) - (centerView.frame.height/2)
        
        prev = centerView.topAnchor.constraint(equalTo: theView.topAnchor, constant: constant)
        prev?.isActive = true
    }
    
    private func setupBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Title of cancel button"), style: .plain, target: self, action: #selector(SelectLocationViewController.didSelectCancel))
    }
    
    @objc private func didSelectCancel() {
//        if let location = location {
//            store.mainContext.delete(location)
//            store.mainContext.persist()
//        }
        navigationController?.popViewController(animated: true)
    }
    
    private func setupLocation() {
        if location == nil {
//            locationManager.currentLocation(cacheOptions: .networkOnly) { [weak self] location, error in
//                DispatchQueue.main.async {
//                    guard let _self = self, let coordinate = location?.coordinate else { return }
//                    self?.location = Location(context: store.mainContext, autoService: _self.autoService, coordinate: coordinate)
//                    store.mainContext.persist()
//                }
//            }
        } else {
            updateMap()
        }
    }
    
    private func updateMap() {
        guard let location = location else { return }
        mapView?.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1200, longitudinalMeters: 1200)
        mapView?.setCenter(location.coordinate, animated: true)
//        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1200, longitudinalMeters: 1200)
//        mapView?.setRegion(region, animated: true)
//        let rect = MKMapRect(x: 0, y: 0, width: Double(view.frame.width), height: Double(view.frame.height))
//        mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: view.safeAreaInsets.top, left: 0, bottom: view.safeAreaInsets.bottom, right: 0), animated: false)
    }
    
    private func styleView() {
        confirmButton.layer.borderColor = UIColor.gray.cgColor
        confirmButton.layer.borderWidth = 1/UIScreen.main.scale
        confirmButton.layer.cornerRadius = confirmButton.frame.height/2
    }
    
    @IBOutlet private weak var centerView: UIView!
    
    @IBAction private func didSelectConfirm() {
        guard let location = location else { return }
        let center = mapView.centerCoordinate
        location.latitude = center.latitude
        location.longitude = center.longitude
        store.mainContext.persist()
        
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = center
//        annotation.title = "Point center"
//
//        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "hi")
//        view.addSubview(annotationView)
//        view.addAnnotation(annotation)
        
        delegate?.didSelect(location: location, viewController: self)
    }
    
    private func updateLocation() {
//        guard location == nil else { return }
//        let newLocation = Location(context: store.mainContext)
//        newLocation.autoService = self.autoService
//        newLocation.latitude = defaultCoordinates.latitude
//        newLocation.longitude = defaultCoordinates.longitude
//        self.location = newLocation
    }
    
    private var didUpdateCurrentUserLocation: Bool = false
    
}

extension SelectLocationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("user location")
        guard didUpdateCurrentUserLocation == false && location == nil else { return }
        didUpdateCurrentUserLocation = true
        DispatchQueue.main.async { [weak self] in
            guard let _self = self, let coordinate = userLocation.location?.coordinate else { return }
            
            if _self.location == nil {
                _self.location = Location(context: store.mainContext, autoService: _self.autoService, coordinate: coordinate)
            }
            _self.location?.latitude = coordinate.latitude
            _self.location?.longitude = coordinate.longitude
            store.mainContext.persist()
        }
    }
    
}
