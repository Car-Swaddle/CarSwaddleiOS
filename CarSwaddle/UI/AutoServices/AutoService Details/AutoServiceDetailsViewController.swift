//
//  AutoServiceViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 1/2/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store
import CarSwaddleData
import Cosmos

private let dateFormatter: DateFormatter = {
    let d = DateFormatter()
    d.dateFormat = "MMM d, hha"
    return d
}()

final class AutoServiceDetailsViewController: UIViewController, StoryboardInstantiating {

    static func create(with autoService: AutoService) -> AutoServiceDetailsViewController {
        let viewController = AutoServiceDetailsViewController.viewControllerFromStoryboard()
        viewController.autoService = autoService
        return viewController
    }
    
    private var autoService: AutoService!
    
    private var autoServiceNetwork: AutoServiceNetwork = AutoServiceNetwork(serviceRequest: serviceRequest)
    private var starRatingView: CosmosView?
    private var ratingTextView: UITextView?
    
    private lazy var contentInsetAdjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: tableView, actionButton: nil)
    
    private enum Row: CaseIterable {
        case mechanic
        case date
        case location
        case vehicle
        case oilType
        case serviceType
        case status
        case notes
        case review
    }
    
    private var rows: [Row] = Row.allCases
    
    lazy private var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(AutoServiceDetailsViewController.didRefresh), for: .valueChanged)
        return refresh
    }()
    
    @objc private func didRefresh() {
        
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        _ = contentInsetAdjuster
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(TableViewCell.self)
        tableView.register(ReviewCell.self)
        tableView.register(NotesTableViewCell.self)
        tableView.register(AutoServiceVehicleCell.self)
    }
    
}

extension AutoServiceDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.row]
        
        switch row {
        case .mechanic:
            let cell: TableViewCell = tableView.dequeueCell()
            cell.textLabel?.text = autoService.mechanic?.user?.displayName
            return cell
        case .date:
            let cell: TableViewCell = tableView.dequeueCell()
            if let date = autoService.scheduledDate {
                cell.textLabel?.text = dateFormatter.string(from: date)
            }
            return cell
        case .location:
            let cell: TableViewCell = tableView.dequeueCell()
            cell.textLabel?.text = "location"
            return cell
        case .vehicle:
            let cell: AutoServiceVehicleCell = tableView.dequeueCell()
            if let autoService = autoService {
                cell.configure(with: autoService)
            }
            return cell
        case .oilType:
            let cell: TableViewCell = tableView.dequeueCell()
            cell.textLabel?.text = autoService.firstOilChange?.oilType.localizedString
            return cell
        case .serviceType:
            let cell: TableViewCell = tableView.dequeueCell()
            cell.textLabel?.text = "Oil Change"
            return cell
        case .status:
            let cell: TableViewCell = tableView.dequeueCell()
            cell.textLabel?.text = autoService.status.rawValue
            return cell
        case .review:
            let cell: ReviewCell = tableView.dequeueCell()
            cell.delegate = self
            cell.configure(with: autoService)
            return cell
        case .notes:
            let cell: NotesTableViewCell = tableView.dequeueCell()
            cell.configure(with: autoService)
            return cell
        }
    }
    
}

extension AutoServiceDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension AutoServiceDetailsViewController: ReviewCellProtocol {
    
    func didSelectRate() {
        let alert = createRatingAlert()
        present(alert, animated: true, completion: nil)
    }
    
    private func createRatingAlert() -> CustomAlertController {
        let title = NSLocalizedString("Rate your mechanic", comment: "Title of alert when user is rating their mechanic")
        let content = CustomAlertContentView.view(withTitle: title, message: nil)
        
        content.addCustomView { [weak self] customView in
            customView.heightAnchor.constraint(equalToConstant: 35).isActive = true
            
            let starRatingView = CosmosView(settings: .default)
            starRatingView.rating = 5.0
            starRatingView.settings.updateOnTouch = true
            starRatingView.translatesAutoresizingMaskIntoConstraints = false
            
            customView.addSubview(starRatingView)
            starRatingView.topAnchor.constraint(equalTo: customView.topAnchor).isActive = true
            starRatingView.bottomAnchor.constraint(equalTo: customView.bottomAnchor).isActive = true
            
            starRatingView.centerXAnchor.constraint(equalTo: customView.centerXAnchor).isActive = true
            starRatingView.widthAnchor.constraint(equalToConstant: 120).isActive = true
            
            self?.starRatingView = starRatingView
        }
        
        content.addCustomView { [weak self] customView in
            customView.heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            let textView = UITextView()
            textView.translatesAutoresizingMaskIntoConstraints = false
            
            customView.addSubview(textView)
            textView.topAnchor.constraint(equalTo: customView.topAnchor).isActive = true
            textView.bottomAnchor.constraint(equalTo: customView.bottomAnchor).isActive = true
            textView.leadingAnchor.constraint(equalTo: customView.leadingAnchor).isActive = true
            textView.trailingAnchor.constraint(equalTo: customView.trailingAnchor).isActive = true
            textView.layer.borderColor = UIColor.gray4.cgColor
            textView.layer.borderWidth = 1
            textView.layer.cornerRadius = 8.0
            
//            textView.font = UIFont.appFont(size: 16)
            
            textView.becomeFirstResponder()
            
            self?.ratingTextView = textView
        }
        
        content.addCancelAction()
        let rateAction = self.rateAction
        content.addAction(rateAction)
        
        content.preferredAction = rateAction
        
        let alert = CustomAlertController.viewController(contentView: content)
        return alert
    }
    
    private var rateAction: CustomAlertAction {
        let rateTitle = NSLocalizedString("RATE", comment: "Button title when selected confirms rate of user to mechanic")
        let autoServiceID = autoService.identifier
        return CustomAlertAction(title: rateTitle) { [weak self] alert in
            guard let rating = self?.starRatingView?.rating,
                let text = self?.ratingTextView?.text else { return }
            store.privateContext { context in
                let json: JSONObject = ["review": [
                    "rating": rating,
                    "text": text
                    ]
                ]
                self?.autoServiceNetwork.updateAutoService(autoServiceID: autoServiceID, json: json, in: context) { objectID, error in
                    if error == nil {
                        print("success!")
                    } else {
                        print("No success")
                    }
                }
            }
        }
    }
    
}
