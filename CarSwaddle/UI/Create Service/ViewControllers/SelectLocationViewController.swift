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
import Contacts
import AddressBook
import CarSwaddleUI
import Firebase

private let losAngeleseCoordinates = CLLocationCoordinate2D(latitude: 34.052235, longitude: -118.243683)
private let defaultCoordinates = losAngeleseCoordinates

private let closeupSpanWidth: CLLocationDistance = 800
private let farSpanWidth: CLLocationDistance = 12000

protocol SelectLocationViewControllerDelegate: class {
    func didSelect(location: Location, viewController: SelectLocationViewController)
    func willBeDismissed(viewController: SelectLocationViewController)
}

/// Start with position set or current location
/// Let the user pan around with the location/pin set to the center of the screen
///
final class SelectLocationViewController: UIViewController, StoryboardInstantiating {
    
    static func create(delegate: SelectLocationViewControllerDelegate, autoService: AutoService) -> SelectLocationViewController {
        let viewController = SelectLocationViewController.viewControllerFromStoryboard()
        viewController.autoService = autoService
//        viewController.location = location
        viewController.delegate = delegate
//        viewController.updateLocation()
        return viewController
    }
    
    weak var delegate: SelectLocationViewControllerDelegate?
    
//    private var location: Location? {
//        didSet {
//            updateMapWithCurrentLocation()
//        }
//    }
    
    private var autoService: AutoService!
    
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var confirmButton: ActionButton!
    @IBOutlet private weak var centerView: UIImageView!
    
    private lazy var contentAdjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: nil, actionButton: confirmButton)
    private lazy var locationSearchResultsViewController = LocationSearchResultsViewController.viewControllerFromStoryboard()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        let placeholder = NSLocalizedString("Search Location", comment: "Placeholder text")
        searchBar.placeholder = placeholder
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.promptUserForLocationAccess()
        
        centerOnUserCurrentLocation()
        
        setupBarButtons()
        
        mapView.delegate = self
        
        centerView.layer.shadowOpacity = 0.45
        centerView.layer.shadowColor = UIColor.black.cgColor
        centerView.layer.shadowRadius = 4
        centerView.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        centerView.image = #imageLiteral(resourceName: "pin").withRenderingMode(.alwaysTemplate)
        
        contentAdjuster.positionActionButton()
        
        navigationItem.titleView = searchBar
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.view.setNeedsLayout()
        navigationController?.view.layoutIfNeeded()
    }
    
    private var prev: NSLayoutConstraint? {
        didSet {
//            if let prev = prev {
//                centerView.removeConstraint(prev)
//            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        styleView()
//        let theView: UIView = self.view
//        let constant = ((theView.frame.height+(theView.safeAreaInsets.top/2))/2) - (centerView.frame.height/2)
        
//        prev = centerView.topAnchor.constraint(equalTo: theView.topAnchor, constant: constant)
//        prev?.isActive = true
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            delegate?.willBeDismissed(viewController: self)
        }
    }
    
    private func setupBarButtons() {
        navigationItem.leftBarButtonItem = dismissBarButton
    }
    
    private var dismissBarButton: UIBarButtonItem {
        return UIBarButtonItem(title: NSLocalizedString("Dismiss", comment: "Title of cancel button"), style: .plain, target: self, action: #selector(SelectLocationViewController.didSelectCancel))
    }
    
    @objc private func didSelectCancel() {
//        if let location = location {
//            store.mainContext.delete(location)
//            store.mainContext.persist()
//        }
//        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    private func centerOnUserCurrentLocation() {
//        if location == nil {
            locationManager.currentLocationPlacemark { [weak self] placemark, error in
                DispatchQueue.main.async {
                    if let placemark = placemark {
                        self?.setLocation(with: placemark)
                    }
                }
            }
//        } else {
//            updateMapWithCurrentLocation()
//        }
    }
    
//    private func updateMapWithCurrentLocation() {
////        guard let location = location else { return }
//        mapView?.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: closeupSpanWidth, longitudinalMeters: closeupSpanWidth)
//        mapView?.setCenter(location.coordinate, animated: true)
//    }
    
    private func styleView() {
//        confirmButton.layer.borderColor = UIColor.gray.cgColor
//        confirmButton.layer.borderWidth = UIView.hairlineLength // 1/UIScreen.main.scale
//        confirmButton.layer.cornerRadius = confirmButton.frame.height/2
    }
    
    @IBAction private func didSelectConfirm() {
//        guard let location = location else { return }
        
        let center = mapView.centerCoordinate
//        setLocation(with: center)
        
        let location = Location(context: store.mainContext, autoService: autoService, coordinate: center)
        store.mainContext.persist()
        
        let locationObjectID = location.objectID
        
        locationManager.placemark(from: location.clLocation) { [weak self] placemark, error in
            store.mainContext { mainContext in
                guard let self = self,
                    let fetchedLocation = mainContext.object(with: locationObjectID) as? Location else { return }
                fetchedLocation.streetAddress = placemark?.localizedAddress
                mainContext.persist()
                self.delegate?.didSelect(location: fetchedLocation, viewController: self)
            }
        }
        
        var logParameters: [String: Any] = [AnalyticsParameterCheckoutOption:"selectLocation", AnalyticsParameterCheckoutStep: "1"]
        let userLocationKey = "userLocation"
        
        if let userLocation = mapView.userLocation.location {
            let oilChangeLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
            let distanceDiff = userLocation.distance(from: oilChangeLocation)
            logParameters["oilChangeDistanceToCurrentUserLocation"] = distanceDiff
            logParameters[userLocationKey] = true
        } else {
            logParameters[userLocationKey] = false
        }
        Analytics.logEvent(AnalyticsEventSetCheckoutOption, parameters: logParameters)
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
    
    @IBAction private func textFieldDidChange(_ textField: UITextField) {
        searchCompleter.cancel()
        searchCompleter.queryFragment = textField.text ?? ""
    }
    
    private lazy var searchCompleter: MKLocalSearchCompleter = {
        let completer = MKLocalSearchCompleter()
        completer.delegate = self
        return completer
    }()
    
    private func setLocation(with coordinate: CLLocationCoordinate2D) {
        mapView?.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: closeupSpanWidth, longitudinalMeters: closeupSpanWidth)
        mapView?.setCenter(coordinate, animated: true)
    }
    
}

