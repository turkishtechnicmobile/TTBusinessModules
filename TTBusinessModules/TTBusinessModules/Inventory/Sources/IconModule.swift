//
//  IconModule.swift
//  NMBusinessModules
//
//  Created by Nazif MASMANACI on 5.05.2021.
//  Copyright © 2021 Turkish Technic. All rights reserved.
//

import UIKit

open class InventoryAssets: NSObject {

    class func bundledImage(named name: String) -> UIImage {
        let primaryBundle = Bundle(for: InventoryAssets.self)
        if let image = UIImage(named: name, in: primaryBundle, compatibleWith: nil) {
            
            return image // Load image in cases where NMBusinessModules is directly integrated
        } else if
            let subBundleUrl = primaryBundle.url(forResource: "inventory", withExtension: "bundle"),
            let subBundle = Bundle(url: subBundleUrl),
            let image = UIImage(named: name, in: subBundle, compatibleWith: nil)
        {
            
            return image // Load image in cases where NMBusinessModules is integrated via cocoapods as a dynamic or static framework with a separate resource bundle
        }

        return UIImage()
    }
}

public enum IconInventory: String {

    case searchIcon = "search-icon"
    case filterIcon = "filter-icon"

    func getImg() -> UIImage? {

        return InventoryAssets.bundledImage(named: self.rawValue)
    }
}
