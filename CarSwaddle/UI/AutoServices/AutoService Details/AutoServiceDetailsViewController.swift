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
        case header
        case vehicle
        case location
        case notes
    }
    
    private var rows: [Row] = Row.allCases
    
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

        setupTableView()
        _ = contentInsetAdjuster
        
        requestData()
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(TableViewCell.self)
        tableView.register(ReviewCell.self)
        tableView.register(NotesTableViewCell.self)
        tableView.register(AutoServiceVehicleCell.self)
        tableView.register(AutoServiceLocationCell.self)
        tableView.register(AutoServiceDetailsHeaderCell.self)
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
            return cell
        }
    }
    
}

extension AutoServiceDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
        let alert = createRatingAlert()
        present(alert, animated: true, completion: nil)
    }
    
    private func createRatingAlert() -> CustomAlertController {
        let title = NSLocalizedString("Rate your mechanic", comment: "Title of alert when user is rating their mechanic")
        let content = CustomAlertContentView.view(withTitle: title, message: nil)
        content.attributedTitleText = NSAttributedString(string: title, attributes: [.foregroundColor: UIColor.gray5, .font: UIFont.appFont(type: .semiBold, size: 17) as UIFont])
        
        content.addCustomView { [weak self] customView in
            customView.heightAnchor.constraint(equalToConstant: 35).isActive = true
            
            let starRatingView = CosmosView(settings: .default)
            starRatingView.rating =  5.0
            starRatingView.settings.updateOnTouch = true
            starRatingView.translatesAutoresizingMaskIntoConstraints = false
            
            customView.addSubview(starRatingView)
            starRatingView.topAnchor.constraint(equalTo: customView.topAnchor).isActive = true
            starRatingView.bottomAnchor.constraint(equalTo: customView.bottomAnchor).isActive = true
            
            starRatingView.centerXAnchor.constraint(equalTo: customView.centerXAnchor).isActive = true
            starRatingView.widthAnchor.constraint(equalToConstant: 120).isActive = true
            
            starRatingView.settings.filledImage = #imageLiteral(resourceName: "star_filled_same_color_border")
            starRatingView.settings.emptyImage = #imageLiteral(resourceName: "star_inactive_gray_border")
            
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
            textView.layer.borderColor = UIColor.gray2.cgColor
            textView.layer.borderWidth = 1
            textView.layer.cornerRadius = 8.0
            
            textView.font = UIFont.appFont(type: .regular, size: 17)
            textView.tintColor = .viewBackgroundColor1
            
            textView.becomeFirstResponder()
            
            self?.ratingTextView = textView
        }
        
        content.addCancelAction()
        let rateAction = self.rateAction
        content.addAction(rateAction)
        
        content.preferredAction = rateAction
        
        if let button = content.preferredButton {
            button.titleLabel?.font = UIFont.appFont(type: .regular, size: 17)
            
            button.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            button.setTitleColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), for: .highlighted)
            
            button.layer.borderWidth = 1
            button.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
            
            let background: UIColor = .secondary
            
            button.setBackgroundImage(UIImage.from(color: background), for: .normal)
            button.setBackgroundImage(UIImage.from(color: background.color(adjustedBy255Points: -40)), for: .highlighted)
        }
        
        content.normalButtons.forEach {
            configureNormalActionButton($0)
        }
        
        let alert = CustomAlertController.viewController(contentView: content)
        return alert
    }
    
    private func configureNormalActionButton(_ button: UIButton) {
        button.titleLabel?.font = UIFont.appFont(type: .regular, size: 17)
        button.setTitleColor(.secondary, for: .normal)
        button.setTitleColor(.viewBackgroundColor1, for: .highlighted)
        
        button.layer.borderWidth = 1
        button.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        
        let background = UIColor(white255: 244)
        
        button.setBackgroundImage(UIImage.from(color: background), for: .normal)
        button.setBackgroundImage(UIImage.from(color: background.color(adjustedBy255Points: -40)), for: .highlighted)
    }
    
    private var rateAction: CustomAlertAction {
        let rateTitle = NSLocalizedString("Rate", comment: "Button title when selected confirms rate of user to mechanic")
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
                self?.autoServiceNetwork.updateAutoService(autoServiceID: autoServiceID, json: json, in: context) { [weak self]  objectID, error in
                    if error == nil {
                        print("success!")
                        DispatchQueue.main.async {
                            self?.reloadCell(row: .header)
                        }
                    } else {
                        print("No success")
                    }
                }
            }
        }
    }
    
    private func reloadCell(row: Row) {
        guard let index = rows.firstIndex(of: row) else { return }
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
    }
    
}
