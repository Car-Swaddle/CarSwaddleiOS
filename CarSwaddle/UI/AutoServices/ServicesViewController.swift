//
//  ServicesViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/21/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleData
import CoreData
import CarSwaddleNetworkRequest
import Store
import Firebase



final class ServicesViewController: UIViewController, StoryboardInstantiating {
    
    static let tableBackgroundColor: UIColor = .primaryBackgroundColor

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var actionButton: ActionButton!
    
    
    enum Section: CaseIterable {
        case upcoming
        case finished
    }
    
    private let sections: [Section] = Section.allCases
    
    lazy private var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl(frame: .zero)
        refresh.addTarget(self, action: #selector(ServicesViewController.didRefresh), for: .valueChanged)
        return refresh
    }()
    
    @objc private func didRefresh() {
        requestAutoServices { [weak self] in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    lazy private var adjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: tableView, actionButton: actionButton)
    private var autoServiceNetwork: AutoServiceNetwork = AutoServiceNetwork(serviceRequest: serviceRequest)
    
    private var autoServiceIDs: [String] = [] {
        didSet {
            resetData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        adjuster.positionActionButton()
        actionButton.addTarget(self, action: #selector(ServicesViewController.didTapCreate), for: .touchUpInside)
        view.backgroundColor = .primaryBackgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestAutoServices()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AutoServiceCell.self)
        tableView.register(HeaderCell.self)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refreshControl
//        tableView.backgroundColor = .primaryBackgroundColor
        tableView.separatorStyle = .none
    }
    
    private func requestAutoServices(completion: @escaping () -> Void = {}) {
        store.privateContext { [weak self] privateContext in
            let allAutoServices = AutoService.fetchAllObjects(with: [AutoService.scheduledDateAscendingSortDescriptor], in: privateContext)
            for autoService in allAutoServices {
                privateContext.delete(autoService)
            }
            
            self?.autoServiceNetwork.getAutoServices(limit: 100, offset: 0, sortStatus: [], in: privateContext) { autoServiceIDs, error in
                DispatchQueue.main.async {
                    let autoServices = AutoService.fetchObjects(with: autoServiceIDs, in: store.mainContext)
                    self?.autoServiceIDs = autoServices.map { $0.identifier }
                    completion()
                }
            }
        }
    }
    
    @IBAction private func didTapCreate() {
        let creator = AutoServiceCreation()
        self.creator = creator
        let pocketController = creator.pocketController!
        pocketController.modalPresentationStyle = .overFullScreen
        present(pocketController, animated: true, completion: nil)
        Analytics.logEvent(AnalyticsEventBeginCheckout, parameters: nil)
    }
    
    private var creator: AutoServiceCreation?
    
    @objc private func didTapDone() {
        dismiss(animated: true, completion: nil)
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<AutoService> = createFetchedResultsController()
    
    private func createFetchedResultsController() -> NSFetchedResultsController<AutoService> {
        let fetchRequest: NSFetchRequest<AutoService> = AutoService.fetchRequest()
        fetchRequest.sortDescriptors = [AutoService.scheduledDateAscendingSortDescriptor]
        
        let inAutoServiceIDsPredicate = AutoService.predicate(includingAutoServiceIDs: autoServiceIDs)
        let pastPredicate = AutoService.predicateFinishedBeforeNow()
        let isCanceledPredicate = AutoService.predicateIsCancelled()
        
        var predicates: [NSPredicate] = [inAutoServiceIDsPredicate, pastPredicate]
        
        if let userID = User.currentUserID {
            let currentUserPredicate = AutoService.predicate(forUserID: userID)
            predicates.append(currentUserPredicate)
        }
        
        let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [andPredicate, isCanceledPredicate])
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: store.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        try! fetchedResultsController.performFetch()
        return fetchedResultsController
    }
    
    private lazy var upcomingFetchedResultsController: NSFetchedResultsController<AutoService> = createFetchedResultsController()
    
    private func createUpcomingFetchedResultsController() -> NSFetchedResultsController<AutoService> {
        let fetchRequest: NSFetchRequest<AutoService> = AutoService.fetchRequest()
        fetchRequest.sortDescriptors = [AutoService.scheduledDateDescendingSortDescriptor]
        
        let inAutoServiceIDsPredicate = AutoService.predicate(includingAutoServiceIDs: autoServiceIDs)
        let upcomingPredicate = AutoService.predicateFinishedAfterNow()
        let isNotCanceledPredicate = AutoService.predicateIsNotCancelled()
        
        var predicates: [NSPredicate] = [inAutoServiceIDsPredicate, upcomingPredicate, isNotCanceledPredicate]
        
        if let userID = User.currentUserID {
            let currentUserPredicate = AutoService.predicate(forUserID: userID)
            predicates.append(currentUserPredicate)
        }
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: store.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        try! fetchedResultsController.performFetch()
        return fetchedResultsController
    }
    
    private func autoService(at indexPath: IndexPath) -> AutoService {
        let adjustedIndexPath = indexPath.with(section: 0).with(row: indexPath.row-1)
        return fetchedResultsController(for: indexPath.section).object(at: adjustedIndexPath)
    }
    
    private func fetchedResultsController(for section: Int) -> NSFetchedResultsController<AutoService> {
        switch sections[section] {
        case .upcoming:
            return upcomingFetchedResultsController
        case .finished:
            return fetchedResultsController
        }
    }
    
//    private func indexPathWith0Section(_ indexPath: IndexPath) -> IndexPath {
//        let adjustedIndexPath = IndexPath(item: indexPath.item, section: 0)
//        return adjustedIndexPath
//    }
    
    private func resetData() {
        fetchedResultsController = createFetchedResultsController()
        upcomingFetchedResultsController = createUpcomingFetchedResultsController()
        tableView.reloadData()
    }
    
    private func numberOfObjects(inSection section: Int) -> Int {
        switch sections[section] {
        case .upcoming:
            return (upcomingFetchedResultsController.sections?[0].numberOfObjects ?? 0)
        case .finished:
            return (fetchedResultsController.sections?[0].numberOfObjects ?? 0)
        }
    }
    
}

extension ServicesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let objectCount = numberOfObjects(inSection: section)
        if objectCount == 0 {
            return objectCount
        } else {
            return objectCount + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell: HeaderCell = tableView.dequeueCell()
            cell.title = self.title(forSection: indexPath.section)
            return cell
        } else {
            let cell: AutoServiceCell = tableView.dequeueCell()
            let autoService = self.autoService(at: indexPath)
            cell.configure(with: autoService)
            return cell
        }
    }
    
//    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        let upcoming = NSLocalizedString("Upcoming Oil changes", comment: "Title of section for oil changes that haven't occurred yet")
//        let past = NSLocalizedString("Finished Oil changes", comment: "Title of section for oil changes that haven't occurred yet")
//        return [upcoming, past]
//    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        switch sections[section] {
//        case .upcoming:
//            return NSLocalizedString("Upcoming Oil changes", comment: "Title of section for oil changes that haven't occurred yet")
//        case .finished:
//            return NSLocalizedString("Finished Oil changes", comment: "Title of section for oil changes that haven't occurred yet")
//        }
//    }

    
}

