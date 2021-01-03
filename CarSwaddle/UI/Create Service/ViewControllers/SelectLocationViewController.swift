//
//  SelectLocationViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/23/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import MapKit
import CarSwaddleStore
import CoreLocation
import Contacts
import AddressBook
import CarSwaddleUI

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
        viewController.delegate = delegate
        return viewController
    }
    
    weak var delegate: SelectLocationViewControllerDelegate?
    
    private var autoService: AutoService!
    
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var confirmButton: ActionButton!
    @IBOutlet private weak var centerView: UIImageView!
    
    private lazy var contentAdjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: nil, actionButton: confirmButton)
    private var locationSearchResultsViewController = LocationSearchResultsViewController.viewControllerFromStoryboard()
    
    private var didUpdateToUserLocation: Bool = false
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: locationSearchResultsViewController)
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.showsCancelButton = false
        let placeholder = NSLocalizedString("Search Location", comment: "Placeholder text")
        searchController.searchBar.placeholder = placeholder
        if #available(iOS 13, *) {
            searchController.searchBar.searchTextField.borderColor = .secondaryBackground
            searchController.searchBar.searchTextField.borderWidth = UIView.hairlineLength
            searchController.searchBar.searchTextField.cornerRadius = 7
        } else {
            searchController.searchBar.textField?.borderColor = .secondaryBackground
            searchController.searchBar.textField?.borderWidth = UIView.hairlineLength
            searchController.searchBar.textField?.cornerRadius = 7
        }
        return searchController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.promptUserForLocationAccess()
        
        locationSearchResultsViewController.delegate = self
        
        setupBarButtons()
        
        mapView.delegate = self
        
        centerView.layer.shadowOpacity = 0.45
        centerView.layer.shadowColor = UIColor.black.cgColor
        centerView.layer.shadowRadius = 4
        centerView.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        centerView.image = #imageLiteral(resourceName: "pin").withRenderingMode(.alwaysTemplate)
        
        contentAdjuster.positionActionButton()
        
        locationManager.currentLocation(cacheOptions: .networkOnly) { [weak self] location, error in
            DispatchQueue.main.async {
                guard let location = location else { return }
                self?.setLocation(with: location)
            }
        }
        
        navigationItem.searchController = searchController
        title = NSLocalizedString("Oil change location", comment: "")
        
        confirmButton.titleLabel?.numberOfLines = 0
        
        pocketController?.bottomViewControllerHeight = 120
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        navigationController?.view.setNeedsLayout()
//        navigationController?.view.layoutIfNeeded()
//
//        pocketController?.bottomViewController?.view.setNeedsLayout()
//        pocketController?.bottomViewController?.view.layoutIfNeeded()
//    }
    
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
        return UIBarButtonItem(title: NSLocalizedString("Dismiss", comment: "Title of cancel button"), style: .plain, target: self, action: #selector(SelectLocationViewController.didSelectDismiss))
    }
    
    @objc private func didSelectDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didSelectConfirm() {
        confirmButton.isLoading = true
        
        let center = mapView.centerCoordinate
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
                self.confirmButton.isLoading = false
            }
        }
        
        var logParameters: [Tracker.Parameter: Any] = [.checkoutOption:"selectLocation", .checkoutStep: "1"]
//        let userLocationKey = "userLocation"
        
        if let userLocation = mapView.userLocation.location {
            let oilChangeLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
            let distanceDiff = userLocation.distance(from: oilChangeLocation)
            logParameters[.distanceTo] = distanceDiff
            logParameters[.userLocation] = true
        } else {
            logParameters[.userLocation] = false
        }
        tracker.logEvent(trackerName: .checkoutOption, trackerParameters: logParameters)
    }
    
    private func setLocation(with placemark: CLPlacemark) {
        guard let coordinate = placemark.location?.coordinate else { return }
        self.setLocation(with: coordinate)
    }
    
    private func setLocation(with location: CLLocation) {
        self.setLocation(with: location.coordinate)
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
        if didUpdateToUserLocation == false {
            didUpdateToUserLocation = true
            setLocation(with: userLocation.coordinate)
        }
    }
    
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
        
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        print("update results")
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        
        locationSearchResultsViewController.results = []
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchBar.text ?? ""
        if searchBar.text?.isEmpty == true {
            locationSearchResultsViewController.results = []
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func didSelect(result: MKLocalSearchCompletion, viewController: LocationSearchResultsViewController) {
        searchController.searchBar.text = result.title
        searchController.isActive = false
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
        
        tracker.logEvent(trackerName: .selectContent, trackerParameters: [
            .checkoutStep: "location"
        ])
    }
    
    func didTapView(_ viewController: LocationSearchResultsViewController) {
        searchController.isActive = false
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
    
    public func firstSubview<T>(of type: T.Type) -> T? {
        let subviews = self.subviews.flatMap { $0.subviews }
        guard let element = (subviews.filter { $0 is T }).first as? T else { return nil }
        return element
    }
    
}



extension UISearchBar {
    
    public var textField: UITextField? {
        return firstSubview(of: UITextField.self)
    }

//    public func setTextFieldBackgroundColor(color: UIColor) {
//        guard let textField = firstSubview(of: UITextField.self) else { return }
//        switch searchBarStyle {
//        case .minimal:
//            textField.layer.backgroundColor = color.cgColor
//        case .prominent, .default:
//            textField.backgroundColor = color
//        @unknown default: break
//        }
//    }
    
}


extension UIViewController {
    
    public var pocketController: PocketController? {
        return navigationController as? PocketController
    }
    
}
