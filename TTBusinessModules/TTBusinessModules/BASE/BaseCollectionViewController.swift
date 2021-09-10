//
//  BaseCollectionViewController.swift
//  NMBusinessModules
//
//  Created by Nazif MASMANACI on 4.05.2021.
//  Copyright © 2021 Turkish Technic. All rights reserved.
//

import UIKit
import Foundation
import NMBaseService
import NMBaseApp
import NMBaseModel
import NMBaseView


open class BaseCollectionViewController: UICollectionViewController, ThemeApplierListener {
    // MARK: - Variables
    var isGradientLayer = false
    let disposeBag = DisposeBag()
    public var themeApplier: ThemeApplier?
    
    lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.white.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = view.layer.cornerRadius
        gradientLayer.shouldRasterize = true
        return gradientLayer
    }()
    
    private let loadingViewController = LoadingViewController()
    
    // MARK: Life Cycle
    open override func viewDidLoad() {
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
        }
    }
    
    func reloadView(_ state: TableViewState) {
        collectionView.reloadData()
        collectionView.refreshControl?.endRefreshing()
    }
    
    public func apply(theme: Theme) {
        collectionView.indicatorStyle = theme.style == .dark ? .white : .black
        setupGradientLayer(with: theme)
        // when no refresh control assigned, not initialize custom
        if let refreshControl = collectionView.refreshControl {
            refreshControl.tintColor = theme.refreshControlColor
            let attributes = [NSAttributedString.Key.foregroundColor: theme.refreshControlColor]
            refreshControl.attributedTitle = NSAttributedString(string: ConstantInventory.Message.loading, attributes: attributes)
        }
    }
    
    /// Add gradient layer to main view layer when necessary.
    private func setupGradientLayer(with theme: Theme) {
        guard isGradientLayer else { return }
        gradientLayer.colors = theme.gradientBackgroundColors
        gradientLayer.removeFromSuperlayer()
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}

class BaseCollectionViewCell: UICollectionViewCell, ConfigurableCell, ThemeApplierListener {
    // MARK: - Variables
    var themeApplier: ThemeApplier?
    
    static var nibName: String {
//        return String(describing: BaseCollectionViewCell.self)
        return String(describing: classForCoder().self)
    }
    
    static var identifier: String {
        return String(describing: classForCoder().self)
    }
    
    // MARK: - Life Cycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        setupTheme()
    }
    
    func configure(with itemViewModel: ItemViewModel) {
        
    }
    
    func apply(theme: Theme) {
        
    }
}
