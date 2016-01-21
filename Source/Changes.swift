//
//  Changes.swift
//  Changes
//
//  Created by Chris Amanse on 1/21/16.
//  Copyright © 2016 Joe Christopher Paul Amanse. All rights reserved.
//

/**
  Describes the type of change
*/
public enum Change<T: Equatable> {
    /**
     A change of type insertion with an `element` that was inserted in the collection and
     a `destination` where the element was inserted.
    */
    case Insertion(element: T, destination: Int)
    
    /**
     A change of type deletion with an `element` that was deleted in the collection and
     a `destination` where the element was deleted.
     */
    case Deletion(element: T, destination: Int)
    
    /**
     A change of type substitution with an `element` as the new element in the collection and
     a `destination` where the element was overwritten.
     For example, changes of `[1,2,3]` since `[1,2,4]` (the old collection), will have a
     `Substitution` change with `element` 3 (the new element) and `destination` 2 (index starts at 0).
     */
    case Substitution(element: T, destination: Int)
    
    /**
     A change of type move with a `element` that was moved in the collection, and
     the element's `origin` and `destination`.
    */
    case Move(element: T, origin: Int, destination: Int)
}

extension Change: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Insertion(element: let element, destination: let destination):
            return "Inserted \(element) at index \(destination)"
        case .Deletion(element: let element, destination: let destination):
            return "Deleted \(element) at index \(destination)"
        case .Substitution(element: let element, destination: let destination):
            return "Substituted with \(element) at index \(destination)"
        case .Move(element: let element, origin: let origin, destination: let destination):
            return "Moved \(element) from index \(origin) to \(destination)"
        }
    }
}

extension Change: Equatable {}
public func ==<T: Equatable>(lhs: Change<T>, rhs: Change<T>) -> Bool {
    switch (lhs, rhs) {
    case (.Insertion(element: let element1, destination: let destination1),
        .Insertion(element: let element2, destination: let destination2)):
        return element1 == element2 && destination1 == destination2
    case (.Substitution(element: let element1, destination: let destination1),
        .Substitution(element: let element2, destination: let destination2)):
        return element1 == element2 && destination1 == destination2
    case (.Deletion(element: let element1, destination: let destination1),
        .Deletion(element: let element2, destination: let destination2)):
        return element1 == element2 && destination1 == destination2
    case (.Move(element: let element1, origin: let origin1, destination: let destination1),
        .Move(element: let element2, origin: let origin2, destination: let destination2)):
        return element1 == element2 && destination1 == destination2 && origin1 == origin2
    default:
        return false
    }
}

private class ChangesSummary<T: CollectionType where T.Generator.Element: Equatable, T.Index.Distance == Int> {
    private static func changesOf(newCollection: T, since oldCollection: T, reduced: Bool = true) -> [Change<T.Generator.Element>] {
        // Wagner-Fischer algorithm
        
        // Max sizes
        let oldCount = oldCollection.count
        let newCount = newCollection.count
        
        // Empty matrix (2D array which consists of steps required taken to and from indices of each)
        // +1 on both rows and columns to include to/from empty strings steps
        var changesTable: [[[Change<T.Generator.Element>]]] = Array(count: oldCount + 1, repeatedValue:
            Array(count: newCount + 1, repeatedValue: [])
        )
        
        // Changes for each index of old collection to an empty string
        var changes: [Change<T.Generator.Element>] = []
        for (row, object) in oldCollection.enumerate() {
            changes.append(.Deletion(element: object, destination: row))
            changesTable[row + 1][0] = changes
        }
        changes.removeAll()
        
        // Changes for old collection as empty string to each index of new collection
        for (column, object) in newCollection.enumerate() {
            changes.append(.Insertion(element: object, destination: column))
            changesTable[0][column + 1] = changes
        }
        changes.removeAll()
        
        // If either old collection or new collection is empty, return the row/column which simply consists of insertions/deletions
        if oldCount == 0 || newCount == 0 {
            return changesTable[oldCount][newCount]
        }
        
        // Iterate through the matrix, move by column, then row
        var oldCollectionIndex: T.Index
        var newCollectionIndex = newCollection.startIndex
        for column in 1...newCount {
            oldCollectionIndex = oldCollection.startIndex
            
            for row in 1...oldCount {
                if oldCollection[oldCollectionIndex] == newCollection[newCollectionIndex] {
                    changesTable[row][column] = changesTable[row - 1][column - 1]
                } else {
                    let previousRowChanges = changesTable[row - 1][column] // If least # of steps, current step is Deletion
                    let previousColumnChanges = changesTable[row][column - 1] // current step is Insertion
                    let previousRowAndColumnChanges = changesTable[row - 1][column - 1] // current step is Substitution
                    
                    let currentChanges: [Change<T.Generator.Element>]
                    let minimumCount = [previousRowChanges.count, previousColumnChanges.count, previousRowAndColumnChanges.count].minElement()!
                    
                    // Determine which has minimum changes, then add corresponding change
                    switch minimumCount {
                    case previousRowChanges.count:
                        currentChanges = previousRowChanges + [.Deletion(element: oldCollection[oldCollectionIndex], destination: row - 1)]
                    case previousColumnChanges.count:
                        currentChanges = previousColumnChanges + [.Insertion(element: newCollection[newCollectionIndex], destination: column - 1)]
                    default:
                        currentChanges = previousRowAndColumnChanges + [.Substitution(element: newCollection[newCollectionIndex], destination: column - 1)]
                    }
                    
                    // Save current changes to table
                    changesTable[row][column] = currentChanges
                }
                
                oldCollectionIndex = oldCollectionIndex.advancedBy(1)
            }
            
            newCollectionIndex = newCollectionIndex.advancedBy(1)
        }
        
        // Combine insertion and deletion pairs into a single move change
        return reduced ? reduceChanges(changesTable[oldCount][newCount]) : changesTable[oldCount][newCount]
    }
    
