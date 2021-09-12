//
//  SegmentCollectionViewController.swift
//  NMBusinessModules
//
//  Created by Nazif MASMANACI on 4.05.2021.
//  Copyright © 2021 Turkish Technic. All rights reserved.
//

import UIKit
import TTBaseApp
import TTBaseModel
import TTBaseView

open class SegmentCollectionViewController: BaseViewController {
    
    // MARK: - Views
    lazy var menuCollectionViewController: SegmentMenuCollectionViewController = {
        let viewController = SegmentMenuCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        viewController.viewModel = viewModel
        return viewController
    }()
    
    public var collectionViewLayout: UICollectionViewLayout!
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = isScrollEnabled
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    public var viewControllers: [UIViewController] = []

    // MARK: - Variables
    public var viewModel: SegmentMenuViewModel!
    public var isScrollEnabled = false
    public var menuHeight: CGFloat = 64
    public var selectedIndex = Dynamic(0)
    private var isEnableSelection = true
    
    // MARK: - Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.addSubview(menuCollectionViewController.view)
        menuCollectionViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            menuCollectionViewController.view.safeTopAnchor.constraint(equalTo: view.safeTopAnchor),
            menuCollectionViewController.view.safeLeadingAnchor.constraint(equalTo: view.safeLeadingAnchor),
            menuCollectionViewController.view.safeTrailingAnchor.constraint(equalTo: view.safeTrailingAnchor),
            menuCollectionViewController.view.safeHeightAnchor.constraint(equalToConstant: menuHeight)
            ])
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.safeTopAnchor.constraint(equalTo: menuCollectionViewController.view.safeBottomAnchor),
            collectionView.safeBottomAnchor.constraint(equalTo: view.safeBottomAnchor),
            collectionView.safeLeadingAnchor.constraint(equalTo: view.safeLeadingAnchor),
            collectionView.safeTrailingAnchor.constraint(equalTo: view.safeTrailingAnchor),
            ])
        
        collectionView.register(SegmentCollectionViewCell.self, forCellWithReuseIdentifier: SegmentCollectionViewCell.identifier)
        
        menuCollectionViewController.selectedIndexPath.bind { [unowned self] in
            self.isEnableSelection = false
            self.collectionView.scrollToItem(at: $0, at: .centeredHorizontally, animated: true)
        }
        
        // call for select first item
        DispatchQueue.main.async {
            self.menuCollectionViewController.scrollMenuBar(to: 0, isEnableSelection: self.isEnableSelection)
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollMenuBar(scrollView)
    }
    
    // this function is triggered once when called collectionView.scrollToItem
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isEnableSelection = true
        scrollMenuBar(scrollView)
    }
    
    func scrollMenuBar(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let offset = x / view.frame.width
        menuCollectionViewController.scrollMenuBar(to: offset, isEnableSelection: isEnableSelection)
        selectedIndex.value = menuCollectionViewController.getSelectedIndexPath().item
    }
    
    public func reloadCollectionView() {
        collectionView.reloadData()
        menuCollectionViewController.reloadCollectionView()
    }
}


extension SegmentCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewControllers.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SegmentCollectionViewCell.identifier, for: indexPath) as! SegmentCollectionViewCell
        cell.hostedView = viewControllers[indexPath.item].view
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let vc = viewControllers[indexPath.item]
        addChild(vc)
        vc.didMove(toParent: self)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let vc = viewControllers[indexPath.item]
        vc.remove()
    }
}

class SegmentCollectionViewCell: BaseCollectionViewCell {
    var hostedView: UIView? {
        didSet {
            guard let hostedView = hostedView else { return }
            hostedView.frame = contentView.frame
            contentView.addSubview(hostedView)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        hostedView?.removeFromSuperview()
        hostedView = nil
    }
}


open class SegmentMenuCollectionViewController: BaseCollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Views
    let menuBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let menuBarLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Variables
    var viewModel: SegmentMenuViewModel!
    var selectedIndexPath = Dynamic(IndexPath(row: 0, section: 0))
    
    private var itemSize = CGSize.zero
    private var menuBarViewWidthLayoutConstraint: NSLayoutConstraint!

    // MARK: - Life Cycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupView()
        setupViewModel()
    }
    
    private func setupLayout() {
        itemSize = CGSize(width:  view.frame.width / CGFloat(viewModel.items.count), height: view.frame.height)
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.itemSize = itemSize
        }
    }
    
    private func setupView() {
        applyTheme()
        
        menuBarViewWidthLayoutConstraint = menuBarView.safeWidthAnchor.constraint(equalToConstant: itemSize.width)
        
        menuBarLineView.addSubview(menuBarView)
        view.addSubview(menuBarLineView)
        
        NSLayoutConstraint.activate([
            menuBarLineView.safeBottomAnchor.constraint(equalTo: view.safeBottomAnchor),
            menuBarLineView.safeLeadingAnchor.constraint(equalTo: view.safeLeadingAnchor),
            menuBarLineView.safeTrailingAnchor.constraint(equalTo: view.safeTrailingAnchor),
            menuBarLineView.safeHeightAnchor.constraint(equalToConstant: 2),

            menuBarView.safeTopAnchor.constraint(equalTo: menuBarLineView.safeTopAnchor),
            menuBarView.safeBottomAnchor.constraint(equalTo: menuBarLineView.safeBottomAnchor),
            menuBarView.safeLeadingAnchor.constraint(equalTo: menuBarLineView.safeLeadingAnchor),
            menuBarViewWidthLayoutConstraint
            ])
        
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(SegmentMenuCollectionViewCell.self, forCellWithReuseIdentifier: SegmentMenuCollectionViewCell.identifier)
    }
    
    func applyTheme() {
        view.backgroundColor = .clear
        menuBarView.backgroundColor = ThemeManager.shared.segmentBottomLineColor
        menuBarLineView.backgroundColor = ThemeManager.shared.segmentBottomLineBackgroundColor
    }
    
    private func setupViewModel() {
        viewModel.state.bind { [unowned self] in
            self.stateHandle($0)
        }
    }
    
    func reloadCollectionView() {
        setupLayout()
        menuBarViewWidthLayoutConstraint.constant = itemSize.width
        menuBarView.setNeedsUpdateConstraints()
        collectionView.reloadData()
    }
    
    func scrollMenuBar(to offset: CGFloat, isEnableSelection: Bool) {
        let offset = offset * itemSize.width
        menuBarView.transform = CGAffineTransform(translationX: offset, y: 0)
        
        if isEnableSelection {
            let item = Int(menuBarView.frame.midX / itemSize.width)
            if item >= 0, item < viewModel.items.count {
                DispatchQueue.main.async {
                    self.collectionView.selectItem(at: IndexPath(item: item, section: 0), animated: true, scrollPosition: .centeredHorizontally)
                }
            }
        }
        
    }
    
    func getSelectedIndexPath() -> IndexPath {
        guard let selectedItems = collectionView.indexPathsForSelectedItems, let selectedItem = selectedItems.first else { return selectedIndexPath.value }
        return selectedItem
    }
    
    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSection()
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = viewModel.item(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SegmentMenuCollectionViewCell.identifier, for: indexPath) as! SegmentMenuCollectionViewCell
        cell.configure(with: item)
        return cell
    }
    
    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath.value = indexPath
    }
}

