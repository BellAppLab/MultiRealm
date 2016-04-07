//
//  BLFixedThreadOperationQueue.m
//  Pods
//
//  Created by Bell App Lab on 23/12/15.
//
//

#import "BLFixedThreadOperationQueue.h"


@interface BLFixedThreadOperationQueue()

@property (nonatomic, strong) NSMutableArray<NSOperation *> *allOperations;
- (void)processOperations;

@end


@implementation BLFixedThreadOperationQueue

- (void)dealloc
{
    [_underlyingThread cancel];
}

#pragma mark -
#pragma mark Managing operations in the queue

- (void)addOperationWithBlock:(void (^)())block
{
    [self.allOperations addObject:[NSBlockOperation blockOperationWithBlock:block]];
    [self.underlyingThread start];
}

- (void)addOperations:(NSArray<NSOperation *> *)operations
{
    [self.allOperations addObjectsFromArray:operations];
    [self.underlyingThread start];
}

@synthesize allOperations = _allOperations;

- (NSMutableArray<NSOperation *> *)allOperations
{
    if (!_allOperations) {
        _allOperations = [NSMutableArray new];
    }
    return _allOperations;
}

- (NSArray<NSOperation *> *)operations
{
    if (_allOperations) return [NSArray arrayWithArray:_allOperations];
    return nil;
}

- (void)cancelAllOperations
{
    if (_allOperations.count == 0) return;
    for (NSOperation *operation in _allOperations) {
        [operation cancel];
    }
}

- (void)processOperations
{
    if (_allOperations.count == 0) {
        _allOperations = nil;
        [NSThread sleepUntilDate:[NSDate distantFuture]];
        return;
    }
    
    NSOperation *operation = [_allOperations objectAtIndex:0];
    [_allOperations removeObjectAtIndex:0];
    if (operation.isCancelled) {
        [self processOperations];
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    void(^completionBlock)() = operation.completionBlock;
    [operation setCompletionBlock:^{
        if (completionBlock) completionBlock();
        [weakSelf processOperations];
    }];
    [operation start];
}


#pragma mark - 
#pragma mark Properties

@synthesize name = _name;

- (NSString *)name
{
    if (_underlyingThread.name) return _underlyingThread.name;
    return _name;
}

- (void)setName:(NSString *)name
{
    _underlyingThread.name = name;
    _name = name;
}


#pragma mark - 
#pragma mark Configuring the thread

@synthesize underlyingThread = _underlyingThread;

- (NSThread *)underlyingThread
{
    if (!_underlyingThread) {
        _underlyingThread = [[NSThread alloc] initWithTarget:self
                                                    selector:@selector(processOperations)
                                                      object:nil];
        _underlyingThread.name = _name;
        _underlyingThread.threadPriority = 0.5;
    }
    return _underlyingThread;
}

- (void)setUnderlyingThread:(NSThread *)underlyingThread
{
    _underlyingThread = underlyingThread;
    _name = _underlyingThread.name;
}

@end
