//
//  ObservableCollection.swift
//  Changes
//
//  Created by Chris Amanse on 1/21/16.
//  Copyright © 2016 Joe Christopher Paul Amanse. All rights reserved.
//

public class ObserverableCollection<T: CollectionType where T.Generator.Element: Equatable, T.Index.Distance == Int> {
    public typealias Element = T.Generator.Element
    private var _currentValue: T
    public var currentValue: T {
        get {
            return _currentValue
        }
        set {
            // Will change
            observer?.observableCollectionWillBeginChanges(self)
            
            // Set change
            let oldValue = _currentValue
            _currentValue = newValue
            
            // Iterate over changes only if observer is not nil
            if let observer = self.observer {
                let changes = _currentValue.changesSince(oldValue)
                
                changes.forEach { change in
                    observer.observableCollection(self, didOccurChange: change)
                }
            }
            
            // Did change
            observer?.observableCollectionDidEndChanges(self)
        }
    }
    
    public var observer: ChangeObserver?
    public init(initialValue: T, observer: ChangeObserver? = nil) {
        _currentValue = initialValue
        self.observer = observer
    }
}

public protocol ChangeObserver {
    func observableCollectionWillBeginChanges<T>(observableCollection: ObserverableCollection<T>)
    func observableCollection<T>(observableCollection: ObserverableCollection<T>, didOccurChange change: Change<T.Generator.Element>)
    func observableCollectionDidEndChanges<T>(observableCollection: ObserverableCollection<T>)
}
