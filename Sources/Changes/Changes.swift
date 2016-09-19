//
//  Diff.swift
//  Diff
//
//  Created by Chris Amanse on 09/19/2016.
//
//

public extension Collection where Iterator.Element: Equatable, IndexDistance == Int {
    
    /// Get the changes of the receiver based on another collection.
    ///
    /// - parameter oldCollection: The old collection.
    /// - parameter reduced:       If set to `true`, insertion and deletion pairs will be combined into a `.Move` type. Default value is `true`.
    ///
    /// - returns: An array of changes.
    public func changes(since oldCollection: Self, reduced: Bool = true) -> [Change<Iterator.Element>] {
        return Changes.changes(old: oldCollection, new: self, reduced: reduced)
    }
}

public extension String {
    
    /// Get the changes of the receiver based on another String.
    ///
    /// - parameter oldString: The old string.
    /// - parameter reduced:   If set to `true`, insertion and deletion pairs will be combined into a `.Move` type. Default value is `true`.
    ///
    /// - returns: An array of changes.
    public func changes(since oldString: String, reduced: Bool = true) -> [Change<Character>] {
        return self.characters.changes(since: oldString.characters, reduced: reduced)
    }
}


fileprivate func changes<T: Collection>(old: T, new: T, reduced: Bool = true) -> [Change<T.Iterator.Element>] where T.Iterator.Element: Equatable, T.IndexDistance == Int {
    // Wagner-Fischer Algorithm
    
    // Max sizes
    let oldCount = old.count
    let newCount = new.count
    
    // If both collections are empty, return empty changes
    if oldCount == 0 && newCount == 0 {
        return []
    }
    
    // Empty matrix (2D array which consists of steps required taken to and from indices of each)
    // +1 on both rows and columns to include to/from empty collection steps
    var changesTable: [[[Change<T.Generator.Element>]]] = Array(
        repeating: Array(repeating: [], count: newCount + 1),
        count: oldCount + 1
    )
    
    // Changes for each index of old collection when new collection is empty
    for (index, element) in old.enumerated() {
        if index == 0 {
            changesTable[1][0] = [.Deletion(element: element, destination: index)]
        } else {
            changesTable[index + 1][0] = changesTable[index][0] + [.Deletion(element: element, destination: index)]
        }
    }
    
    // Changes for each index of new collection when old collection is empty
    for (index, element) in new.enumerated() {
        if index == 0 {
            changesTable[0][1] = [.Insertion(element: element, destination: index)]
        } else {
            changesTable[0][index + 1] = changesTable[0][index] + [.Insertion(element: element, destination: index)]
        }
    }
    
    // If either old collection or new collection is empty, return the row/column which simply consists of insertions/deletions
    if oldCount == 0 || newCount == 0 {
        return changesTable[oldCount][newCount]
    }
    
    // Iterate through the matrix
    for (newCollectionIndex, newCollectionElement) in new.enumerated() {
        let column = newCollectionIndex + 1
        
        for (oldCollectionIndex, oldCollectionElement) in old.enumerated() {
            let row = oldCollectionIndex + 1
            
            if oldCollectionElement == newCollectionElement {
                // If same element, no changes, thus copy previous changes
                changesTable[row][column] = changesTable[row - 1][column - 1]
            } else {
                let previousRowChanges = changesTable[row - 1][column] // If least # of steps, current step is Deletion
                let previousColumnChanges = changesTable[row][column - 1] // Current step is Insertion
                let previousRowAndColumnChanges = changesTable[row - 1][column - 1] // Current step is Substitution
                
                let minimumCount = min(previousRowChanges.count,
                                       previousColumnChanges.count,
                                       previousRowAndColumnChanges.count)
                
                let currentChanges: [Change<T.Iterator.Element>]
                switch minimumCount {
                case previousRowChanges.count:
                    currentChanges = previousRowChanges + [.Deletion(element: oldCollectionElement, destination: oldCollectionIndex)]
                case previousColumnChanges.count:
                    currentChanges = previousColumnChanges + [.Insertion(element: newCollectionElement, destination: newCollectionIndex)]
                default:
                    currentChanges = previousRowAndColumnChanges + [.Substitution(element: newCollectionElement, destination: newCollectionIndex)]
                }
                
                // Save current changes to table
                changesTable[row][column] = currentChanges
            }
        }
    }
    
    // Reduce if reduced flag is true
    let changes = changesTable[oldCount][newCount]
    if reduced {
        return reduce(changes: changes)
    } else {
        return changes
    }
}

fileprivate func reduce<T: Equatable>(changes: [Change<T>]) -> [Change<T>] {
    return changes.reduce([Change<T>]()) { (result, change) -> [Change<T>] in
        var reducedChanges = result
        
        let currentChange: Change<T>
        switch change {
        case .Insertion(element: let element, destination: let insertionDestination):
            // Find deletion pair in reduced changes
            var deletionDestination: Int = 0
            
            if let deletionIndex = reducedChanges.index(where: {
                if case .Deletion(element: element, destination: let destination) = $0 {
                    // Found pair
                    deletionDestination = destination
                    return true
                } else {
                    return false
                }
            }) {
                reducedChanges.remove(at: deletionIndex)
                currentChange = .Move(element: element, origin: deletionDestination, destination: insertionDestination)
            } else {
                currentChange = change
            }
        case .Deletion(element: let element, destination: let deletionDestination):
            // Find insertion pair in reduced changes
            var insertionDestination: Int = 0
            
            if let insertionIndex = reducedChanges.index(where: {
                if case .Insertion(element: element, destination: let destination) = $0 {
                    // Found pair
                    insertionDestination = destination
                    return true
                } else {
                    return false
                }
            }) {
                reducedChanges.remove(at: insertionIndex)
                currentChange = .Move(element: element, origin: deletionDestination, destination: insertionDestination)
            } else {
                currentChange = change
            }
        default:
            currentChange = change
        }
        
        return reducedChanges + [currentChange]
    }
}
