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

private let cancelRefundMessage = NSLocalizedString("If you cancel this auto service your funds will refunded and your mechanic will be notified.", comment: "Alert")
private let cancelNoRefundMessage = NSLocalizedString("Because the auto service is less than 24 hours away. Your funds will not be refunded to you should you cancel this auto service. Your mechanic will be notified of the cancellation", comment: "Alert")

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
    
    private var autoService: AutoService! {
        didSet {
            self.rows = createRows()
        }
    }
    
    private var autoServiceNetwork: AutoServiceNetwork = AutoServiceNetwork(serviceRequest: serviceRequest)
    private var starRatingView: CosmosView?
    private var ratingTextView: UITextView?
    
    private var ratingController: RatingController = RatingController()
    
    private lazy var contentInsetAdjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: tableView, actionButton: nil)
    
    private enum Row: CaseIterable {
        case header
        case vehicle
        case location
        case notes
        case cancel
    }
    
    private func createRows() -> [Row] {
        var cases: [Row] = [.header, .vehicle, .location, .notes]
        if autoService.status.isCancellable {
            cases.append(.cancel)
        }
        return cases
    }
    
    private lazy var rows: [Row] = {
        return createRows()
    }()
    
    lazy private var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(AutoServiceDetailsViewController.didRefresh), for: .valueChanged)
        return refresh
    }()
    
    @objc private func didRefresh() {
        requestData { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        starRatingView?.backgroundColor = .clear
        
        setupTableView()
        _ = contentInsetAdjuster
        
        requestData()
        
        ratingController.userDidRate = { [weak self] in
            self?.reloadCell(row: .header)
        }
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(TableViewCell.self)
        tableView.register(ReviewCell.self)
        tableView.register(NotesTableViewCell.self)
        tableView.register(AutoServiceVehicleCell.self)
        tableView.register(AutoServiceLocationCell.self)
        tableView.register(AutoServiceDetailsHeaderCell.self)
        tableView.register(CancelAutoServiceCell.self)
        tableView.refreshControl = refreshControl
    }
    
    private func requestData(completion: @escaping () -> Void = {}) {
        let autoServiceID = autoService.identifier
        store.privateContext { [weak self] privateContext in
            self?.autoServiceNetwork.getAutoServiceDetails(autoServiceID: autoServiceID, in: privateContext) { autoServiceObjectID, error in
                DispatchQueue.main.async {
                    if self?.refreshControl.isRefreshing == true {
                        self?.refreshControl.endRefreshing()
                    }
                    completion()
                }
            }
        }
    }
    
    private func cancelAlert() -> UIAlertController {
        let title = NSLocalizedString("Are you sure you want to cancel this auto service?", comment: "Alert")
        let message: String
        if let scheduledDate = autoService.scheduledDate, scheduledDate > Date().dateByAdding(hours: 24) {
            message = cancelRefundMessage
        } else {
            message = cancelNoRefundMessage
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let actionTitle = NSLocalizedString("Cancel auto service", comment: "Action title")
        let cancelAutoServiceAction = UIAlertAction(title: actionTitle, style: .destructive) { [weak self] action in
            self?.cancelAutoService()
        }
        
        alert.addAction(cancelAutoServiceAction)
        
        let backTitle = NSLocalizedString("Dismiss", comment: "Action title cancel")
        let backAction = UIAlertAction(title: backTitle, style: .cancel)
        
        alert.addAction(backAction)
        
        return alert
    }
    
    private func cancelAutoService() {
        guard let autoServiceID = autoService?.identifier else { return }
        store.privateContext { [weak self] privateContext in
            self?.autoServiceNetwork.updateAutoService(autoServiceID: autoServiceID, status: .canceled, in: privateContext) { autoServiceObjectID, error in
                guard let autoServiceObjectID = autoServiceObjectID, error == nil else { return }
                store.mainContext { mainContext in
                    self?.autoService = mainContext.object(with: autoServiceObjectID) as? AutoService
                    if self?.refreshControl.isRefreshing == true {
                        self?.refreshControl.endRefreshing()
                    }
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
}

extension AutoServiceDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.row]
        
        switch row {
        case .header:
            let cell: AutoServiceDetailsHeaderCell = tableView.dequeueCell()
            cell.configure(with: autoService)
            cell.delegate = self
            return cell
        case .location:
            let cell: AutoServiceLocationCell = tableView.dequeueCell()
            if let location = autoService.location {
                cell.configure(with: location)
            }
            return cell
        case .vehicle:
            let cell: AutoServiceVehicleCell = tableView.dequeueCell()
            if let autoService = autoService {
                cell.configure(with: autoService)
            }
            return cell
        case .notes:
            let cell: NotesTableViewCell = tableView.dequeueCell()
            cell.configure(with: autoService)
            cell.didBeginEditing = { [weak self] in
                self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
            cell.showHairlineView = autoService.status.isCancellable
            return cell
        case .cancel:
            let cell: CancelAutoServiceCell = tableView.dequeueCell()
            return cell
        }
    }
    
}

extension AutoServiceDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch rows[indexPath.row] {
        case .cancel:
            let alert = self.cancelAlert()
            present(alert, animated: true, completion: nil)
        default:
            break
        }
    }
    
}

extension AutoServiceDetailsViewController: AutoServiceDetailsHeaderCellDelegate {
    
    func present(viewController: UIViewController, cell: AutoServiceDetailsHeaderCell) {
        present(viewController, animated: true, completion: nil)
    }
    
    func dismissMessageComposeViewController(cell: AutoServiceDetailsHeaderCell) {
        dismiss(animated: true, completion: nil)
    }
    
    func didTapReview(cell: AutoServiceDetailsHeaderCell) {
        didSelectRate()
    }
    
}

extension AutoServiceDetailsViewController: ReviewCellProtocol {
    
    func didSelectRate() {
        guard autoService.reviewFromUser == nil else { return }
        let alert = self.ratingController.createRatingAlert(forAutoServiceID: autoService.identifier)
        present(alert, animated: true, completion: nil)
    }
    
    private func reloadCell(row: Row) {
        guard let index = rows.firstIndex(of: row) else { return }
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
    }
    
}



extension AutoService.Status {
    
    var isCancellable: Bool {
        return self == .scheduled
    }
    
}
