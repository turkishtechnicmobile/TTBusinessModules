//
//  FS1_FirstStepSegmentVC.swift
//  NMBusinessModules
//
//  Created by MnzfM on 5.03.2021.
//  Copyright © 2018 Turkish Technic. All rights reserved.


import UIKit
import TTBaseView
import TTBaseModel

class FSFilter {
    var airCraft: String?
    var origin: String?
    var destination: String?
    var fleet: String?
    
    init() {
    }
    
    func getAcType() -> String {
        guard let fleet = fleet else { return ConstantFS.empty }
        return ["A318", "A319", "A320", "A321"].contains(fleet) ? "A320F" : fleet
    }
    
    
}

extension FSFilter {
    enum FilterType {
        case defectReport
        case defectReportArchive
        case flightSchedule
    }
    
    class FleetItemViewModel: Model {
        let fleet: String
        
        init(_ fleet: String) {
            self.fleet = fleet
        }
    }
}


public class FS1_FirstStepSegmentVC: BaseViewController {

    @IBOutlet weak var nsOrigin: NSelectableView!
    @IBOutlet weak var nsDestination: NSelectableView!
    @IBOutlet weak var nsAC: NSelectableView!
    @IBOutlet weak var nsFleet: NSelectableView!
    @IBOutlet weak var btnSearch: UIButton!
    
    
    // MARK: - Variables
    var fleets = [String]()
    let titles = ["Departure", "Arrival"]
    private var viewControllers = [FS1_FirstStepSegmentItemVC]()
    private var delegates = [FS1_FirstStepSegmentItemVCDelegate]()
    
    private var fsFilter: FSFilter!

    private var segmentedContainer: NSegmentedContainer?
    
    public var cellBtnClicked:((String)->Void)?

    let filter: FSFilter = {
        let filter = FSFilter()
        filter.origin = ConstantFS.flightScheduleOrigin
        return filter
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        barNav.setBar(type: .onlyHamburger, vc: self, title: ConstantFS.Hamburger.flightSchedule)
 
        nsOrigin.fullButton()
        nsDestination.fullButton()
        nsAC.fullButton()
        nsFleet.fullButton()
        
        self.getAllLocations {}
        self.getAllFlightList {}
        
        self.nsOrigin.setSourceString(stringArray: self.persistent.locations)
        self.nsDestination.setSourceString(stringArray: self.persistent.locations)
        self.nsAC.setSourceString(stringArray: self.persistent.airCrafts)
        self.nsFleet.setSourceString(stringArray: ConstantFS.fleets)

        self.adjustScreen()
        segmentedContainer?.segmentChanged = { [unowned self] in
            self.didChangeSegment($0)
        }
    }
    
    func adjustScreen(){
        
        nsOrigin.delegate = self
        nsDestination.delegate = self
        nsAC.delegate = self
        nsFleet.delegate = self
        
        nsOrigin.setInitValue(title: ConstantFS.flightScheduleOrigin,
                              buttonText: ConstantFS.flightScheduleOrigin,
                              defaultValue: ConstantFS.flightScheduleOrigin,
                              isEditibleBtn: true,showClearBtn: true)
        
        nsDestination.setInitValue(title: "",
                                   buttonText: ConstantFS.Filter.destination,
                                   defaultValue: ConstantFS.Filter.destination,
                                   isEditibleBtn: true,showClearBtn: true)
        
        nsAC.setInitValue(title: "",
                          buttonText: ConstantFS.Filter.airCraft,
                          defaultValue: ConstantFS.Filter.airCraft,
                          isEditibleBtn: true,showClearBtn: true)
        
        nsFleet.setInitValue(title: "",
                             buttonText: ConstantFS.Filter.fleet,
                             defaultValue: ConstantFS.Filter.fleet,
                             isEditibleBtn: true,showClearBtn: true)
                
        nsOrigin.setShowType(showListType: .showValue, showReturnType: .showValue)
        nsDestination.setShowType(showListType: .showValue, showReturnType: .showValue)
        nsAC.setShowType(showListType: .showValue, showReturnType: .showValue)
        nsFleet.setShowType(showListType: .showValue, showReturnType: .showValue)
        
    }
    
