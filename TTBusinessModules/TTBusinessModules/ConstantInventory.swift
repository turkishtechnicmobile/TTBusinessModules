//
//  ConstantInventory.swift
//  NMBusinessModules
//
//  Created by Nazif MASMANACI on 4.05.2021.
//  Copyright © 2021 Turkish Technic. All rights reserved.
//

import Foundation
import TTBaseApp

class ConstantInventory: ConstantManager {
    
    static let pn = "P/N"
    static let sn = "S/N"
    static let location = "Location"
    static let ac = "A/C"
    static let company = "Company"
    static let companies = ["ALL", "TKAO", "TTAS"]
    
    static let pnInfoFormat = "Chapter: %1d      Section: %1d    %@"
    static let stock = "STOCK"
    static let detail = "DETAIL"
    static let pnNotValid = "P/N can not be empty!"
    

    struct Message {
        static let noResultsFound = "No results found"
        static let loading = "Loading..."
    }
    
    struct Alert {
        static let info = "Info"
        static let warning = "Warning"
        static let error = "Error"
    }
    
    struct Hamburger {
        static let inventory = "INVENTORY"
    }
    
    struct Action {
//        static let done = "Done"
        static let ok = "OK"
        static let cancel = "Cancel"
        static let select = "SELECT"
//        static let notNow = "Not Now"
//        static let giveAccess = "Give Access"
//        static let settings = "Settings"
    }
    
    struct Detail {
        static let title = "INVENTORY DETAIL"
        static let batchFormat = "Batch: %1d"
        static let locationFormat = "Location: %@"
        static let acFormat = "A/C: %@"
        static let snFormat = "S/N: %@"
        static let companyFormat = "Company: %@"
        static let conditionFormat = "Condition: %@"
        static let infoFormat =  "Avaliable: %.0f   Reserved: %.0f   InTransfer: %.0f   Pending: %.0f   U/S: %.0f   InRepair: %.0f"
    }
    
    struct Control {
        static let general = "GENERAL"
        static let batch = "BATCH:"
        static let pn = "PN:"
        static let sn = "SN:"
        static let description = "DESCRIPTION:"
        static let model = "MODEL:"
        static let category = "CATEGORY:"
        static let subCategory = "SUB-CAT:"
        static let condition = "CONDITION:"
        static let stockUom = "U.O.M:"
        static let maintenanceControl = "MAIN. CNTRL:"
        static let owner = "OWNER:"
        static let chapter = "CHAPTER:"
        static let section = "SECTION:"
        static let pnTotalTimes = "PN TOTAL TIMES"
        static let days = "DAYS:"
        static let hours = "HOURS:"
        static let minutes = "MINUTES:"
        static let cycles = "CYCLES:"
        static let inventory = "INVENTORY"
        static let location = "LOCATION:"
        static let bin = "BIN:"
        static let available = "AVAILABLE:"
        static let reserved = "RESERVED:"
        static let transfer = "TRANSFER:"
        static let pending = "PENDING:"
        static let us = "U/S:"
        static let repair = "REPAIR:"
        static let rental = "RENTAL:"
        static let inventoryControl = "INVENTORY CONTROL"
        static let control = "CONTROL:"
        static let resetDate = "RESET DATE:"
        static let scheduleTitle = "SCHEDULE"
        static let scheduleHours = "HOURS:"
        static let scheduleDate = "DATE:"
        static let scheduleCycles = "CYCLES:"
        static let scheduleDays = "DAYS:"
        static let actualTitle = "ACTUAL"
        static let actualHours = "HOURS:"
        static let actualMinutes = "MINUTES:"
        static let actualCycles = "CYCLES:"
        static let actualDays = "DAYS:"
        static let remainingDays = "REMAINING DAYS:"
        static let createdBy = "CREATED BY:"
        static let createdDate = "CREATED DATE:"
        static let modifiedBy = "MODIFIED BY:"
        static let modifiedDate = "MODIFIED DATE:"
    }
    
    struct Summary {
        static let locationFormat = "Location: %@"
        static let availableFormat = "Avaliable: %.0f"
        static let reservedFormat = "Reserved: %.0f"
        static let transferFormat = "Transfer: %.0f"
        static let pendingFormat = "Pending: %.0f"
        static let usFormat = "U/S: %.0f"
        static let repairFormat = "Repair: %.0f"
    }

}
