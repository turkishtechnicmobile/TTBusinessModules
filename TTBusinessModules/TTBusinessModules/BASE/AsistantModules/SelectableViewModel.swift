//
//  SelectableViewModel.swift
//  NMBusinessModules
//
//  Created by Nazif MASMANACI on 4.05.2021.
//  Copyright © 2021 Turkish Technic. All rights reserved.
//

import Foundation
import NMBaseApp
import NMBaseModel

open class SelectableViewModel: BaseFirstListViewModel<SelectableItemViewModel> {
    var showOption: ShowOption
    public var allowMultipleSelection = false
    
    private var unfilteredItems = [SelectableItemViewModel]()
    private var dispatchWorkItem: DispatchWorkItem?
    private let searchDelay: TimeInterval = 0.5
    
    public let selectedItem: Dynamic<SelectableItemViewModel?> = Dynamic(nil) /// used for when single selection
    public let selectedItems: Dynamic<[SelectableItemViewModel]> = Dynamic([]) /// used for when multi selection
    public let closeView: Dynamic<Bool> = Dynamic(false)
    
    deinit {
        print("***** deinit \(String(describing: SelectableViewModel.self))")
    }
    
    public init(items: [SelectableItemViewModel], showOption: ShowOption = .keyOnly) {
        self.showOption = showOption
        super.init()
        self.items = items
        self.unfilteredItems = items
    }
    
    open override func didSelectItem(at indexPath: IndexPath) {
        selectDeselectItem(at: indexPath)
        reloadRows.value = [indexPath]
        
        if !allowMultipleSelection {
            selectedItem.value = item(at: indexPath)
            close()
        }
    }
    
    func clear() {
        if allowMultipleSelection {
            selectedItems.value = []
        } else {
            selectedItem.value = nil
        }
        close()
    }
    
    /// apply multi selection
    func apply() {
        selectedItems.value = self.items.filter { $0.isSelected }
        close()
    }
    
    func close() {
        closeView.value = true
    }
    
    func search(text: String) {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        dispatchWorkItem?.cancel()
        dispatchWorkItem = DispatchWorkItem(block: { [unowned self] in
            self.items = text.isEmpty ? self.unfilteredItems : self.unfilteredItems.filter { $0.key.uppercased().contains(text) || $0.value.uppercased().contains(text) }
        })
        
        let delay: TimeInterval = text.isEmpty ? 0 : searchDelay
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: dispatchWorkItem!)
        
        dispatchWorkItem!.notify(queue: .main) {
            self.state.value = self.items.isEmpty ? .empty : .populate
        }
    }
    
    /// will be used in future
    private func clearSelection() {
        guard !allowMultipleSelection else { return }
        // clear all selection, moreover don't forget to clear tableview visible Cells if needed
        items.forEach { $0.isSelected = false }
    }
}

extension SelectableViewModel {
    public enum ShowOption {
        case keyOnly
        case valueOnly
        case keyAndValue
    }
}

open class SelectableItemViewModel: ItemViewModel, ViewModelSelectable {
    public let model: Model
    public let key: String
    public let value: String
    public var isSelected: Bool
    
    public init(model: Model, key: String, value: String, isSelected: Bool = false) {
        self.model = model
        self.key = key
        self.value = value
        self.isSelected = isSelected
    }
    
    public func text(with option: SelectableViewModel.ShowOption) -> String {
        switch option {
        case .keyOnly, .keyAndValue:
            return key
        default:
            return value
        }
    }
    
    public func detailText(with option: SelectableViewModel.ShowOption) -> String? {
        switch option {
        case .keyAndValue:
            return value
        default:
            return nil
        }
    }
}

open class SelectableModel: Model {
    let key: String
    let value: String
    
    init(_ key: String, _ value: String) {
        self.key = key
        self.value = value
    }
}
