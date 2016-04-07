# BLFixedThreadOperations

[![CI Status](http://img.shields.io/travis/Bell App Lab/BLFixedThreadOperations.svg?style=flat)](https://travis-ci.org/Bell App Lab/BLFixedThreadOperations)
[![Version](https://img.shields.io/cocoapods/v/BLFixedThreadOperations.svg?style=flat)](http://cocoapods.org/pods/BLFixedThreadOperations)
[![License](https://img.shields.io/cocoapods/l/BLFixedThreadOperations.svg?style=flat)](http://cocoapods.org/pods/BLFixedThreadOperations)
[![Platform](https://img.shields.io/cocoapods/p/BLFixedThreadOperations.svg?style=flat)](http://cocoapods.org/pods/BLFixedThreadOperations)

A wrapper around NSThread to mimic NSOperationQueues, but make them work with a single thread.
The main purpose of this library is to create a familiar interface (based on NSOperations) to handle NSThreads. This is particularly handy when dealing with other non-thread-safe libraries that cannot be handled by dispatch queues or NSOperationQueues.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

BLFixedThreadOperations is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "BLFixedThreadOperations"
```

## Author

Bell App Lab, apps@bellapplab.com

## License

BLFixedThreadOperations is available under the MIT license. See the LICENSE file for more info.
