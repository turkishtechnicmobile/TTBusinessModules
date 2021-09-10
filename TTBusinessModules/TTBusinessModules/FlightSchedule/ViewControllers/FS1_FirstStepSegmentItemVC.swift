//
//  FS1_FirstStepSegmentItemVC.swift
//  NMBusinessModules
//
//  Created by MnzfM on 5.03.2021.
//  Copyright © 2018 Turkish Technic. All rights reserved.

import UIKit
import TTBaseModel
import TTBaseService
import TTBaseView

protocol FS1_FirstStepSegmentItemVCDelegate {
    func filter(with filter: FSFilter)
}

enum FSSegmentItemType {
    case departure
    case arrival
}

class FS1_FirstStepSegmentItemVC: BaseViewController {
    @IBOutlet weak var mainTableView: UITableView!
    
    var flights = [FlightArrivalOrDeparture]()
    private var updateTimer: Timer?
    typealias RepairCompletion = (String) -> Void
    var repairActionHandler: RepairCompletion?
    
    var vcType: FSSegmentItemType!
   
    private var filter: FSFilter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTableView.refreshControl = refreshControl
        mainTableView.rowHeight = 125
        mainTableView.allowsSelection = false
        mainTableView.tableFooterView = UIView()
        mainTableView.separatorInset = UIEdgeInsets(top: 0, left: 91, bottom: 0, right: 0)
        mainTableView.register(UINib(nibName: CellFSListItem.className,bundle: Bundle(for: self.classForCoder)),
                               forCellReuseIdentifier: CellFSListItem.className)
        
        refresh()
    }
    
    public override func apply(theme: Theme) {
        super.apply(theme: theme)
        
        self.view.backgroundColor = theme.backgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        updateTimer?.invalidate()
    }
    
    func getItemListOnSuccess(flights:[FlightArrivalOrDeparture], udValue:String){
        self.flights = flights
        mainTableView.reloadData()
        mainTableView.backgroundView = flights.isEmpty ? noResultsFoundLabel : nil
    }
    
    
    @objc
    override func refresh() {
        super.refresh()
        self.getData()
    }
}

// MARK: - TableViewDelegate Methods
extension FS1_FirstStepSegmentItemVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flights.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellFSListItem.className) as! CellFSListItem
        let source = flights[indexPath.row]
        let hour = vcType == FSSegmentItemType.departure ? source.scheduleDate:source.arrivalDate
        
        cell.setCell(item: source, vcType: self.vcType, hour: hour!)
        cell.repairActionHadler = repairActionHandler
        
        if indexPath.row > 0 { // arrivaldate ayrımı var kontrol et.
            
            let hourPrev =  self.vcType == FSSegmentItemType.departure ? flights[indexPath.row - 1].scheduleDate : flights[indexPath.row - 1].arrivalDate
            
            if Date.hour(hour!) ==  Date.hour(hourPrev!) {
                cell.leftSideImage.isHidden = true
                cell.leftSideTailImage.isHidden = false
                cell.dateLabel.isHidden = true
            }
        }
        
        return cell
    }
    
}

extension FS1_FirstStepSegmentItemVC: FS1_FirstStepSegmentItemVCDelegate {
    
    func filter(with filter: FSFilter) {
        self.filter = filter
        guard isViewLoaded else {
            return
        }
        getData()
    }
    
    
    private func getData() {
        guard let filter = filter else { return }
        
        let origin = filter.origin ?? ""
        let destination = filter.destination ?? ""
        let ac = filter.airCraft ?? ""
        let fleet = filter.getAcType()
        
        let requestModel = FlightRequest(isDeparture: vcType == FSSegmentItemType.departure, origin: origin, destination: destination, ac: ac, fleet: fleet)
        
        showLoadingView()
        
//        service.execute(path: vcType == FSSegmentItemType.departure ? .getFlightDeparture : .getFlightArrival, method: .get, requestObject: requestModel, responseType: FlightResponse.self, options:[.debugPrint]) { [weak self] in
        
        
        service.execute(path: .getFlightSchedule, requestObject: requestModel, responseType: ResponseFlightSchedule.self, options:[.debugPrint]) { [weak self] in
            guard let `self` = self else { return }
            self.removeLoadingView()
            self.refreshControl.endRefreshing()
            if case .success(let result) = $0 {

                self.getItemListOnSuccess(flights: (self.vcType == .departure ? result.data.flights!: result.data.flights!), udValue: origin)
            }
        }
        
    }
}

