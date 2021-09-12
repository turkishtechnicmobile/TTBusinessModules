//
//  CellInventoryDetail.swift
//  NMBusinessModules
//
//  Created by Nazif MASMANACI on 4.05.2021.
//  Copyright © 2021 Turkish Technic. All rights reserved.
//

import UIKit
import TTBaseModel
import TTBaseView

class CellInventoryDetail: UITableViewCell, ConfigurableCell, ThemeApplierListener {
    @IBOutlet weak var opacityView: UIView!
    @IBOutlet weak var batchLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var acLabel: UILabel!
    @IBOutlet weak var snLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var detailInfoLabel: UILabel!
    
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
        guard let itemViewModel = itemViewModel as? InventoryDetailItemViewModel else { return }
        batchLabel.text = itemViewModel.batch
        locationLabel.text = itemViewModel.location
        acLabel.text = itemViewModel.ac
        snLabel.text = itemViewModel.sn
        companyLabel.text = itemViewModel.company
        conditionLabel.text = itemViewModel.condition
        detailInfoLabel.text = itemViewModel.detailInfo
    }
    
    func apply(theme: Theme) {
        opacityView.backgroundColor = theme.cellOpacityColor
        batchLabel.textColor = theme.textColor
        locationLabel.textColor = theme.textColor
        acLabel.textColor = theme.textColor
        snLabel.textColor = theme.textColor
        companyLabel.textColor = theme.textColor
        conditionLabel.textColor = theme.textColor
        detailInfoLabel.textColor = theme.textColor
    }
}