class SegmentMenuCollectionViewCell: BaseCollectionViewCell {
    // MARK: - Views
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = IconInventory.filterIcon.getImg() // UIImage(named: IconInventory.filterIcon.getImg())
        imageView.alpha = unSelectedAlpha
        imageView.safeWidthAnchor.constraint(equalToConstant: badgeWidth).isActive = true
        imageView.safeWidthAnchor.constraint(equalTo: imageView.safeHeightAnchor).isActive = true
        return imageView
    }()
    
    lazy var circleBadgeView: UIView = {
        let view = UIView()
        view.alpha = unSelectedAlpha
        view.layer.cornerRadius = badgeWidth / 2
        
        view.safeWidthAnchor.constraint(equalToConstant: badgeWidth).isActive = true
        view.safeWidthAnchor.constraint(equalTo: view.safeHeightAnchor).isActive = true
        
        view.addSubview(badgeTitleLabel)
        badgeTitleLabel.fillSuperView(with: .center)
        return view
    }()
    
    lazy var badgeTitleLabel: UILabel = {
        let label = UILabel()
        label.alpha = unSelectedAlpha
        label.font = titleFont
        return label
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.alpha = unSelectedAlpha
        label.font = titleFont
        return label
    }()
    
    // MARK: - Variables
    private let badgeWidth: CGFloat = 30
    private let unSelectedAlpha: CGFloat = 0.5
    private let titleFont: UIFont = ThemeManager.shared.largeTitleFont

    override var isSelected: Bool {
        didSet {
            applyIsSelected()
        }
    }
    
    // MARK: - Life Cycle
    override func setup() {
        super.setup()
        
        let stackView = UIStackView(arrangedSubviews: [iconImageView, circleBadgeView, titleLabel])
        stackView.spacing = 8
        addSubview(stackView)
        stackView.fillSuperView(with: .center)
        
        iconImageView.isHidden = true
        circleBadgeView.isHidden = true
    }
    
    override func apply(theme: Theme) {
        super.apply(theme: theme)
        iconImageView.tintColor = theme.badgeIconTintColor
        badgeTitleLabel.textColor = theme.textColor
        titleLabel.textColor = theme.textColor
        circleBadgeView.backgroundColor = theme.badgeBackgroundColor
        applyIsSelected()
    }
    
    private func applyIsSelected() {
        iconImageView.alpha = isSelected ? 1 : unSelectedAlpha
        circleBadgeView.alpha = isSelected ? 1 : unSelectedAlpha
        badgeTitleLabel.alpha = isSelected ? 1 : unSelectedAlpha
        titleLabel.alpha = isSelected ? 1 : unSelectedAlpha
    }
    
    override func configure(with itemViewModel: ItemViewModel) {
        super.configure(with: itemViewModel)
        
        guard let itemViewModel = itemViewModel as? SegmentMenuItemViewModel else { return }
        
        if let iconName = itemViewModel.iconName.value {
            iconImageView.isHidden = false
            iconImageView.image = UIImage(named: iconName)
        } else {
            iconImageView.isHidden = true
        }
        
        circleBadgeView.isHidden = (itemViewModel.badgeTitle ?? "").isEmpty ? true : false
        badgeTitleLabel.text = itemViewModel.badgeTitle
        
        itemViewModel.iconName.bind { [unowned self] in
            guard let iconName = $0 else {
                self.iconImageView.isHidden = true
                return
            }
            self.iconImageView.isHidden = false
            self.iconImageView.image = UIImage(named: iconName)
        }
        
        itemViewModel.title.bindAndFire { [unowned self] in
            self.titleLabel.text = $0
        }
    }
}

open class SegmentMenuViewModel: BaseFirstListViewModel<SegmentMenuItemViewModel> {
    
}

open class SegmentMenuItemViewModel: ItemViewModel {
    public var iconName: Dynamic<String?> = Dynamic(nil)
    public var badgeTitle: String?
    public var title: Dynamic<String> = Dynamic("")
    
    public init(iconName: String? = nil, badgeTitle: String? = nil, title: String = "[Title]") {
        self.iconName.value = iconName
        self.badgeTitle = badgeTitle
        self.title.value = title
    }
}

