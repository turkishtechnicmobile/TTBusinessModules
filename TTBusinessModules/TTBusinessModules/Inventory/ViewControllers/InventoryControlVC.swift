//
//  InventoryControlVC.swift
//  NMBusinessModules
//
//  Created by Nazif MASMANACI on 4.05.2021.
//  Copyright © 2021 Turkish Technic. All rights reserved.
//

import UIKit
import NMBaseView

class InventoryControlVC: BaseTableViewController {
   
    var viewModel: InventoryControlVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        setupViewModel()
    }
    
    private func setupView() {
        barNav.setBar(type: .onlyBack, vc: self, title: viewModel.title)
    }
    
    private func setupTableView() {
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
        tableView.register(UINib(nibName: CellInventoryControl.className,bundle: Bundle(for: self.classForCoder)),
                               forCellReuseIdentifier: CellInventoryControl.className)
    }
    
    private func setupViewModel() {
        viewModel.state.bind { [unowned self] in
            self.stateHandle($0)
        }.disposed(by: disposeBag)
        
        viewModel.errorState.bind { [unowned self] in
            self.errorHandle($0)
        }.disposed(by: disposeBag)
        
        viewModel.getData()
    }
    
    // MARK: - TableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSection()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.item(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: CellInventoryControl.identifier, for: indexPath) as! CellInventoryControl
        cell.configure(with: item)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForHeader(in: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return viewModel.titleForFooter(in: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            
            switch ThemeManager.shared.style {
            case .dark: headerView.contentView.backgroundColor = .lightGray
            case .light: headerView.contentView.backgroundColor = .clear
            case .mobilCabin: headerView.contentView.backgroundColor = #colorLiteral(red: 0.361360997, green: 0.4262621403, blue: 0.722029984, alpha: 1)
            }
            
            headerView.textLabel?.textColor = ThemeManager.shared.textColor
            headerView.textLabel?.font = ThemeManager.shared.topTitleFont
        }
    }
}