extension SelectLocationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
//        if location == nil {
//            setLocation(with: userLocation)
//            updateMapWithCurrentLocation()
//        }
        
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
    
//    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
//        print("changed")
////        if location == nil {
////
////        }
////        location
//
////        location?.coordinate = CLLocationCoordinate2D(latitude: <#T##CLLocationDegrees#>, longitude: <#T##CLLocationDegrees#>)
//    }
    
//    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        print("changed region")
//    }
    
}


extension SelectLocationViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        locationSearchResultsViewController.results = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("failed")
    }
    
}

extension SelectLocationViewController: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, LocationSearchResultsDelegate {
    
    func willPresentSearchController(_ searchController: UISearchController) {
//        navigationItem.setLeftBarButton(nil, animated: true)
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
//        navigationItem.setLeftBarButton(dismissBarButton, animated: true)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        print("update results")
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        navigationItem.setLeftBarButton(nil, animated: true)
        searchBar.setShowsCancelButton(true, animated: true)
        if locationSearchResultsViewController.parent == nil {
            addLocationSearchResultsViewController()
        }
        
        locationSearchResultsViewController.results = []
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if locationSearchResultsViewController.parent == nil {
            addLocationSearchResultsViewController()
        }
        searchCompleter.queryFragment = searchBar.text ?? ""
        if searchBar.text?.isEmpty == true {
            locationSearchResultsViewController.results = []
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        navigationItem.setLeftBarButton(dismissBarButton, animated: true)
        removeLocationSearchResultsViewController()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    private func addLocationSearchResultsViewController() {
        addChild(locationSearchResultsViewController)
        view.addSubview(locationSearchResultsViewController.view)
        locationSearchResultsViewController.view.pinFrameToSuperViewBounds()
        locationSearchResultsViewController.didMove(toParent: self)
        locationSearchResultsViewController.delegate = self
    }
    
    private func removeLocationSearchResultsViewController() {
        locationSearchResultsViewController.willMove(toParent: nil)
        locationSearchResultsViewController.view.removeFromSuperview()
        locationSearchResultsViewController.removeFromParent()
    }
    
    func didSelect(result: MKLocalSearchCompletion, viewController: LocationSearchResultsViewController) {
        searchBar.text = result.title
        searchBar.resignFirstResponder()
        removeLocationSearchResultsViewController()
        requestLocationSearchCoordinates(address: result.addressDescription) { [weak self] finalCoordinate in
            guard let self = self else { return }
            if let finalCoordinate = finalCoordinate {
                let midpoint = self.mapView.centerCoordinate.midpoint(to: finalCoordinate)
                UIView.animate(withDuration: 0.55, delay: 0.0, options: [.curveEaseOut], animations: {
                    var region = MKCoordinateRegion(center: midpoint, latitudinalMeters: self.mapView.latitudinalMeters * 12, longitudinalMeters: self.mapView.longitudinalMeters * 12)
                    region.span.latitudeDelta = min(134, region.span.latitudeDelta)
                    region.span.longitudeDelta = min(130, region.span.latitudeDelta)
                    self.mapView.region = region
                }, completion: { isFinished in
                    UIView.animate(withDuration: 0.55, delay: 0.0, options: [.curveEaseInOut], animations: {
                        let region = MKCoordinateRegion(center: finalCoordinate, latitudinalMeters: closeupSpanWidth, longitudinalMeters: closeupSpanWidth)
                        self.mapView.region = region
                    }, completion: { isFinished in })
                })
            }
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterCheckoutStep: "location"
        ])
    }
    
    func didTapView(_ viewController: LocationSearchResultsViewController) {
        searchBar.resignFirstResponder()
    }
    
    private func requestLocationSearchCoordinates(address: String, completion: @escaping (_ coordinate: CLLocationCoordinate2D?) -> Void) {
        locationManager.placemarks(fromAddress: address) { placemarks, error in
            DispatchQueue.main.async {
                let coordinate = placemarks?.first?.location?.coordinate
                completion(coordinate)
            }
        }
    }
    
}



public extension MKLocalSearchCompletion {
    
