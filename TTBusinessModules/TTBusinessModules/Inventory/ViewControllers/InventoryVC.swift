//
//  InventoryVC.swift
//  NMBusinessModules
//
//  Created by Nazif MASMANACI on 4.05.2021.
//  Copyright © 2021 Turkish Technic. All rights reserved.
//

import UIKit
import TTBaseView

public class InventoryVC: BaseViewController {

    @IBOutlet weak var pnComponentView: TitledTextFieldComponentView!
    @IBOutlet weak var snComponentView: TitledTextFieldComponentView!
    @IBOutlet weak var locationComponentView: TitledTextFieldComponentView!
    @IBOutlet weak var airCraftComponentView: TitledButtonComponentView!
    @IBOutlet weak var companyComponentView: ButtonComponentView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var pnInfoComponentView: TitleComponentView!
    @IBOutlet weak var containerView: UIView!
    
    private var segmentCollectionViewController: SegmentCollectionViewController!
    
    lazy var summaryViewController: InventorySummaryVC = {
        let viewController = BaseAppCoordinator.inventorySummaryVC()
        viewController.viewModel = viewModel.inventorySummaryViewModel
        return viewController
    }()
    
    lazy var detailViewController: InventoryDetailVC = {
        let viewController = BaseAppCoordinator.inventoryDetailVC()
        viewController.viewModel = viewModel.inventoryDetailViewModel
        return viewController
    }()
    
    // MARK: - Variables
    public var viewModel: InventoryVM!
    
    // MARK: - Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupViewModel()
    }
    
    public override func apply(theme: Theme) {
        super.apply(theme: theme)
        searchButton.setTitleColor(theme.textColor, for: .normal)
        
        searchButton.tintColor = theme.textColor // for image color
        self.view.backgroundColor = theme.backgroundColor
        
        guard let img = IconInventory.searchIcon.getImg() else {return}
        let searchIcon = img.withRenderingMode(.alwaysTemplate)
        searchButton.setImage(searchIcon, for: .normal)
    }
    
    private func setupView() {
        barNav.setBar(type: .onlyHamburger, vc: self, title: ConstantInventory.Hamburger.inventory)
        
        segmentCollectionViewController = BaseAppCoordinator.segmentCollectionViewController()
        segmentCollectionViewController.collectionViewLayout = segmentCollectionViewFlowLayout(showTopBar: false, topFilterHeight: 160)
        segmentCollectionViewController.viewModel = viewModel.segmentMenuViewModel
        segmentCollectionViewController.viewControllers = [summaryViewController, detailViewController]
        add(child: segmentCollectionViewController, to: containerView)
        
        pnComponentView.titleText = ConstantInventory.pn
        snComponentView.titleText = ConstantInventory.sn
        locationComponentView.titleText = ConstantInventory.location
        airCraftComponentView.titleText = ConstantInventory.ac
        companyComponentView.buttonTitleText = ConstantInventory.company
        
        pnComponentView.textFieldChanged = { [unowned self] in
            self.viewModel.pnChanged($0)
        }
        
        snComponentView.textFieldChanged = { [unowned self] in
            self.viewModel.snChanged($0)
        }
        
        locationComponentView.textFieldChanged = { [unowned self] in
            self.viewModel.locationChanged($0)
        }
        
        airCraftComponentView.actionHandler = { [unowned self] in
            self.viewModel.airCraftSelection()
        }
        
        companyComponentView.actionHandler = { [unowned self] in
            self.viewModel.companySelection()
        }
        
        segmentCollectionViewController.selectedIndex.bind { [unowned self] in
            self.viewModel.segmentDidSelected(at: $0)
        }
    }
    
    private func setupViewModel() {
        viewModel.state.bind { [unowned self] in
            self.stateHandle($0)
        }.disposed(by: disposeBag)
        
        viewModel.errorState.bind { [unowned self] in
            self.errorHandle($0)
        }.disposed(by: disposeBag)
        
        viewModel.routeToSelectable.bind { [unowned self] in
            guard let selectableViewModel = $0 else { return }
            let selectableViewController = BaseAppCoordinator.selectableViewController()
            selectableViewController.viewModel = selectableViewModel

            self.presentFormSheetNavigation(viewController: selectableViewController)
            self.viewModel.routeToSelectable.value = nil // ARC
        }.disposed(by: disposeBag)
        
        viewModel.inventoryType.bindAndFire { [unowned self] in
            self.snComponentView.isTextFieldEnabled = $0 == .detail
            self.airCraftComponentView.isButtonEnabled = $0 == .detail
        }
        
        viewModel.pn.bindAndFire { [unowned self] in
            self.pnComponentView.textFieldText = $0
        }.disposed(by: disposeBag)
        
        viewModel.sn.bindAndFire { [unowned self] in
            self.snComponentView.textFieldText = $0
        }.disposed(by: disposeBag)
        
        viewModel.location.bindAndFire { [unowned self] in
            self.locationComponentView.textFieldText = $0
        }.disposed(by: disposeBag)
        
        viewModel.airCraft.bindAndFire { [unowned self] in
            self.airCraftComponentView.buttonTitleText = $0 ??  ConstantInventory.Action.select
        }.disposed(by: disposeBag)

        viewModel.pnInfo.bindAndFire { [unowned self] in
            self.pnInfoComponentView.titleText = $0
        }.disposed(by: disposeBag)
        
        viewModel.company.bindAndFire { [unowned self] in
            self.companyComponentView.buttonTitleText = $0 ?? ConstantInventory.company
        }.disposed(by: disposeBag)
    }
    
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        viewModel.getData()
    }
    
}

