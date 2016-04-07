import RealmSwift
import BLFixedThreadOperations


//MARK: - Handling background tasks in iOS
#if os(iOS)
    typealias BackgroundTaskId = UIBackgroundTaskIdentifier
    
    private func startBackgroundTask() -> BackgroundTaskId
    {
        var result = UIBackgroundTaskInvalid
        result = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(result)
            result = UIBackgroundTaskInvalid
        }
        return result
    }
    
    private func endBackgroundTask(backgroundTaskId: BackgroundTaskId)
    {
        if backgroundTaskId == UIBackgroundTaskInvalid {
            return
        }
        UIApplication.sharedApplication().endBackgroundTask(backgroundTaskId)
    }
#else
    typealias BackgroundTaskId = Int
    
    private func startBackgroundTask() -> BackgroundTaskId
    {
        return 0
    }
    
    private func endBackgroundTask(backgroundTaskId: BackgroundTaskId)
    {
        return
    }
#endif


//MARK: - Main
public struct MultiRealm
{
    //MARK: Defines
    public enum Queue
    {
        case Main, Background
    }
    public typealias CreationBlock = () -> Realm
    
    //MARK: Variables
    public private(set) var realm: Realm!
    public let queueType: Queue
    public let fixedThreadOpeationQueue: BLFixedThreadOperationQueue?
    
    //MARK: Setup
    public init(_ queueType: Queue, _ creationBlock: CreationBlock)
    {
        self.queueType = queueType
        switch self.queueType {
        case .Background:
            self.fixedThreadOpeationQueue = BLFixedThreadOperationQueue()
        default:
            self.fixedThreadOpeationQueue = nil
        }
        self.performBlock { 
            self.realm = creationBlock()
        }
    }
    
    private mutating func set(realm: Realm)
    {
        self.realm = realm
    }
    
    //MARK: Processing
    public func performBlock(block: () -> Void)
    {
        let bgTaskId = startBackgroundTask()
        let finalBlock = { () -> () in
            block()
            endBackgroundTask(bgTaskId)
        }
        
        if let queue = self.fixedThreadOpeationQueue {
            queue.addOperationWithBlock(finalBlock)
            return
        }
        
        dispatch_async(dispatch_get_main_queue(), finalBlock)
    }
}
