# MultiRealm

[![CI Status](http://img.shields.io/travis/Bell App Lab/MultiRealm.svg?style=flat)](https://travis-ci.org/Bell App Lab/MultiRealm)
[![Version](https://img.shields.io/cocoapods/v/MultiRealm.svg?style=flat)](http://cocoapods.org/pods/MultiRealm)
[![License](https://img.shields.io/cocoapods/l/MultiRealm.svg?style=flat)](http://cocoapods.org/pods/MultiRealm)
[![Platform](https://img.shields.io/cocoapods/p/MultiRealm.svg?style=flat)](http://cocoapods.org/pods/MultiRealm)

## Usage

Instead of this:

```swift
let realm = try! Realm()
```

**Do this:**

```swift
let multiRealm = MultiRealm(.Background) {
    let realm = try! Realm()
    multiRealm.set(realm)
}
```

And then, when you need to perform operations with that Realm:

```swift
multiRealm.performBlock {
    //save your objects
    try! multiRealm.realm.write() { ... }
}
```

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 8+
OSX 10.10+
RealmSwift

## Installation

MultiRealm is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MultiRealm"
```

## Author

Bell App Lab, apps@bellapplab.com

## License

MultiRealm is available under the MIT license. See the LICENSE file for more info.
