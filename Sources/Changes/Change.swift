//
//  Change.swift
//  Diff
//
//  Created by Chris Amanse on 09/19/2016.
//
//

/// Describes the type of change
///
/// - Insertion:    A change of type insertion with an `element` that was inserted in the collection and a `destination` where the element was inserted.
/// - Deletion:     A change of type deletion with an `element` that was deleted in the collection and a `destination` where the element was deleted.
/// - Substitution: A change of type substitution with an `element` as the new element in the collection and a `destination` where the element was overwritten. For example, changes of `[1,2,3]` since `[1,2,4]` (the old collection), will have a `Substitution` change with `element` 3 (the new element) and `destination` 2 (index starts at 0).
/// - Move:         A change of type move with a `element` that was moved in the collection, and the element's `origin` and `destination`.
public enum Change<T: Equatable> {
    case Insertion(element: T, destination: Int)
    case Deletion(element: T, destination: Int)
    case Substitution(element: T, destination: Int)
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

extension Change: Equatable {
    public static func ==<T: Equatable>(lhs: Change<T>, rhs: Change<T>) -> Bool {
        switch (lhs, rhs) {
        case (.Insertion(let x), .Insertion(let y)):
            return x == y
        case (.Deletion(let x), .Deletion(let y)):
            return x == y
        case (.Substitution(let x), .Substitution(let y)):
            return x == y
        case (.Move(let x), .Move(let y)):
            return x == y
        default:
            return true
        }
    }
}
