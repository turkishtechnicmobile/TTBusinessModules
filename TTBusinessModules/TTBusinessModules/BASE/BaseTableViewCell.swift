//
//  BaseTableViewCell.swift
//  NMBusinessModules
//
//  Created by Nazif MASMANACI on 4.05.2021.
//  Copyright © 2021 Turkish Technic. All rights reserved.
//

import UIKit
import NMBaseView
import NMBaseModel


class BaseTableViewCell: UITableViewCell, ConfigurableCell, ThemeApplierListener {
    // MARK: - Variables
    var themeApplier: ThemeApplier?
    
    static var nibName: String {
        return String(describing: classForCoder().self)
    }
    
    static var identifier: String {
        return String(describing: classForCoder().self)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        setupTheme()
    }
    
    func apply(theme: Theme) {
        backgroundColor = .clear
    }
    
    func configure(with itemViewModel: ItemViewModel) {
        
    }
}

