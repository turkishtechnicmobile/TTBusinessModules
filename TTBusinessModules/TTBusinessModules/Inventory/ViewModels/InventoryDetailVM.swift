//
//  InventoryDetailVM.swift
//  NMBusinessModules
//
//  Created by Nazif MASMANACI on 4.05.2021.
//  Copyright © 2021 Turkish Technic. All rights reserved.
//

import Foundation
import NMBaseModel

class InventoryDetailVM: BaseListViewModel<InventoryDetailItemViewModel> {
    var pnMaster: PnMaster?
    var inventoryDetail: InventoryDetail?
    var title: String {
        guard let pnMaster = pnMaster else { return "" }
        let pn = pnMaster.pn ?? ""
        let pnDescription = pnMaster.pnDescription ?? ""
        return String(format: "%@ - %@", pn, pnDescription)
    }
    
    func getData() {
        guard let inventoryDetail = inventoryDetail else { return }
        
        state.value = .loading
        service.inventoryDetails(with: inventoryDetail) { [weak self] in
            guard let `self` = self else { return }
            if let data = self.handle(result: $0, withSetState: false) {
                self.items = data.details.compactMap { InventoryDetailItemViewModel($0) }
                self.stateSuccess()
            }else {
                self.state.value = .error
            }
        }.disposed(by: disposeBag)
    }
    
    func getInventoryControlViewModel(at indexPath: IndexPath) -> InventoryControlVM {
        // TODO: optional value unwrapped !!!
        let selectedItem = item(at: indexPath)
        let controlViewModel = InventoryControlVM(pnMaster: pnMaster!, inventoryDetail: selectedItem.detail)
        return controlViewModel
    }
}

public class InventoryDetailItemViewModel: BaseItemViewModel {
    let detail: InventoryDetail
    
    var batch: String {
//        return "Batch: \(inventoryDetail.batch ?? 0)"
        return String(format: ConstantInventory.Detail.batchFormat, detail.batch ?? 0)
    }
    var location: String {
//        return "Location: \(getTextValue(for: \.location))"
        return String(format: ConstantInventory.Detail.locationFormat, detail.location ?? "")
    }
    var ac: String {
//        return "A/C: \(getTextValue(for: \.installedAc))"
        return String(format: ConstantInventory.Detail.acFormat, detail.installedAc ?? "")
    }
    var sn: String {
//        return "S/N: \(getTextValue(for: \.sn))"
        return String(format: ConstantInventory.Detail.snFormat, detail.sn ?? "")
    }
    var company: String {
//        return "Company: \(getTextValue(for: \.company))"
        return String(format: ConstantInventory.Detail.companyFormat, detail.company ?? "")
    }
    var condition: String {
//        return "Condition: \(getTextValue(for: \.condition))"
        return String(format: ConstantInventory.Detail.conditionFormat, detail.condition ?? "")
    }
    
    var detailInfo: String {
        return String(format: ConstantInventory.Detail.infoFormat, getDoubleValue(for: \.qtyAvailable), getDoubleValue(for: \.qtyReserved), getDoubleValue(for: \.qtyInTransfer), getDoubleValue(for: \.qtyPendingRi), getDoubleValue(for: \.qtyUs), getDoubleValue(for: \.qtyInRepair))
    }

    init(_ detail: InventoryDetail) {
        self.detail = detail
    }
    
    private func getTextValue(for keyPath: KeyPath<InventoryDetail, String?>) -> String {
        return detail[keyPath: keyPath] ?? ""
    }
    
    private func getDoubleValue(for keyPath: KeyPath<InventoryDetail, Double?>) -> Double {
        return detail[keyPath: keyPath] ?? 0
    }
}
