//
//  CellInventorySummary.swift
//  NMBusinessModules
//
//  Created by Nazif MASMANACI on 4.05.2021.
//  Copyright © 2021 Turkish Technic. All rights reserved.
//

import UIKit
import NMBaseModel
import NMBaseView

class CellInventorySummary: UITableViewCell, ConfigurableCell, ThemeApplierListener {
    @IBOutlet weak var opacityView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var avaliableLabel: UILabel!
    @IBOutlet weak var reservedLabel: UILabel!
    @IBOutlet weak var transferLabel: UILabel!
    @IBOutlet weak var pendingLabel: UILabel!
    @IBOutlet weak var usLabel: UILabel!
    @IBOutlet weak var repairLabel: UILabel!
    
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
        guard let itemViewModel = itemViewModel as? InventorySummaryItemVM else { return }
        locationLabel.text = itemViewModel.location
        avaliableLabel.text = itemViewModel.available
        reservedLabel.text = itemViewModel.reserved
        transferLabel.text = itemViewModel.transfer
        pendingLabel.text = itemViewModel.pending
        usLabel.text = itemViewModel.us
        repairLabel.text = itemViewModel.repair
    }
    
    func apply(theme: Theme) {
        opacityView.backgroundColor = theme.cellOpacityColor
        locationLabel.textColor = theme.textColor
        avaliableLabel.textColor = theme.textColor
        reservedLabel.textColor = theme.textColor
        transferLabel.textColor = theme.textColor
        pendingLabel.textColor = theme.textColor
        usLabel.textColor = theme.textColor
        repairLabel.textColor = theme.textColor
    }
}