    var addressDescription: String {
        return "\(title) \(subtitle)"
    }
    
}


public extension Location {
    
    var clLocation: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
}


public extension CLPlacemark {
    
    /// Address from a placemark
    var localizedAddress: String? {
        let address = CNMutablePostalAddress()
        address.state = administrativeArea ?? ""
        address.city = locality ?? ""
        address.postalCode = postalCode ?? ""
        address.street = String(format: "%@ %@", thoroughfare ?? "", subThoroughfare ?? "")
        return CNPostalAddressFormatter.string(from: address, style: .mailingAddress)
    }
    
}

public extension MKMapView {
    
    var longitudinalMeters: CLLocationDistance {
        let deltaLongitude = region.span.longitudeDelta
        let latitudeCircumference = 40075160 * cos(region.center.latitude * Double.pi / 180);
        return deltaLongitude * latitudeCircumference / 360
    }
    
    var latitudinalMeters: CLLocationDistance {
        let deltaLatitude = region.span.latitudeDelta
        return deltaLatitude * 40008000 / 360
    }
    
}


extension CLLocationCoordinate2D {
    
    func midpoint(to location: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        
        let lon1 = longitude * Double.pi / 180
        let lon2 = location.longitude * Double.pi / 180
        let lat1 = latitude * Double.pi / 180
        let lat2 = location.latitude * Double.pi / 180
        let dLon = lon2 - lon1
        let x = cos(lat2) * cos(dLon)
        let y = cos(lat2) * sin(dLon)
        
        let lat3 = atan2( sin(lat1) + sin(lat2), sqrt((cos(lat1) + x) * (cos(lat1) + x) + y * y) )
        let lon3 = lon1 + atan2(y, cos(lat1) + x)
        
        return CLLocationCoordinate2DMake(lat3 * 180 / Double.pi, lon3 * 180 / Double.pi)
    }
}


extension UIView {
    
    public func firstView<T>(of type: T.Type) -> T? {
        let subviews = self.subviews.flatMap { $0.subviews }
        guard let element = (subviews.filter { $0 is T }).first as? T else { return nil }
        return element
    }
    
}


extension UISearchBar {
    
    public var textField: UITextField? {
        return firstView(of: UITextField.self)
    }
    
    public func setTextFieldBackgroundColor(color: UIColor) {
        guard let textField = firstView(of: UITextField.self) else { return }
        switch searchBarStyle {
        case .minimal:
            textField.layer.backgroundColor = color.cgColor
        case .prominent, .default:
            textField.backgroundColor = color
        @unknown default: break
        }
    }
    
}