    public override func apply(theme: Theme) {
        super.apply(theme: theme)
        if let segmentedContainer = segmentedContainer {
            segmentedContainer.viewMode = theme.style.isLight() ? .light : .dark
            
            if theme.style.isLight() {

                segmentedContainer.viewMode = .light
            }else if theme.style.isDark() {

                segmentedContainer.viewMode = .dark
            }else {

               segmentedContainer.viewMode = .mobilCabin
            }
        }
    }
    
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "myEmbeddedSegue") {
            let childViewController = segue.destination as! NSegmentedContainer
            
            let firstSegmentItem = BaseAppCoordinator.flightScheduleListViewController()
            firstSegmentItem.vcType = FSSegmentItemType.departure
            delegates.append(firstSegmentItem)
            firstSegmentItem.repairActionHandler = { [unowned self] in
                self.showDefectReports(with: $0)
            }
            firstSegmentItem.filter(with: filter)
            
            let secondSegmentItem = BaseAppCoordinator.flightScheduleListViewController()
            secondSegmentItem.vcType = FSSegmentItemType.arrival
            delegates.append(secondSegmentItem)
            secondSegmentItem.repairActionHandler = { [unowned self] in
                self.showDefectReports(with: $0)
            }
            secondSegmentItem.filter(with: filter)
            
            viewControllers = [firstSegmentItem,secondSegmentItem]
            childViewController.setViewControllers(vcArray: viewControllers, titles: titles, badgeMode: .textBadge)
            segmentedContainer = childViewController
        }
    }
    
    private func apply(filter: FSFilter) {
        fsFilter = filter
        delegates.forEach { $0.filter(with: filter) }
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        delegates.forEach { $0.filter(with: filter) }
    }
    
    func didChangeSegment(_ index: Int) {
        if index == 0 {
            let destination = filter.destination
            filter.destination = filter.origin
            filter.origin = destination
        }
        if index == 1 {
            let origin = filter.origin
            filter.origin = filter.destination
            filter.destination = origin
        }
        viewControllers[index].filter(with: filter)
        
        nsOrigin.setInitValue(title: "",
                              buttonText: filter.origin ?? ConstantFS.Filter.origin,
                              defaultValue: filter.origin ?? ConstantFS.Filter.origin,
                              isEditibleBtn: true,showClearBtn: true)
        
        nsDestination.setInitValue(title: "",
                                   buttonText: filter.destination ?? ConstantFS.Filter.destination,
                              defaultValue: filter.destination ?? ConstantFS.Filter.destination,
                              isEditibleBtn: true,showClearBtn: true)
        
    }
    
    private func showDefectReports(with airCraft: String) {

        cellBtnClicked?(airCraft)
    }
}

//MARK: Data request
extension FS1_FirstStepSegmentVC {
   
    func getAllLocations(successComplition:@escaping() -> Void) {
        
        service.execute(path: .getLocationList, method: .get, requestObject: RequestModelBase(), responseType: LocationResponse.self) { [weak self] in
            guard let `self` = self else { return }
            if case .success(let result) = $0, let locations = result.locations {
                let allLocation = locations.compactMap { Location(location: $0.location, description: $0.locationDesc)}
                let sortedLocation = Location.sortMostUsed(locations: allLocation)
                self.nsOrigin.setSourceString(stringArray: sortedLocation.compactMap({ $0.location}))
                self.nsDestination.setSourceString(stringArray: sortedLocation.compactMap({ $0.location}))
                successComplition()
            }
        }
    }
    
    func getAllFlightList(successComplition:@escaping() -> Void) {

        let requestModel = SmallRequest(status: "ACTIVE", ac: "")
        service.execute(path: .getAllFlightList, method: .get, requestObject: requestModel, responseType: ACResponse.self) { [weak self] in
            guard let `self` = self else { return }
            if case .success(let result) = $0, let acMasters = result.acMasters {

                let airCrafts = acMasters.compactMap { $0.ac }
                self.persistent.airCrafts = airCrafts
                self.nsAC.setSourceString(stringArray: airCrafts)
                successComplition()
            }
        }
    }
}


extension FS1_FirstStepSegmentVC: NSelectableViewDelegate {
    
    public func didSelectedItem(selectableView: NSelectableView, selectedObj: KeyValueObject) {
        
        switch selectableView {
        case nsOrigin: filter.origin = selectedObj.getValue() // print(selectedObj.getValue())
        case nsDestination: filter.destination = selectedObj.getValue() // print(selectedObj.getValue())
        case nsAC: filter.airCraft = selectedObj.getValue() // print(selectedObj.getValue())
        case nsFleet: filter.fleet = selectedObj.getValue() // print(selectedObj.getValue())
        default: break
        }
    }
    
    public func didClearFilter(selectableView: NSelectableView) {
        
        switch selectableView {
        case nsOrigin: filter.origin = nil // print(selectedObj.getValue())
        case nsDestination: filter.destination = nil  // print(selectedObj.getValue())
        case nsAC: filter.airCraft = nil  // print(selectedObj.getValue())
        case nsFleet: filter.fleet = nil  // print(selectedObj.getValue())
        default: break
        }
    }
}
