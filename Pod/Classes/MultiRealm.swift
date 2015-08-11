import RealmSwift


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


public typealias MultiRealmBlock = ()->()


public struct MultiRealm
{
    public let realm: Realm
    private var queue: NSOperationQueue?
    
    public init(realm: Realm, inBackground background: Bool)
    {
        if background {
            self.queue = NSOperationQueue()
            self.queue!.maxConcurrentOperationCount = 1
            self.queue!.name = "MultiRealmQueue"
        } else {
            assert(NSThread.currentThread() == NSThread.mainThread(), "Calls to init with 'inBackground = false' must be made from the main thread")
        }
        self.realm = realm
    }
    
    public func performBlock(block: MultiRealmBlock)
    {
        var bgTaskId = startBackgroundTask()
        let finalBlock = { ()->() in
            block()
            endBackgroundTask(bgTaskId)
        }
        
        if var queue = self.queue {
            queue.addOperationWithBlock(finalBlock)
            return
        }
        dispatch_async(dispatch_get_main_queue(), finalBlock)
    }
}


public extension Object
{
    public func save(inMultiRealm multiRealm: MultiRealm, withBlock block: MultiRealmBlock?)
    {
        
        multiRealm.performBlock { [unowned self] () -> () in
            multiRealm.realm.write { [unowned self] () -> Void in
                multiRealm.realm.add(self, update: true)
            }
            block?()
        }
    }
    
    public class func saveAll<T: Object>(objects: Results<T>, inMultiRealm multiRealm: MultiRealm, withBlock block: MultiRealmBlock?)
    {
        multiRealm.performBlock { () -> () in
            multiRealm.realm.write { () -> Void in
                multiRealm.realm.add(objects, update: true)
            }
            block?()
        }
    }
    
    public func remove(fromMultiRealm multiRealm: MultiRealm, withBlock block: MultiRealmBlock?)
    {
        multiRealm.performBlock { [unowned self] () -> () in
            multiRealm.realm.write { [unowned self] () -> Void in
                multiRealm.realm.delete(self)
            }
            block?()
        }
    }
    
    public class func removeAll<T: Object>(objects: Results<T>, fromMultiRealm multiRealm: MultiRealm, withBlock block: MultiRealmBlock?)
    {
        multiRealm.performBlock { () -> () in
            multiRealm.realm.write { () -> Void in
                multiRealm.realm.delete(objects)
            }
            block?()
        }
    }
}
