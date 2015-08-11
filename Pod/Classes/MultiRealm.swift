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


//MARK: - Defines
public enum QueueType
{
    case Main, Background
}


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
    public convenience init(path: String = Realm.defaultPath, queueType: QueueType) {
        self.init(path: path, readOnly: false, encryptionKey: nil, inMemoryIdentifier: nil, queueType: queueType)
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
    public convenience init(path: String, readOnly: Bool, encryptionKey: NSData? = nil, queueType: QueueType) {
        self.init(path: path, readOnly: readOnly, encryptionKey: encryptionKey, inMemoryIdentifier: nil, queueType: queueType)
    }
    
    /**
    Obtains a Realm instance for an un-persisted in-memory Realm. The identifier
    used to create this instance can be used to access the same in-memory Realm from
    multiple threads.
    
    Because in-memory Realms are not persisted, you must be sure to hold on to a
    reference to the `Realm` object returned from this for as long as you want
    the data to last. Realm's internal cache of `Realm`s will not keep the
    in-memory Realm alive across cycles of the run loop, so without a strong
    reference to the `Realm` a new Realm will be created each time. Note that
    `Object`s, `List`s, and `Results` that refer to objects persisted in a Realm have a
    strong reference to the relevant `Realm`, as do `NotifcationToken`s.
    
    :param: identifier A string used to identify a particular in-memory Realm.
    */
    public convenience init(inMemoryIdentifier: String, queueType: QueueType) {
        self.init(path: nil, readOnly: nil, encryptionKey: nil, inMemoryIdentifier: nil, queueType: queueType)
    }
    
    public convenience init(realm: Realm, encryptionKey: NSData?, queueType: QueueType) {
        self.init(path: realm.path, readOnly: realm.readOnly, encryptionKey: encryptionKey, inMemoryIdentifier: nil, queueType: queueType)
    }
    
    private init(path: String?, readOnly: Bool?, encryptionKey: NSData? = nil, inMemoryIdentifier: String? = nil, queueType: QueueType) {
        if queueType == .Main {
            self.queue = NSOperationQueue.mainQueue()
        } else {
            self.queue = NSOperationQueue()
            self.queue.maxConcurrentOperationCount = 1
            self.queue.name = "MultiRealmQueue"
        }
        self.performBlock { [unowned self] () -> () in
            if var identifier = inMemoryIdentifier {
                self.realm = Realm(inMemoryIdentifier: identifier)
            } else {
                var error = NSErrorPointer()
                if let realm = Realm(path: path!, readOnly: readOnly!, encryptionKey: encryptionKey, error: error) {
                    self.realm = realm
                } else {
                    NSException(name: NSInternalInconsistencyException, reason: error.debugDescription, userInfo: nil).raise()
                }
            }
        }
    }
    
    public func performBlock(block: () -> Void)
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
    public func save(inMultiRealm multiRealm: MultiRealm, withBlock block: (() -> Void)?)
    {
        
        multiRealm.performBlock { [unowned self] () -> () in
            multiRealm.realm.write { [unowned self] () -> Void in
                multiRealm.realm.add(self, update: true)
            }
            block?()
        }
    }
    
    public class func saveAll<T: Object>(objects: Results<T>, inMultiRealm multiRealm: MultiRealm, withBlock block: (() -> Void)?)
    {
        multiRealm.performBlock { () -> () in
            multiRealm.realm.write { () -> Void in
                multiRealm.realm.add(objects, update: true)
            }
            block?()
        }
    }
    
    public func remove(fromMultiRealm multiRealm: MultiRealm, withBlock block: (() -> Void)?)
    {
        multiRealm.performBlock { [unowned self] () -> () in
            multiRealm.realm.write { [unowned self] () -> Void in
                multiRealm.realm.delete(self)
            }
            block?()
        }
    }
    
    public class func removeAll<T: Object>(objects: Results<T>, fromMultiRealm multiRealm: MultiRealm, withBlock block: (() -> Void)?)
    {
        multiRealm.performBlock { () -> () in
            multiRealm.realm.write { () -> Void in
                multiRealm.realm.delete(objects)
            }
            block?()
        }
    }
}