extension ServicesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row != 0 else { return }
        let autoService = self.autoService(at: indexPath)
        
        let viewController = AutoServiceDetailsViewController.create(with: autoService)
        show(viewController, sender: self)
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return ServiceHeaderView.height(for: self.title(for: section), width: view.frame.width)
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = ServiceHeaderView.viewFromNib()
//        view.label.text = self.title(for: section)
//        return view
//    }
    
    private func title(forSection section: Int) -> String {
        switch sections[section] {
        case .upcoming:
            let appointments = NSLocalizedString("Hello %@, you have %d upcoming appointments", comment: "How many appointments are upcoming")
            let name = User.currentUser(context: store.mainContext)?.firstName ?? ""
            let upcomingAppointments = numberOfObjects(inSection: 0)
            return String(format: appointments, name, upcomingAppointments)
        case .finished:
            return NSLocalizedString("Completed appointments", comment: "How many appointments are finished")
        }
    }
    
}




public extension AutoService {
    
    static var scheduledDateAscendingSortDescriptor: NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(AutoService.scheduledDate), ascending: false)
    }
    
    static var scheduledDateDescendingSortDescriptor: NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(AutoService.scheduledDate), ascending: true)
    }
    
    static func predicate(includingAutoServiceIDs autoServiceIDs: [String]) -> NSPredicate {
        return NSPredicate(format: "%K in %@", #keyPath(AutoService.identifier), autoServiceIDs)
    }
    
    static func predicateScheduled(before date: Date) -> NSPredicate {
        return NSPredicate(format: "%K < %@", #keyPath(AutoService.scheduledDate), date as NSDate)
    }
    
    static func predicateIsCancelled() -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(AutoService.isCanceled), NSNumber(value: true))
    }
    
    static func predicateIsNotCancelled() -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(AutoService.isCanceled), NSNumber(value: false))
    }
    
    
    static func predicateScheduled(after date: Date) -> NSPredicate {
        return NSPredicate(format: "%K > %@", #keyPath(AutoService.scheduledDate), date as NSDate)
    }
    
    static func predicateFinishedBeforeNow() -> NSPredicate {
        return AutoService.predicateScheduled(before: Date().dateByAdding(hours: -1))
    }
    
    static func predicateFinishedAfterNow() -> NSPredicate {
        return AutoService.predicateScheduled(after: Date().dateByAdding(hours: -1))
    }
    
}



extension IndexPath {
    
    func with(section: Int) -> IndexPath {
        return IndexPath(row: self.row, section: section)
    }
    
    func with(row: Int) -> IndexPath {
        return IndexPath(row: row, section: self.section)
    }
    
}
