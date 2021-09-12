//
//  InventoryVM.swift
//  NMBusinessModules
//
//  Created by Nazif MASMANACI on 4.05.2021.
//  Copyright © 2021 Turkish Technic. All rights reserved.
//

import Foundation
import TTBaseApp
import TTBaseModel

open class InventoryVM: BaseListViewModel<InventoryDetailItemViewModel> {
    private var airCrafts = [AcMaster]()
    private let companies = ConstantInventory.companies.compactMap { CompanyItemViewModel($0) }

    private var pnMaster: PnMaster? {
        didSet {
            inventorySummaryViewModel.pnMaster = pnMaster
            inventoryDetailViewModel.pnMaster = pnMaster
            guard let pnMaster = pnMaster else { return }
            let chapter = pnMaster.chapter ?? 0
            let section = pnMaster.section ?? 0
            let description = pnMaster.pnDescription ?? ""
            pnInfo.value = String(format: ConstantInventory.pnInfoFormat, chapter, section, description)
        }
    }
    
    let inventoryType = Dynamic(InventoryType.stock)
    let pn: Dynamic<String?> = Dynamic(nil)
    let sn: Dynamic<String?> = Dynamic(nil)
    let location: Dynamic<String?> = Dynamic(nil)
    let airCraft: Dynamic<String?> = Dynamic(nil)
    let company: Dynamic<String?> = Dynamic(nil)
    let pnInfo = Dynamic(String(format: ConstantInventory.pnInfoFormat, 0, 0, ""))

    let inventorySummaryViewModel = InventorySummaryVM()
    let inventoryDetailViewModel = InventoryDetailVM()
    
    let segmentMenuViewModel = SegmentMenuViewModel()
    private let summarySegmentMenuItemViewModel = SegmentMenuItemViewModel(title: ConstantInventory.stock)
    private let detailSegmentMenuItemViewModel = SegmentMenuItemViewModel(title: ConstantInventory.detail)
    
    // MARK: - Routers
    var routeToSelectable: Dynamic<SelectableViewModel?> = Dynamic(nil)
    
    deinit {
        print("***** deinit \(String(describing: InventoryVM.self))")
    }
    
    public override init() {
        super.init()
        segmentMenuViewModel.items = [summarySegmentMenuItemViewModel, detailSegmentMenuItemViewModel]
        
        getAirCrafts { [weak self] in
            guard let `self` = self else { return }
            self.airCrafts = $0
        }
    }
    
    typealias AirCraftCompletion = ([AcMaster]) -> Void
    func getAirCrafts(completion: @escaping AirCraftCompletion) {
        dispatchGroup.enter()
        state.value = .loading
        
        service.getAirCrafts { [weak self] in
            guard let `self` = self else { return }
            completion(self.handle(result: $0)?.acMasters ?? [])
            self.dispatchGroup.leave()
        }.disposed(by: disposeBag)
    }
    
    func getData() {
        guard let pn = pn.value, !pn.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showError(title: ConstantInventory.Alert.warning, message: ConstantInventory.pnNotValid)
            return }
        
        getPnMaster()
        
        let inventoryDetail = InventoryDetail()
        inventoryDetail.pn = pn.trimmingCharacters(in: .whitespacesAndNewlines)
        inventoryDetail.sn = sn.value
        inventoryDetail.location = location.value
        inventoryDetail.installedAc = airCraft.value
        inventoryDetail.company = company.value
        
        inventorySummaryViewModel.inventoryDetail = inventoryDetail
        inventoryDetailViewModel.inventoryDetail = inventoryDetail
        
        switch inventoryType.value {
        case .stock:
            inventorySummaryViewModel.getData()
        case .detail:
            inventoryDetailViewModel.getData()
        }
    }

    func getPnMaster() {
        let pnMaster = PnMaster()
        pnMaster.pn = pn.value
        service.pnMaster(with: pnMaster) { [weak self] in
            guard let `self` = self else { return }
            if let data = self.handle(result: $0, withSetState: false) {
                self.pnMaster = data.pnInfo
                self.stateSuccess()
            }
        }.disposed(by: disposeBag)
    }
    
    func segmentDidSelected(at index: Int) {
        inventoryType.value = InventoryType.init(rawValue: index) ?? .stock
        
        if case .stock = inventoryType.value {
            sn.value = nil
            airCraft.value = nil
        }
    }
    
    func pnChanged(_ text: String?) {
        pn.value = text
    }
    
    func snChanged(_ text: String?) {
        sn.value = text
    }
    
    func locationChanged(_ text: String?) {
        location.value = text
    }
    
    func airCraftSelection() {
        let items = airCrafts.compactMap { SelectableItemViewModel(model: $0, key: $0.ac, value: "") }
        let viewModel = SelectableViewModel(items: items)
        viewModel.selectedItem.bind { [unowned self] in
            guard let selected = $0 else {
                self.airCraft.value = nil
                return
            }
            self.airCraft.value = selected.key
        }.disposed(by: disposeBag)
        routeToSelectable.value = viewModel
    }
    
    func companySelection() {
        let items = companies.compactMap { SelectableItemViewModel(model: $0, key: $0.company, value: "") }
        let viewModel = SelectableViewModel(items: items)
        viewModel.selectedItem.bind { [unowned self] in
            guard let selected = $0 else {
                self.company.value = nil
                return
            }
            self.company.value = selected.key
        }.disposed(by: disposeBag)
        routeToSelectable.value = viewModel
    }
}

extension InventoryVM {
    class CompanyItemViewModel: Model {
        let company: String
        
        init(_ company: String) {
            self.company = company
        }
    }
    
    enum InventoryType: Int {
        case stock = 0
        case detail = 1
    }
}
