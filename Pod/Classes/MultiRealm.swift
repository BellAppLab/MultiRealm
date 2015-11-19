import RealmSwift


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
        
        internal var queue: dispatch_queue_t {
            switch self
            {
            case .Main: return dispatch_get_main_queue()
            case .Background: return dispatch_queue_create("MultiRealmQueue", nil)
            }
        }
    }
    public typealias CreationBlock = () -> Void
    
    //MARK: Variables
    private(set) var realm: Realm!
    public let queue: dispatch_queue_t
    
    //MARK: Setup
    public init(_ queueType: Queue, _ creationBlock: CreationBlock)
    {
        self.queue = queueType.queue
        self.performBlock(creationBlock)
    }
    
    public mutating func set(realm: Realm)
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
        
        dispatch_async(self.queue, finalBlock)
    }
}
