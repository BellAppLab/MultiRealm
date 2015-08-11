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


public final class MultiRealm
{
    public var realm: Realm!
    private let queue: NSOperationQueue
    
    // MARK: Initializers
    
    /**
    Obtains a Realm instance persisted at the specified file path. Defaults to
    `Realm.defaultPath`
    
    :param: path Path to the realm file.
    :param: inBackground: Determines if the Realm should be created on a background thread
    */
    public convenience init(path: String = Realm.defaultPath, inBackground background: Bool) {
        self.init(path: path, readOnly: false, encryptionKey: nil, inBackground: background)
    }
    
    /**
    Obtains a `Realm` instance with persistence to a specific file path with
    options.
    
    Like `init(path:)`, but with the ability to open read-only realms and get
    errors as an `NSError` inout parameter rather than exceptions.
    
    :warning: Read-only Realms do not support changes made to the file while the
    `Realm` exists. This means that you cannot open a Realm as both read-only
    and read-write at the same time. Read-only Realms should normally only be used
    on files which cannot be opened in read-write mode, and not just for enforcing
    correctness in code that should not need to write to the Realm.
    
    :param: path            Path to the file you want the data saved in.
    :param: readOnly        Bool indicating if this Realm is read-only (must use for read-only files).
    :param: encryptionKey   64-byte key to use to encrypt the data.
    :param: inBackground: Determines if the Realm should be created on a background thread
    that describes the problem. If you are not interested in
    possible errors, omit the argument, or pass in `nil`.
    */
    public init(path: String, readOnly: Bool, encryptionKey: NSData? = nil, inBackground background: Bool) {
        if !background {
            assert(NSThread.currentThread() == NSThread.mainThread(), "Calls to init with 'inBackground = false' must be made from the main thread")
            self.queue = NSOperationQueue.mainQueue()
        } else {
            self.queue = NSOperationQueue()
            self.queue.maxConcurrentOperationCount = 1
            self.queue.name = "MultiRealmQueue"
        }
        self.performBlock { [unowned self] () -> () in
            var error = NSErrorPointer()
            if let realm = Realm(path: path, readOnly: readOnly, encryptionKey: encryptionKey, error: error) {
                self.realm = realm
            } else {
                NSException(name: NSInternalInconsistencyException, reason: error.debugDescription, userInfo: nil).raise()
            }
        }
    }
    
    public func performBlock(block: MultiRealmBlock)
    {
        var bgTaskId = startBackgroundTask()
        let finalBlock = { ()->() in
            block()
            endBackgroundTask(bgTaskId)
        }
        
        self.queue.addOperationWithBlock(finalBlock)
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
