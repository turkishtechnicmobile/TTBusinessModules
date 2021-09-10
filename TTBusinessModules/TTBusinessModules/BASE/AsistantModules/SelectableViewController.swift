//
//  SelectableViewController.swift
//  NMBusinessModules
//
//  Created by Nazif MASMANACI on 4.05.2021.
//  Copyright © 2021 Turkish Technic. All rights reserved.
//

import UIKit
import NMBaseModel
import NMBaseView

open class SelectableViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet weak var clearBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var applyButton: BTButton!
    
    let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.autocapitalizationType = .allCharacters
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        return searchController
    }()
    
    // MARK: - Variables
    public var viewModel: SelectableViewModel!
    
    // MARK: - Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupViewModel()
    }
    
    private func setupView() {
        searchController.searchResultsUpdater = self
        navigationItem.titleView = searchController.searchBar
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 70
        tableView.tableFooterView = UIView()
        tableView.register(SelectableTableViewCell.self, forCellReuseIdentifier: SelectableTableViewCell.identifier)
    }
    
    private func setupViewModel() {
        viewModel.state.bind { [unowned self] in
            self.stateHandle($0)
        }.disposed(by: disposeBag)
        
        viewModel.reloadRows.bind { [unowned self] in
            self.tableView.reloadRows(at: $0, with: .automatic)
        }.disposed(by: disposeBag)
        
        viewModel.closeView.bind { [unowned self](_) in
            self.close()
        }.disposed(by: disposeBag)
        
        applyButton.isHidden = !viewModel.allowMultipleSelection
        
        self.tableView.backgroundColor = ThemeManager.shared.backgroundColor
    }
    
    @IBAction func barButtonTapped(_ sender: UIBarButtonItem) {
        switch sender {
        case clearBarButtonItem:
            viewModel.clear()
        case cancelBarButtonItem:
            close()
        default:
            fatalError("Unhandled switch case at \(String(describing: self))")
        }
    }
    
    private func close() {
        searchController.isActive = false
        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func applyTapped(_ sender: UIButton) {
        viewModel.apply()
    }
    
    override func reloadView(_ state: TableViewState) {
        super.reloadView(state)
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
        tableView.backgroundView = state == .empty ? noResultsFoundLabel : nil
    }
}

extension SelectableViewController: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSection()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.item(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectableTableViewCell.identifier, for: indexPath) as! SelectableTableViewCell
        cell.configure(with: item, option: viewModel.showOption)
        cell.accessoryType = item.isSelected ? .checkmark : .none
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectItem(at: indexPath)
    }
}

extension SelectableViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        viewModel.search(text: text)
    }
}

class SelectableTableViewCell: BaseTableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func configure(with itemViewModel: ItemViewModel, option: SelectableViewModel.ShowOption) {
        super.configure(with: itemViewModel)
        guard let itemViewModel = itemViewModel as? SelectableItemViewModel else { return }
        
        textLabel?.text = itemViewModel.text(with: option)
        detailTextLabel?.text = itemViewModel.detailText(with: option)
        accessoryType = itemViewModel.isSelected ? .checkmark : .none
    }
    
    override func apply(theme: Theme) {
        super.apply(theme: theme)
                
        textLabel?.textColor = theme.textColor
        detailTextLabel?.textColor = theme.textColor
    }
}