    private static func reduceChanges(changes: [Change<T.Generator.Element>]) -> [Change<T.Generator.Element>] {
        return changes.reduce([Change<T.Generator.Element>](), combine: { (var reducedChanges, var currentChange) in
            switch currentChange {
            case .Insertion(element: let element, destination: let insertionDestination):
                // Find deletion pair
                var deletionDestination: Int = 0
                guard let deletionIndex = reducedChanges.indexOf({ change in
                    if case .Deletion(element: element, destination: let destination) = change {
                        // Get deletion destination (origin of move)
                        deletionDestination = destination
                        return true
                    }
                    return false
                }) else {
                    // If no pair found, break from switch
                    break
                }
                
                // If deletion pair found, remove deletion and replace current change with Move
                reducedChanges.removeAtIndex(deletionIndex)
                currentChange = .Move(element: element, origin: deletionDestination, destination: insertionDestination)
            case .Deletion(element: let element, destination: let deletionDestination):
                // Find insertion pair
                var insertionDestination: Int = -1
                guard let insertionIndex = reducedChanges.indexOf({ change in
                    if case .Insertion(element: element, destination: let destination) = change {
                        // Get insertion destination (destination of move)
                        insertionDestination = destination
                        return true
                    }
                    return false
                }) else {
                    // If no pair found, break from switch
                    break
                }
                
                // If insertion pair found, remove insertion and replace current change with Move
                reducedChanges.removeAtIndex(insertionIndex)
                currentChange = .Move(element: element, origin: deletionDestination, destination: insertionDestination)
            default:
                break
            }
            
            reducedChanges.append(currentChange)
            return reducedChanges
        })
    }
}

public extension CollectionType where Generator.Element: Equatable, Index.Distance == Int {
    /**
     Get the changes occured in the receiver based on an old collection.
     
     - Parameters:
       - oldCollection: The old collection which the receiver will use to compute for changes
       - reduced: If set to `true`, insertion and deletion pairs will be combined into a `.Move` type. Default is `true`.
     
     - Returns: An array of changes occureed in the receiver based on the `oldCollection`.
    */
    public func changesSince(oldCollection: Self, reduced: Bool = true) -> [Change<Generator.Element>] {
        return ChangesSummary.changesOf(self, since: oldCollection, reduced: reduced)
    }
}

public extension String {
    /**
     Get the changes occured in the `String` based on an old collection.
     
     - Parameters:
       - oldCollection: The old collection which the receiver will use to compute for changes
       - reduced: If set to `true`, insertion and deletion pairs will be combined into a `.Move` type. Default is `true`.
     
     - Returns: An array of changes occureed in the receiver based on the `oldCollection`.
    */
    public func changesSince(oldCollection: String, reduced: Bool = true) -> [Change<Character>] {
        return characters.changesSince(oldCollection.characters, reduced: reduced)
    }
}

