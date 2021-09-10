//
//  AppCoordinator.swift
//  NMBusinessModules
//
//  Created by MnzfM on 8.03.2021.
//


import UIKit
import TTBaseModel

open class BaseAppCoordinator: NSObject, Coordinator {
    struct Storyboard {
  
        static let flightSchedule = "FlightSchedule"
        static let inventory = "Inventory"
        static let assistant = "AssistantBusiness"
    }
    
    // MARK: - Storyboard

    private static func flightScheduleStoryboard() -> UIStoryboard {
        
    //    let storyboardName = "StoryboardName"
        let storyboardBundle = Bundle(for: self)
        return UIStoryboard(name: Storyboard.flightSchedule, bundle: storyboardBundle)
        
      //  return UIStoryboard(name: Storyboard.flightSchedule, bundle: nil)
    }
    
    private static func inventoryStoryboard() -> UIStoryboard {
       
        let storyboardBundle = Bundle(for: self)
        return UIStoryboard(name: Storyboard.inventory, bundle: storyboardBundle)
    }
    
    private static func assistantStoryboard() -> UIStoryboard {
       
        let storyboardBundle = Bundle(for: BaseAppCoordinator.self)
        return UIStoryboard(name: Storyboard.assistant, bundle: storyboardBundle)
    }
    
    public static func segmentCollectionViewController() -> SegmentCollectionViewController {
        return SegmentCollectionViewController()
    }
    
    public static func selectableViewController() -> SelectableViewController {
        return assistantStoryboard().instance(of: SelectableViewController.self)
    }

}

// MARK: - Flight Schedule
extension BaseAppCoordinator {
    
    public static func flightScheduleSegmentViewController() -> FS1_FirstStepSegmentVC {
        
        return flightScheduleStoryboard().instance(of: FS1_FirstStepSegmentVC.self)
    }
    
    static func flightScheduleListViewController() -> FS1_FirstStepSegmentItemVC {
        return flightScheduleStoryboard().instance(of: FS1_FirstStepSegmentItemVC.self)
    }
}


// MARK: - Inventory
extension BaseAppCoordinator {
    
    public static func inventoryViewController() -> InventoryVC {
        return inventoryStoryboard().instance(of: InventoryVC.self)
    }
    
    static func inventorySummaryVC() -> InventorySummaryVC {
        return inventoryStoryboard().instance(of: InventorySummaryVC.self)
    }
    
    static func inventoryDetailVC() -> InventoryDetailVC {
        return inventoryStoryboard().instance(of: InventoryDetailVC.self)
    }
    
    static func inventoryControlVC() -> InventoryControlVC {
        return inventoryStoryboard().instance(of: InventoryControlVC.self)
    }
}
