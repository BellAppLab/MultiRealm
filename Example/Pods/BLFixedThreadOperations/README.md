# BLFixedThreadOperations

[![CI Status](http://img.shields.io/travis/Bell App Lab/BLFixedThreadOperations.svg?style=flat)](https://travis-ci.org/Bell App Lab/BLFixedThreadOperations)
[![Version](https://img.shields.io/cocoapods/v/BLFixedThreadOperations.svg?style=flat)](http://cocoapods.org/pods/BLFixedThreadOperations)
[![License](https://img.shields.io/cocoapods/l/BLFixedThreadOperations.svg?style=flat)](http://cocoapods.org/pods/BLFixedThreadOperations)
[![Platform](https://img.shields.io/cocoapods/p/BLFixedThreadOperations.svg?style=flat)](http://cocoapods.org/pods/BLFixedThreadOperations)

A wrapper around NSThread to mimic NSOperationQueues, but make them work with a single thread.
The main purpose of this library is to create a familiar interface (based on NSOperations) to handle NSThreads. This is particularly handy when dealing with other non-thread-safe libraries that cannot be handled by dispatch queues or NSOperationQueues.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

### CocoaPods

BLFixedThreadOperations is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "BLFixedThreadOperations"
```

### Git Submodules

**Why submodules, you ask?**

Following [this thread](http://stackoverflow.com/questions/31080284/adding-several-pods-increases-ios-app-launch-time-by-10-seconds#31573908) and other similar to it, and given that Cocoapods only works with Swift by adding the use_frameworks! directive, there's a strong case for not bloating the app up with too many frameworks. Although git submodules are a bit trickier to work with, the burden of adding dependencies should weigh on the developer, not on the user. :wink:

To install BLFixedThreadOperations using git submodules:

```
cd toYourProjectsFolder
git submodule add -b Submodule --name BLFixedThreadOperations https://github.com/BellAppLab/BLFixedThreadOperations.git
```

Navigate to the new BLFixedThreadOperations folder and drag the Pods folder to your Xcode project.

## Author

Bell App Lab, apps@bellapplab.com

## License

BLFixedThreadOperations is available under the MIT license. See the LICENSE file for more info.
