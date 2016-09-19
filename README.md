# Changes
[![Build Status](https://travis-ci.org/chrisamanse/Changes.svg?branch=master)](https://travis-ci.org/chrisamanse/Changes)
![Swift Version](https://img.shields.io/badge/swift-3.0-orange.svg)
[![spm compatible](https://img.shields.io/badge/spm-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-4BC51D.svg)](https://github.com/CocoaPods/CocoaPods)
![Platform](https://img.shields.io/badge/platform-ios%20%7C%20macos%20%7C%20tvos%20%7C%20watchos%20%7C%20linux-lightgrey.svg)

A Swift framework that computes changes occurred in a `CollectionType`. Elements of the collection should also conform to `Equatable`. Inspired by [Changeset](https://github.com/osteslag/Changeset).

# Installation

- **Carthage**
  - Simply add `github "chrisamanse/Changes" ~> 2.0` in your `Cartfile`
- **CocoaPods**
  - Add `pod "Changes"` in your `Podfile`
- **Swift Package Manager**
  - Add `.Target(url: "https://github.com/chrisamanse/Changes.git, majorVersion: 2)` in dependencies
- **Manual**
  - Add this project as a subproject of your Xcode project
  - Or simply copy the source files

# Usage

## Change

Get changes of a `Collection` with elements that conform to `Equatable`.

```swift
let oldArray = [1,2,3,4,5]
let newArray = [1,3,2,4]

// Get changes
let changes = newArray.changes(since: oldArray)

// Prints out ["Moved 3 from index 2 to 1", "Deleted 5 at index 4"]
print(changes)
```

# License

Copyright (c) 2016 Joe Christopher Paul Amanse

This software is distributed under the [MIT License](./LICENSE).
