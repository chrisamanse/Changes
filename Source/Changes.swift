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
     A change of type insertion with a `value` that was inserted in the collection and
     a `destination` where the element was inserted.
    */
    case Insertion(value: T, destination: Int)
    
    /**
     A change of type deletion with a `value` that was deleted in the collection and
     a `destination` where the element was deleted.
     */
    case Deletion(value: T, destination: Int)
    
    /**
     A change of type substitution with a `value` as the new element in the collection and
     a `destination` where the element was overwritten.
     For example, changes of `[1,2,3]` since `[1,2,4]` (the old collection), will have a
     `Substitution` change with `value` 3 (the new value) and `destination` 2 (index starts at 0).
     */
    case Substitution(value: T, destination: Int)
    
    /**
     A change of type move with a `value` that was moved in the collection, and
     the element's `origin` and `destination`.
    */
    case Move(value: T, origin: Int, destination: Int)
}

extension Change: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Insertion(value: let value, destination: let destination):
            return "Inserted \(value) at index \(destination)"
        case .Deletion(value: let value, destination: let destination):
            return "Deleted \(value) at index \(destination)"
        case .Substitution(value: let value, destination: let destination):
            return "Substituted with \(value) at index \(destination)"
        case .Move(value: let value, origin: let origin, destination: let destination):
            return "Moved \(value) from index \(origin) to \(destination)"
        }
    }
}

extension Change: Equatable {}
public func ==<T: Equatable>(lhs: Change<T>, rhs: Change<T>) -> Bool {
    switch (lhs, rhs) {
    case (.Insertion(value: let value1, destination: let destination1),
        .Insertion(value: let value2, destination: let destination2)):
        return value1 == value2 && destination1 == destination2
    case (.Substitution(value: let value1, destination: let destination1),
        .Substitution(value: let value2, destination: let destination2)):
        return value1 == value2 && destination1 == destination2
    case (.Deletion(value: let value1, destination: let destination1),
        .Deletion(value: let value2, destination: let destination2)):
        return value1 == value2 && destination1 == destination2
    case (.Move(value: let value1, origin: let origin1, destination: let destination1),
        .Move(value: let value2, origin: let origin2, destination: let destination2)):
        return value1 == value2 && destination1 == destination2 && origin1 == origin2
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
        
        // Changes for each index of old value to an empty string
        var changes: [Change<T.Generator.Element>] = []
        for (row, object) in oldCollection.enumerate() {
            changes.append(.Deletion(value: object, destination: row))
            changesTable[row + 1][0] = changes
        }
        changes.removeAll()
        
        // Changes for old value as empty string to each index of new value
        for (column, object) in newCollection.enumerate() {
            changes.append(.Insertion(value: object, destination: column))
            changesTable[0][column + 1] = changes
        }
        changes.removeAll()
        
        // If either old value or new value is empty, return the row/column which simply consists insertions/deletions
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
                        currentChanges = previousRowChanges + [.Deletion(value: oldCollection[oldCollectionIndex], destination: row - 1)]
                    case previousColumnChanges.count:
                        currentChanges = previousColumnChanges + [.Insertion(value: newCollection[newCollectionIndex], destination: column - 1)]
                    default:
                        currentChanges = previousRowAndColumnChanges + [.Substitution(value: newCollection[newCollectionIndex], destination: column - 1)]
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
            case .Insertion(value: let value, destination: let insertionDestination):
                // Find deletion pair
                var deletionDestination: Int = 0
                guard let deletionIndex = reducedChanges.indexOf({ change in
                    if case .Deletion(value: value, destination: let destination) = change {
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
                currentChange = .Move(value: value, origin: deletionDestination, destination: insertionDestination)
            case .Deletion(value: let value, destination: let deletionDestination):
                // Find insertion pair
                var insertionDestination: Int = -1
                guard let insertionIndex = reducedChanges.indexOf({ change in
                    if case .Insertion(value: value, destination: let destination) = change {
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
                currentChange = .Move(value: value, origin: deletionDestination, destination: insertionDestination)
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
     Get the changes occured in the receiver based on an old value.
     
     - Parameters:
       - oldCollection: The old collection which the receiver will use to compute for changes
       - reduced: If set to `true`, insertion and deletion pairs will be combined into a `.Move` type. Default is `true`.
     
     - Returns: An array of changes occureed in the receiver based on the `oldValue`.
    */
    public func changesSince(oldCollection: Self, reduced: Bool = true) -> [Change<Generator.Element>] {
        return ChangesSummary.changesOf(self, since: oldCollection, reduced: reduced)
    }
}

public extension String {
    /**
     Get the changes occured in the `String` based on an old value.
     
     - Parameters:
       - oldCollection: The old collection which the receiver will use to compute for changes
       - reduced: If set to `true`, insertion and deletion pairs will be combined into a `.Move` type. Default is `true`.
     
     - Returns: An array of changes occureed in the receiver based on the `oldValue`.
    */
    public func changesSince(oldCollection: String, reduced: Bool = true) -> [Change<Character>] {
        return characters.changesSince(oldCollection.characters, reduced: reduced)
    }
}

