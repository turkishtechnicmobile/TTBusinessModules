//
//  InventoryControlVM.swift
//  NMBusinessModules
//
//  Created by Nazif MASMANACI on 4.05.2021.
//  Copyright © 2021 Turkish Technic. All rights reserved.
//

import Foundation
import TTBaseModel

class InventoryControlVM: BaseSectionListViewModel<BaseSectionItemViewModel<InventoryControlItemVM>> {
    let pnMaster: PnMaster
    let inventoryDetail: InventoryDetail
    
    var title: String {
        return ConstantInventory.Detail.title
    }
    
    init(pnMaster: PnMaster, inventoryDetail: InventoryDetail) {
        self.pnMaster = pnMaster
        self.inventoryDetail = inventoryDetail
    }
    
    func getData() {
        // First Section
        let batch = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.batch, value: getString(for: inventoryDetail.batch))
        let pn = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.pn, value: inventoryDetail.pn)
        let sn = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.sn, value: inventoryDetail.sn)
        let description = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.description, value: pnMaster.pnDescription)
        let model = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.model, value: inventoryDetail.pnModel)
        let category = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.category, value: pnMaster.category)
        let subCategory = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.subCategory, value: pnMaster.subCategory)
        let condition = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.condition, value: inventoryDetail.condition)
        let stockUom = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.stockUom, value: pnMaster.stockUom)
        let maintenanceControl = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.maintenanceControl, value: pnMaster.maintenanceControl)
        let owner = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.owner, value: inventoryDetail.owner)
        let chapter = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.chapter, value: getString(for: pnMaster.chapter))
        let section = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.section, value: getString(for: pnMaster.section))
        
        let firstSectionRow1 = InventoryControlItemVM(items: [batch, pn, sn])
        let firstSectionRow2 = InventoryControlItemVM(items: [description])
        firstSectionRow2.fillProportional = true
        let firstSectionRow3 = InventoryControlItemVM(items: [model, category, subCategory])
        let firstSectionRow4 = InventoryControlItemVM(items: [condition, stockUom, maintenanceControl])
        let firstSectionRow5 = InventoryControlItemVM(items: [owner, chapter, section])
        
        let firstSection = BaseSectionItemViewModel<InventoryControlItemVM>(headerTitle: ConstantInventory.Control.general)
        firstSection.items = [firstSectionRow1, firstSectionRow2, firstSectionRow3, firstSectionRow4, firstSectionRow5]
        items.append(firstSection)
        
        // Pn Total Times Section
        let secondSection = BaseSectionItemViewModel<InventoryControlItemVM>(headerTitle: ConstantInventory.Control.pnTotalTimes)
        let days = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.days, value: "0")
        let hours = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.hours, value: "0")
        let minutes = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.minutes, value: "0")
        let cycles = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.cycles, value: "0")
        
        secondSection.items = [InventoryControlItemVM(items: [days, hours, minutes, cycles])]
        items.append(secondSection)
        
        // Invrentory Section
        let thirdSection = BaseSectionItemViewModel<InventoryControlItemVM>(headerTitle: ConstantInventory.Control.inventory)
        let location = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.location, value: inventoryDetail.location)
        let bin = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.bin, value: inventoryDetail.bin)
        let available = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.available, value: getString(for: inventoryDetail.qtyAvailable))
        let reserved = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.reserved, value: getString(for: inventoryDetail.qtyReserved))
        let transfer = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.transfer, value: getString(for: inventoryDetail.qtyInTransfer))
        let pending = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.pending, value: getString(for: inventoryDetail.qtyPendingRi))
        let us = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.us, value: getString(for: inventoryDetail.qtyUs))
        let repair = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.repair, value: getString(for: inventoryDetail.qtyInRepair))
        let rental = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.rental, value: getString(for: inventoryDetail.qtyInRental))

        let thirdSectionRow1 = InventoryControlItemVM(items: [location, bin, spacer()])
        let thirdSectionRow2 = InventoryControlItemVM(items: [available, reserved, transfer, pending])
        let thirdSectionRow3 = InventoryControlItemVM(items: [us, repair, rental, spacer()])
        
        thirdSection.items = [thirdSectionRow1, thirdSectionRow2, thirdSectionRow3]
        items.append(thirdSection)
        
        getDataRemaining()
    }
    
    private func getDataRemaining() {
        let inventoryControl = InventoryControl()
        inventoryControl.pn = inventoryDetail.pn
        inventoryControl.sn = inventoryDetail.sn
        
        state.value = .loading
        service.inventoryControls(with: inventoryControl) { [weak self] in
            guard let `self` = self else { return }
            if let data = self.handle(result: $0, withSetState: false) {
                self.handleResult(data)
                self.stateSuccess()
            }else {
                self.state.value = .error
            }
        }.disposed(by: disposeBag)
    }
    
    func handleResult(_ result: InventoryControlResponse) {
        guard let cycle = result.cycles.first else { return }
        // Change Pn Total Times value
        items[1].items[0].items[0].value = getString(for: cycle.days) ?? "0"
        items[1].items[0].items[1].value = getString(for: cycle.hours) ?? "0"
        items[1].items[0].items[2].value = getString(for: cycle.minutes) ?? "0"
        items[1].items[0].items[3].value = getString(for: cycle.cycles) ?? "0"
        
        let lastSection = BaseSectionItemViewModel<InventoryControlItemVM>(headerTitle: ConstantInventory.Control.inventoryControl)
        result.controls.forEach { (item) in
            let control = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.control, value: item.control)
            let resetDate = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.resetDate, value: getString(for: item.resetDate))
            let scheduleTitle = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.scheduleTitle, value: nil)
            let scheduleHours = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.scheduleHours, value: getString(for: item.scheduleHours))
            let scheduleDate = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.scheduleDate, value: getString(for: item.scheduleDate))
            let scheduleCycles = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.scheduleCycles, value: getString(for: item.scheduleCycles))
            let scheduleDays = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.scheduleDays, value: getString(for: item.scheduleDays))
            
            let actualTitle = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.actualTitle, value: nil)
            let actualHours = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.actualHours, value: getString(for: item.hours))
            let actualMinutes = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.actualMinutes, value: getString(for: item.minutes))
            let actualCycles = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.actualCycles, value: getString(for: item.cycles))
            let actualDays = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.actualDays, value: getString(for: item.actualDays))
            let remainingDays = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.remainingDays, value: getString(for: item.remainingDays))
            
            let createdBy = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.createdBy, value: item.createdBy)
            let createdDate = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.createdDate, value: getString(for: item.createdDate))
            let modifiedBy = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.modifiedBy, value: item.modifiedBy)
            let modifiedDate = InventoryControlItemVM.DetailItem(key: ConstantInventory.Control.modifiedDate, value: getString(for: item.modifiedDate))
            
            let row1 = InventoryControlItemVM(items: [control, resetDate])
            let row2 = InventoryControlItemVM(items: [scheduleTitle])
            row2.bottomSpace = 0
            row2.fontSize = 19
            let row3 = InventoryControlItemVM(items: [scheduleHours, scheduleDate, scheduleCycles, scheduleDays])
            let row4 = InventoryControlItemVM(items: [actualTitle])
            row4.bottomSpace = 0
            row4.fontSize = 19
            let row5 = InventoryControlItemVM(items: [actualHours, actualMinutes, actualCycles, actualDays])
            let row6 = InventoryControlItemVM(items: [remainingDays])
            let row7 = InventoryControlItemVM(items: [createdBy, createdDate])
            let row8 = InventoryControlItemVM(items: [modifiedBy, modifiedDate])
            row8.showSeperator = true
            
            [row1, row2, row3, row4, row5, row6, row7, row8].forEach { lastSection.items.append($0)}
        }
        items.append(lastSection)
    }
    
    func getString(for value: Int?) -> String? {
        guard let value = value else { return nil }
        return String(format: "%1d", value)
    }
    
    func getString(for value: Double?) -> String? {
        guard let value = value else { return nil }
        return String(format: "%.0f", value)
    }
    
    func getString(for date: Date?) -> String? {
        guard let date = date else { return nil }
        return dateFormat.format(date: date, with: .dateAndTime)
    }
    
    func spacer() -> InventoryControlItemVM.DetailItem {
        return InventoryControlItemVM.DetailItem(key: "", value: nil)
    }

    func item(at section: Int) -> BaseSectionItemViewModel<InventoryControlItemVM> {
        return items[section]
    }

    func item(at indexPath: IndexPath) -> InventoryControlItemVM {
        return item(at: indexPath.section).item(at: indexPath)
    }

    func titleForHeader(in section: Int) -> String? {
        return item(at: section).headerTitle
    }

    func titleForFooter(in section: Int) -> String? {
        return item(at: section).footerTitle
    }
}


class InventoryControlItemVM: BaseItemViewModel {
    var items: [DetailItem]
    var fillProportional = false
    var showSeperator = false
    var bottomSpace: CGFloat?
    var fontSize: CGFloat?
    
    init(items: [DetailItem]) {
        self.items = items
    }
}

extension InventoryControlItemVM {
    struct DetailItem: ItemViewModel {
        var key: String
        var value: String?
    }
}
