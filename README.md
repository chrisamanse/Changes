# Changes
[![Build Status](https://travis-ci.org/chrisamanse/Changes.svg?branch=master)](https://travis-ci.org/chrisamanse/Changes)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

A Swift framework that computes changes occurred in a `CollectionType`. Inspired by [Changeset](https://github.com/ostestlag/Changeset).

Supports iOS and OSX.

# To-do

- [x] Carthage
- [ ] CocoaPods
- [ ] Other platforms

# Installation

- **Carthage**
  - Simply add `github "chrisamanse/Changes"` in your `Cartfile`
- **Manual**
  - Add this project as a subproject of your Xcode project
  - Or simply copy the source files

# Usage

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

# License

Copyright (c) 2016 Joe Christopher Paul Amanse

This software is distributed under the [MIT License](./LICENSE).
