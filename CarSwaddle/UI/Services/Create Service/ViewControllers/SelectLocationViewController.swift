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
            updateMapWithCurrentLocation()
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
        mapView.delegate = self
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
            locationManager.currentLocationPlacemark { [weak self] placemark, error in
                DispatchQueue.main.async {
                    if let placemark = placemark {
                        self?.setLocation(with: placemark)
                    }
                }
            }
        } else {
            updateMapWithCurrentLocation()
        }
    }
    
    private func updateMapWithCurrentLocation() {
        guard let location = location else { return }
        mapView?.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1200, longitudinalMeters: 1200)
        mapView?.setCenter(location.coordinate, animated: true)
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
        setLocation(with: center)
        
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
    
    private func setLocation(with placemark: CLPlacemark) {
        guard let coordinate = placemark.location?.coordinate else { return }
        self.setLocation(with: coordinate)
    }
    
    private func setLocation(with placemark: MKUserLocation) {
        guard let coordinate = placemark.location?.coordinate else { return }
        self.setLocation(with: coordinate)
    }
    
    private func setLocation(with coordinate: CLLocationCoordinate2D) {
        if location == nil {
            location = Location(context: store.mainContext, autoService: autoService, coordinate: coordinate)
        }
        location?.latitude = coordinate.latitude
        location?.longitude = coordinate.longitude
        store.mainContext.persist()
    }
    
    private var didUpdateCurrentUserLocation: Bool = false
    
}

extension SelectLocationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        guard didUpdateCurrentUserLocation == false && location == nil else { return }
//        didUpdateCurrentUserLocation = true
//        DispatchQueue.main.async { [weak self] in
//            guard let _self = self else { return }
//            _self.setLocation(with: userLocation)
//            if _self.location == nil {
//                _self.location = Location(context: store.mainContext, autoService: _self.autoService, coordinate: coordinate)
//            }
//            _self.location?.latitude = coordinate.latitude
//            _self.location?.longitude = coordinate.longitude
//            store.mainContext.persist()
//        }
    }
    
}
