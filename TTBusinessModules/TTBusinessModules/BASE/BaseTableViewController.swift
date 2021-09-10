//
//  BaseTableViewController.swift
//  NMBusinessModules
//
//  Created by Nazif MASMANACI on 4.05.2021.
//  Copyright © 2021 Turkish Technic. All rights reserved.
//

import UIKit
import NMBaseView
import NMBaseApp
import NMBaseModel

class BaseTableViewController: UITableViewController, ThemeApplierListener {
    // MARK: - Variables
    var isGradientLayer = false
    lazy private(set) var barNav = NNavigation(barTintColor: UIColor.init(red: 20.0/255, green: 51.0/255, blue: 88.0/255, alpha: 1),barTextFont: UIFont(name: "MuseoSans-700", size: 20))
    let disposeBag = DisposeBag()
    var themeApplier: ThemeApplier?
    
    lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.white.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = view.layer.cornerRadius
        gradientLayer.shouldRasterize = true
        return gradientLayer
    }()
    
    let noResultsFoundLabel: UILabel = {
        let label = UILabel()
        label.text = ConstantInventory.Message.noResultsFound
        label.textAlignment = .center
        return label
    }()
    
    private let loadingViewController = LoadingViewController()
    
    lazy var customRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    deinit {
        debugPrint("***** deinit \(String(describing: classForCoder))")
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTheme()
    }
    
    func showLoadingView() {
        add(loadingViewController)
    }
    
    func removeLoadingView() {
        loadingViewController.removeLV()
    }
    
    func stateHandle(_ state: TableViewState) {
        switch state {
        case .loading:
            showLoadingView()
        case .populate:
            removeLoadingView()
            reloadView(state)
        case .empty:
            removeLoadingView()
            reloadView(state)
        case .error:
            removeLoadingView()
            reloadView(state)
        }
    }
    
    func reloadView(_ state: TableViewState) {
        tableView.reloadData()
        refreshControl?.endRefreshing()
        tableView.backgroundView = state == .empty ? noResultsFoundLabel : nil
    }
    
    @objc
    func refresh() {
        
    }
    
    func errorHandle(_ errorState: ErrorState) {
        switch errorState {
        case .warning(let title, let message):
            showWarning(title: title, message: message)
        case .error(let title, let message):
            showError(title: title, message: message)
        default:
            debugPrint("Default switch \(#function)")
        }
    }
    
    private func showWarning(title: String?, message: String?) {
        showError(title: title, message: message)
    }
    
    func showError(title: String?, message: String?) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: ConstantInventory.Action.ok, style: .default, handler: nil)
        alertViewController.addAction(okAction)
        present(alertViewController, animated: true, completion: nil)
    }
    
    func show(confirmationAlert: ConfirmationAlert) {
        func actionStyle(_ actionStyle: ActionStyle) -> UIAlertAction.Style {
            switch actionStyle {
            case .default:
                return .default
            case .cancel:
                return .cancel
            case .destructive:
                return .destructive
            }
        }
        
        let alertStyle: UIAlertController.Style = {
            switch confirmationAlert.style {
            case .actionSheet:
                return .actionSheet
            case .alert:
                return .alert
            }
        }()
        
        let alertViewController = UIAlertController(title: confirmationAlert.title, message: confirmationAlert.message, preferredStyle: alertStyle)
        
        if let cancelActionTitle = confirmationAlert.cancelActionTitle {
            let style = actionStyle(confirmationAlert.cancelActionStyle)
            let action = UIAlertAction(title: cancelActionTitle, style: style) { (_) in
                confirmationAlert.cancelActionHandler?()
            }
            alertViewController.addAction(action)
            if case .cancel = confirmationAlert.actionPreferred {
                alertViewController.preferredAction = action
            }
        }
        
        if let okActionTitle = confirmationAlert.okActionTitle {
            let style = actionStyle(confirmationAlert.okActionStyle)
            let action = UIAlertAction(title: okActionTitle, style: style) { (_) in
                confirmationAlert.okActionHandler?()
            }
            alertViewController.addAction(action)
            if case .ok = confirmationAlert.actionPreferred {
                alertViewController.preferredAction = action
            }
        }
        
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    func apply(theme: Theme) {
        
        barNav.setBarTintColor(color: theme.navigationBarBackgroundColor)
        view.backgroundColor = theme.backgroundColor
        noResultsFoundLabel.textColor = theme.textColor
        setupGradientLayer(with: theme)
        
        tableView.indicatorStyle = theme.style == .dark ? .white : .black
        // when no refresh control assigned, not initialize custom
        customRefreshControl.tintColor = theme.refreshControlColor
        let attributes = [NSAttributedString.Key.foregroundColor: theme.refreshControlColor,
                          NSAttributedString.Key.font : theme.titleFont]
        customRefreshControl.attributedTitle = NSAttributedString(string: ConstantInventory.Message.loading, attributes: attributes)
    }
    
    /// Add gradient layer to main view layer when necessary.
    private func setupGradientLayer(with theme: Theme) {
        guard isGradientLayer else { return }
        gradientLayer.colors = theme.gradientBackgroundColors
        gradientLayer.removeFromSuperlayer()
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func pushViewController(_ viewController: UIViewController, animated: Bool = true) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
}
