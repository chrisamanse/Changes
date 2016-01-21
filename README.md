# Changes
[![Build Status](https://travis-ci.org/chrisamanse/Changes.svg?branch=master)](https://travis-ci.org/chrisamanse/Changes)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-4BC51D.svg)](https://github.com/CocoaPods/CocoaPods)

A Swift framework that computes changes occurred in a `CollectionType`. Elements of the collection should also conform to `Equatable`. Inspired by [Changeset](https://github.com/osteslag/Changeset).

**Supports**:
  - iOS 8.0+
  - OSX 10.10+

# To-do

- [x] Tests with Quick and Nimble
- [x] Carthage
- [x] CocoaPods
- [ ] Other platforms

# Installation

- **Carthage**
  - Simply add `github "chrisamanse/Changes"` in your `Cartfile`
- **CocoaPods**
  - Use `use_frameworks!`
  - Add `pod "Changes"`
- **Manual**
  - Add this project as a subproject of your Xcode project
  - Or simply copy the source files

# Usage

## Change

Get changes of any `CollectionType` with elements that conform to `Equatable`.

```swift
let oldArray = [1,2,3,4,5]
let newArray = [1,3,2,4]

// Get changes
// Returns [Change<Element>] where Element is the element type of the collection
// Change<Element> is an enum which have cases for Insertion, Deletion, Substitution, and Move
let changes = newArray.changesSince(oldArray)

// Prints out ["Moved 3 from index 2 to 1", "Deleted 5 at index 4"]
print(changes)
```

## ObservableCollection

Observe changes in a collection. Perfect for `UITableView`s and `UICollectionView`s.

```swift
class Observer: ChangeObserver {
    func observableCollectionWillBeginChanges<T>(observableCollection: ObservableCollection<T>) {
        // Prepare for changes
    }
    func observableCollection<T>(observableCollection: ObservableCollection<T>, didOccurChange change: Change<T.Generator.Element>) {
        switch change {
        case .Insertion(element: let insertedElement, destination: let insertIndex):
            // Handle insertion
        case .Deletion(element: let deletedElement, destination: let deletedIndex):
            // Handle deletion
        case .Substitution(element: let newElement, destination: let index):
            // Handle substitution
        case .Move(element: let movedElement, origin: let origin, destination: let destination):
            // Handle move
        }
    }
    func observableCollectionDidEndChanges<T>(observableCollection: ObservableCollection<T>) {
        // Finished changes
    }
}

// Set observer
let observer = Observer()
var observableCollection = ObservableCollection(initialValue: [1,2,3,4,5,6])
observableCollection.observer = observer

observableCollection.currentValue // Current value of collection
observableCollection.currentValue = [1,2,3,5,4] // Set current value and observer will receive changes

```

# License

Copyright (c) 2016 Joe Christopher Paul Amanse

This software is distributed under the [MIT License](./LICENSE).
