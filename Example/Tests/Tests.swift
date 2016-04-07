import UIKit
import XCTest
import MultiRealm
import RealmSwift

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreation() {
        // This is an example of a functional test case.
        _ = MultiRealm(.Background) {
            var realm: Realm?
            do {
                realm = try Realm()
                XCTAssert(realm != nil, "Realm created successfully!")
                return realm
            } catch {
                print(error)
                XCTFail()
                return nil
            }
        }
    }
    
}
