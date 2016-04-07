//
//  BLFixedThreadOperationQueue.h
//  Pods
//
//  Created by Bell App Lab on 23/12/15.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLFixedThreadOperationQueue : NSObject

/*
    Managing operations in the queue
 */

- (void)addOperationWithBlock:(void(^)())block;
- (void)addOperations:(NSArray<NSOperation *> *) operations;

@property (nonatomic, readonly) NSArray<NSOperation *> * _Nullable operations;

- (void)cancelAllOperations;

/*
    Properties
 */
@property (nonatomic, copy) NSString * _Nullable name;

/*
    Configuring the thread
 */
@property (nonatomic, strong) NSThread *underlyingThread;

@end

NS_ASSUME_NONNULL_END
