//
//  PickerCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 8/26/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

private let doneTitle = NSLocalizedString("Done", comment: "")
private let selectTitle = NSLocalizedString("Select", comment: "")



class StatePickerCell: UITableViewCell, NibRegisterable, StatePickerDelegate {
    
    public var didChangeSelection: ( _ state: USState) -> Void = { _ in }
    public var willUpdateHeight: () -> Void = {}
    public var didUpdateHeight: () -> Void = {}
    public var didShowPicker: () -> Void = {}
    
    public var selectedState: USState = .utah {
        didSet {
            updatePickerWithSelection()
            didChangeSelection(selectedState)
        }
    }
    
    public func hidePicker() {
        isShowingPicker = false
    }
    
    public func showPicker() {
        isShowingPicker = true
    }
    
    @IBOutlet private weak var selectionLabel: UILabel!
    @IBOutlet private weak var topContainerView: UIView!
    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet private weak var picker: StatePicker!
    
    @IBOutlet private var heightViewHeightConstraint: NSLayoutConstraint!
    
    private var isShowingPicker: Bool = false {
        didSet {
            updateUIForIsShowingPicker()
            if isShowingPicker {
                didShowPicker()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectedState = .utah
//        picker.addTarget(self, action: #selector(didChangePicker), for: .valueChanged)
        updateUIForIsShowingPicker()
        
        clipsToBounds = true
        selectionStyle = .none
        
        picker.statePickerDelegate = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        
        
//        datePicker.minimumDate = Date()
//        if selectedDate < Date() {
//            datePicker.date = selectedDate
//        }
    }
    
    private func updatePickerWithSelection() {
        selectionLabel.text = selectedState.localizedString
//        dateLabel.text = monthDayYearTimeDateFormatter.string(from: selectedDate)
    }
    
    private func updateUIForIsShowingPicker() {
        willUpdateHeight()
        heightViewHeightConstraint.constant = isShowingPicker ? topContainerView.frame.height + picker.frame.height : topContainerView.frame.height
        didUpdateHeight()
        
        UIView.animate(withDuration: 0.25) {
            self.picker.alpha = self.isShowingPicker ? 1.0 : 0.0
        }
        
        UIView.performWithoutAnimation {
            self.doneButton.setTitle(self.buttonTitle, for: .normal)
            self.doneButton.layoutIfNeeded()
        }
    }
    
    private var buttonTitle: String {
        return isShowingPicker ? doneTitle : selectTitle
    }
    
    @IBAction private func didTapDone() {
        isShowingPicker = !isShowingPicker
    }
    
    @objc private func didChangePicker() {
//        selectedDate = datePicker.date
    }
    
    func didSelectState(state: USState, statePicker: StatePicker) {
        selectedState = state
    }
    
}


//extension DatePickerCell: UIPickerViewDelegate {
//
//
//
//}
//
//extension DatePickerCell: UIPickerViewDataSource {
//
//
//
//}



public enum USState: String, CaseIterable {
    case alaska             = "AK"
    case alabama            = "AL"
    case arkansas           = "AR"
//    case americanSamoa      = "AS"
    case arizona            = "AZ"
    case california         = "CA"
    case colorado           = "CO"
    case connecticut        = "CT"
//    case districtOfColumbia = "DC"
    case delaware           = "DE"
    case florida            = "FL"
    case georgia            = "GA"
//    case guam               = "GU"
    case hawaii             = "HI"
    case iowa               = "IA"
    case idaho              = "ID"
    case illinois           = "IL"
    case indiana            = "IN"
    case kansas             = "KS"
    case kentucky           = "KY"
    case louisiana          = "LA"
    case massachusetts      = "MA"
    case maryland           = "MD"
    case maine              = "ME"
    case michigan           = "MI"
    case minnesota          = "MN"
    case missouri           = "MO"
    case mississippi        = "MS"
    case montana            = "MT"
    case northCarolina      = "NC"
    case northDakota        = "ND"
    case nebraska           = "NE"
    case newHampshire       = "NH"
    case newJersey          = "NJ"
    case newMexico          = "NM"
    case nevada             = "NV"
    case newYork            = "NY"
    case ohio               = "OH"
    case oklahoma           = "OK"
    case oregon             = "OR"
    case pennsylvania       = "PA"
//    case puertoRico         = "PR"
    case rhodeIsland        = "RI"
    case southCarolina      = "SC"
    case southDakota        = "SD"
    case tennessee          = "TN"
    case texas              = "TX"
    case utah               = "UT"
    case virginia           = "VA"
//    case virginIslands      = "VI"
    case vermont            = "VT"
    case washington         = "WA"
    case wisconsin          = "WI"
    case westVirginia       = "WV"
    case wyoming            = "WY"
    
    public var localizedString: String {
        switch self {
        case .alaska: return NSLocalizedString("Alaska", comment: "US state")
        case .alabama: return NSLocalizedString("Alabama", comment: "US state")
        case .arkansas: return NSLocalizedString("Arkansas", comment: "US state")
//        case .americanSamoa: return NSLocalizedString("American Samoa", comment: "US state")
        case .arizona: return NSLocalizedString("Arizona", comment: "US state")
        case .california: return NSLocalizedString("California", comment: "US state")
        case .colorado: return NSLocalizedString("Colorado", comment: "US state")
        case .connecticut: return NSLocalizedString("Connecticut", comment: "US state")
//        case .districtOfColumbia: return NSLocalizedString("District Of Columbia", comment: "US state")
        case .delaware: return NSLocalizedString("Delaware", comment: "US state")
        case .florida: return NSLocalizedString("Florida", comment: "US state")
        case .georgia: return NSLocalizedString("Georgia", comment: "US state")
//        case .guam: return NSLocalizedString("Guam", comment: "US state")
        case .hawaii: return NSLocalizedString("Hawaii", comment: "US state")
        case .iowa: return NSLocalizedString("Iowa", comment: "US state")
        case .idaho: return NSLocalizedString("Idaho", comment: "US state")
        case .illinois: return NSLocalizedString("Illinois", comment: "US state")
        case .indiana: return NSLocalizedString("Indiana", comment: "US state")
        case .kansas: return NSLocalizedString("Kansas", comment: "US state")
        case .kentucky: return NSLocalizedString("Kentucky", comment: "US state")
        case .louisiana: return NSLocalizedString("Louisiana", comment: "US state")
        case .massachusetts: return NSLocalizedString("Massachusetts", comment: "US state")
        case .maryland: return NSLocalizedString("Maryland", comment: "US state")
        case .maine: return NSLocalizedString("Maine", comment: "US state")
        case .michigan: return NSLocalizedString("Michigan", comment: "US state")
        case .minnesota: return NSLocalizedString("Minnesota", comment: "US state")
        case .missouri: return NSLocalizedString("Missouri", comment: "US state")
        case .mississippi: return NSLocalizedString("Mississippi", comment: "US state")
        case .montana: return NSLocalizedString("Montana", comment: "US state")
        case .northCarolina: return NSLocalizedString("North Carolina", comment: "US state")
        case .northDakota: return NSLocalizedString("North Dakota", comment: "US state")
        case .nebraska: return NSLocalizedString("Nebraska", comment: "US state")
        case .newHampshire: return NSLocalizedString("New Hampshire", comment: "US state")
        case .newJersey: return NSLocalizedString("New Jersey", comment: "US state")
        case .newMexico: return NSLocalizedString("New Mexico", comment: "US state")
        case .nevada: return NSLocalizedString("Nevada", comment: "US state")
        case .newYork: return NSLocalizedString("New York", comment: "US state")
        case .ohio: return NSLocalizedString("Ohio", comment: "US state")
        case .oklahoma: return NSLocalizedString("Oklahoma", comment: "US state")
        case .oregon: return NSLocalizedString("Oregon", comment: "US state")
        case .pennsylvania: return NSLocalizedString("Pennsylvania", comment: "US state")
//        case .puertoRico: return NSLocalizedString("Puerto Rico", comment: "US state")
        case .rhodeIsland: return NSLocalizedString("Rhode Island", comment: "US state")
        case .southCarolina: return NSLocalizedString("South Carolina", comment: "US state")
        case .southDakota: return NSLocalizedString("South Dakota", comment: "US state")
        case .tennessee: return NSLocalizedString("Tennessee", comment: "US state")
        case .texas: return NSLocalizedString("Texas", comment: "US state")
        case .utah: return NSLocalizedString("Utah", comment: "US state")
        case .virginia: return NSLocalizedString("Virginia", comment: "US state")
//        case .virginIslands: return NSLocalizedString("Virgin Islands", comment: "US state")
        case .vermont: return NSLocalizedString("Vermont", comment: "US state")
        case .washington: return NSLocalizedString("Washington", comment: "US state")
        case .wisconsin: return NSLocalizedString("Wisconsin", comment: "US state")
        case .westVirginia: return NSLocalizedString("WestVirginia", comment: "US state")
        case .wyoming: return NSLocalizedString("Wyoming", comment: "US state")
        }
    }
    
}

public protocol StatePickerDelegate: class {
    func didSelectState(state: USState, statePicker: StatePicker)
}

public class StatePicker: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        dataSource = self
    }
    
    public func setUSState(state: USState) {
        guard let index = usStates.firstIndex(of: state) else { return }
        selectedRow(inComponent: index)
    }
    
    private var usStates: [USState] = USState.allCases
    
    public weak var statePickerDelegate: StatePickerDelegate?
    
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return usStates.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return usStates[row].localizedString
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        statePickerDelegate?.didSelectState(state: usStates[row], statePicker: self)
    }
    
}
