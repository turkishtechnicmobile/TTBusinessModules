//
//  CellInventoryControl.swift
//  NMBusinessModules
//
//  Created by Nazif MASMANACI on 4.05.2021.
//  Copyright © 2021 Turkish Technic. All rights reserved.
//

import UIKit
import NMBaseModel
import NMBaseView

class CellInventoryControl: UITableViewCell, ConfigurableCell, ThemeApplierListener {
    
    @IBOutlet var labelList: [UILabel]!
    @IBOutlet var stackList: [UIStackView]!
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    var themeApplier: ThemeApplier?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTheme()
    }

    static var nibName: String {
        return String(describing: classForCoder().self)
    }

    static var identifier: String {
        return String(describing: classForCoder().self)
    }
    
    func configure(with itemViewModel: ItemViewModel) {
        guard let itemViewModel = itemViewModel as? InventoryControlItemVM else { return }
        var offset = 0
        itemViewModel.items.forEach {
            labelList[offset].text = $0.key
            labelList[offset + 1].text = $0.value
            offset += 2
        }
        
        (0..<itemViewModel.items.count).forEach {
            stackList[$0].isHidden = false
            stackList[$0].distribution = itemViewModel.fillProportional ? .fill : .fillEqually
            stackList[$0].spacing = itemViewModel.fillProportional ? 16 : 0
        }
        (itemViewModel.items.count..<4).forEach { stackList[$0].isHidden = true }
        
        seperatorView.isHidden = !itemViewModel.showSeperator
        bottomLayoutConstraint.constant = itemViewModel.bottomSpace ?? 16
        labelList.first?.font = labelList.first?.font.withSize( itemViewModel.fontSize ?? 16)
        labelList.first?.textColor = itemViewModel.bottomSpace == 0 ? ThemeManager.shared.updateButtonBackgroundColor : ThemeManager.shared.textColor
    }
    
    func apply(theme: Theme) {
        labelList.forEach { $0.textColor = theme.textColor}
    }
}


