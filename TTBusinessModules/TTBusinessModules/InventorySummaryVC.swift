//
//  InventorySummaryVC.swift
//  NMBusinessModules
//
//  Created by Nazif MASMANACI on 4.05.2021.
//  Copyright © 2021 Turkish Technic. All rights reserved.
//

import UIKit
import TTBaseView

class InventorySummaryVC: BaseTableViewController {
  
    var viewModel: InventorySummaryVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        setupViewModel()
    }
    
    private func setupView() {
        
    }
    
    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(UINib(nibName: CellInventorySummary.className,bundle: Bundle(for: self.classForCoder)),
                               forCellReuseIdentifier: CellInventorySummary.className)
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSection()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.item(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: CellInventorySummary.identifier, for: indexPath) as! CellInventorySummary
        cell.configure(with: item)
        cell.selectedBackgroundView = ThemeManager.cellSelectedBackgroundView()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = BaseAppCoordinator.inventoryDetailVC()
        detailViewController.viewModel = viewModel.getInventoryDetailVM(at: indexPath)
        pushViewController(detailViewController)
    }
}

