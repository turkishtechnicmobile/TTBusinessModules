//
//  BaseViewController.swift
//  NMBusinessModules
//
//  Created by MnzfM on 5.03.2021.
//

import UIKit
import Foundation
import NMBaseService
import NMBaseApp
import NMBaseModel
import NMBaseView

class BaseNavigationController: UINavigationController { }

open class BaseViewController: UIViewController, ThemeApplierListener {
    
    public func apply(theme: Theme) {
        
        barNav.setBarTintColor(color: theme.navigationBarBackgroundColor)
    }
    
    // MARK: - Variables
    var isGradientLayer = false
    let disposeBag = DisposeBag()
    public var themeApplier: ThemeApplier?
    lazy private(set) var barNav = NNavigation(barTintColor: UIColor.init(red: 20.0/255, green: 51.0/255, blue: 88.0/255, alpha: 1),
                                               barTextFont: UIFont(name: "MuseoSans-700", size: 20))
    
    @Inject var persistent: Persistent
    @Inject var service: ServiceProtocol
    @Inject var dateFormat: DateFormat

    var isTopBarShown = true

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
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
        label.text = ConstantFS.Message.noResultsFound
        label.textAlignment = .center
        return label
    }()
    
    private let loadingViewController = LoadingViewController()

    
    deinit {
        debugPrint("***** deinit \(String(describing: classForCoder))")
    }
    
    // MARK: - Life Cycles
    public override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint("* viewDidLoaded \(String(describing: classForCoder))")
        
        setupTheme()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        windowEndEditing()
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    private func windowEndEditing() {
        DispatchQueue.main.async {
            self.view.window?.endEditing(true)
        }
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
        let okAction = UIAlertAction(title: ConstantManager.ok, style: .default, handler: nil)
        alertViewController.addAction(okAction)
        present(alertViewController, animated: true, completion: nil)
    }
    
    func presentFormSheetNavigation(viewController: UIViewController) {
        let navigationVC = BaseNavigationController(rootViewController: viewController)
        navigationVC.modalPresentationStyle = .formSheet
        self.present(navigationVC, animated: true, completion: nil)
    }

    func pushViewController(_ viewController: UIViewController, animated: Bool = true) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func presentOverContext(_ viewController:UIViewController, animated: Bool = true) {
        viewController.modalPresentationStyle = .overCurrentContext
        present(viewController, animated: animated, completion: nil)
    }
    
    
    func showLoadingView() {
        add(loadingViewController)
    }
    
    func removeLoadingView() {
        loadingViewController.removeLV()
    }
    
    func segmentCollectionViewFlowLayout(showTopBar: Bool, topFilterHeight: CGFloat = 0) -> UICollectionViewFlowLayout {
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
        let navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
        let topBarAndSegmentHeight:CGFloat = showTopBar ? 2 * 64 : 64
        let height = view.frame.height - statusBarHeight - navigationBarHeight - topBarAndSegmentHeight - topFilterHeight
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.estimatedItemSize = CGSize(width:  view.frame.width, height: height)
        return layout
    }
}

