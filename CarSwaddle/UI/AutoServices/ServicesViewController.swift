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
import CarSwaddleStore
import Firebase
import EventKit


final class ServicesViewController: UIViewController, StoryboardInstantiating {
    
    static let tableBackgroundColor: UIColor = .background

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
        view.backgroundColor = ServicesViewController.tableBackgroundColor
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
        creator.delegate = self
        self.creator = creator
        let pocketController = creator.pocketController!
        pocketController.modalPresentationStyle = .fullScreen
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
    
}

extension ServicesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row != 0 else { return }
        let autoService = self.autoService(at: indexPath)
        
        let viewController = AutoServiceDetailsViewController.create(with: autoService)
        show(viewController, sender: self)
    }
    
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

extension ServicesViewController: AutoServiceCreationDelegate {
    
    func didCompletePayment(creation: AutoServiceCreation, autoService: AutoService) {
        let confirmAlert = self.confirmationAlert(autoService: autoService)
        present(confirmAlert, animated: true, completion: nil)
    }
    
    private func confirmationAlert(autoService: AutoService) -> CustomAlertController {
        let title = NSLocalizedString("Congratulations on scheduling your oil change! Would you like to add it to your calendar?", comment: "Title of alert after user created an auto service")
        let message = NSLocalizedString("Add it to your calendar to receive reminders.", comment: "Title of alert after user created an auto service")
        let alertView = CustomAlertContentView.view(withTitle: title, message: message)
        
        let dismissAction = CustomAlertAction(title: NSLocalizedString("Dismiss", comment: "Dismisses an alert"))
        alertView.addAction(dismissAction)
        let addAction = CustomAlertAction(title: NSLocalizedString("Add event", comment: "Adds an event to the users calendar")) { action in
            autoService.createEvent { event in
                DispatchQueue.main.async {
                    if event != nil {
                        let addedAlert = self.didAddEventAlert()
                        self.present(addedAlert, animated: true, completion: nil)
                    } else {
                        let allowAlert = self.allowCalendarUseAlert()
                        self.present(allowAlert, animated: true, completion: nil)
                    }
                }
            }
        }
        alertView.addAction(addAction)
        
        alertView.preferredAction = addAction
        
        let alert = CustomAlertController.viewController(contentView: alertView)
        return alert
    }
    
    private func allowCalendarUseAlert() -> CustomAlertController {
        let title = NSLocalizedString("Allow Car Swaddle calendar access", comment: "Title of alert after user created an auto service")
        let message = NSLocalizedString("In order for Car Swaddle to add events to your calendar, you must allow so in settings.", comment: "Title of alert after user created an auto service")
        let alertView = CustomAlertContentView.view(withTitle: title, message: message)
        
        alertView.addCancelAction()
        let openSettingsAction = CustomAlertAction(title: NSLocalizedString("Open settings", comment: "Title of button that opens the users settings")) { action in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertView.addAction(openSettingsAction)
        alertView.preferredAction = openSettingsAction
        
        let alert = CustomAlertController.viewController(contentView: alertView)
        return alert
    }
    
    private func didAddEventAlert() -> CustomAlertController {
        let title = NSLocalizedString("Car Swaddle added an event to your calendar", comment: "Title of alert after user created an auto service")
        let message = NSLocalizedString("You'll get a reminder the day before and 30 minutes before the service.", comment: "Title of alert after user created an auto service")
        let alertView = CustomAlertContentView.view(withTitle: title, message: message)
        
        alertView.addOkayAction()
        
        let alert = CustomAlertController.viewController(contentView: alertView)
        alert.tapBackgroundToDismiss = true
        return alert
    }
    
}


extension AutoService {
    
    func createEvent(completion: @escaping (_ event: EKEvent?) -> Void) {
        let store = EKEventStore()
        
        store.requestAccess(to: .event) { isAllowed, error in
            guard isAllowed else {
                completion(nil)
                return
            }
            let event = EKEvent(eventStore: store)
            if let date = self.scheduledDate {
                event.startDate = date
                event.endDate = date.dateByAdding(minutes: 45)
            }
            
            event.title = NSLocalizedString("Car Swaddle oil change", comment: "Title of an event")
            
            event.location = self.location?.streetAddress
            event.availability = .busy
            
            event.addAlarm(EKAlarm(relativeOffset: .minute * 30))
            event.addAlarm(EKAlarm(relativeOffset: .day))
            
            event.calendar = store.defaultCalendarForNewEvents
            
            do {
                try store.save(event, span: .thisEvent)
                completion(event)
            } catch {
                completion(nil)
            }
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
