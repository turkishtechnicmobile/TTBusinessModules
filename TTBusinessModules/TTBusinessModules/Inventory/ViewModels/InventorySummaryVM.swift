//
//  InventorySummaryVM.swift
//  NMBusinessModules
//
//  Created by Nazif MASMANACI on 4.05.2021.
//  Copyright © 2021 Turkish Technic. All rights reserved.
//

import Foundation
import TTBaseModel

class InventorySummaryVM: BaseListViewModel<InventorySummaryItemVM> {
    var pnMaster: PnMaster?
    var inventoryDetail: InventoryDetail?
    
    func getData() {
        guard let inventoryDetail = inventoryDetail else { return }
        
        state.value = .loading
        service.inventorySummaries(with: inventoryDetail) { [weak self] in
            guard let `self` = self else { return }
            if let data = self.handle(result: $0, withSetState: false) {
                self.items = data.summaries.compactMap { InventorySummaryItemVM($0) }
                self.stateSuccess()
            }else {
                self.state.value = .error
            }
        }.disposed(by: disposeBag)
    }
    
    func getInventoryDetailVM(at indexPath: IndexPath) -> InventoryDetailVM {
        let newDetail = InventoryDetail()
        newDetail.pn = inventoryDetail?.pn
        newDetail.company = inventoryDetail?.company
        newDetail.location = item(at: indexPath).inventorySummary.location
        
        let detailViewModel = InventoryDetailVM()
        detailViewModel.pnMaster = pnMaster
        detailViewModel.inventoryDetail = newDetail
        return detailViewModel
    }
}

class InventorySummaryItemVM: BaseItemViewModel {
    let inventorySummary: InventorySummary
    
    var location: String {
        return String(format: ConstantInventory.Summary.locationFormat, inventorySummary.location ?? "")
    }
    var available: String {
        return String(format: ConstantInventory.Summary.availableFormat, inventorySummary.available ?? 0)
    }
    var reserved: String {
        return String(format: ConstantInventory.Summary.reservedFormat, inventorySummary.reserved ?? 0)
    }
    var transfer: String {
        return String(format: ConstantInventory.Summary.transferFormat, inventorySummary.inTransfer ?? 0)
    }
    var pending: String {
        return String(format: ConstantInventory.Summary.pendingFormat, inventorySummary.pending ?? 0)
    }
    var us: String {
        return String(format: ConstantInventory.Summary.usFormat, inventorySummary.us ?? 0)
    }
    var repair: String {
        return String(format: ConstantInventory.Summary.repairFormat, inventorySummary.inRepair ?? 0)
    }

    init(_ inventorySummary: InventorySummary) {
        self.inventorySummary = inventorySummary
    }
    
    private func getIntValue(for keyPath: KeyPath<InventorySummary, Double?>) -> Double {
        return inventorySummary[keyPath: keyPath] ?? 0
    }
}
