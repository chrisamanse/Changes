import XCTest
@testable import Changes

class ChangesTests: XCTestCase {
    func testChangeEquality() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let insertion = Change.Insertion(element: 1, destination: 5)
        let deletion = Change.Deletion(element: 1, destination: 5)
        let substitution = Change.Substitution(element: 1, destination: 5)
        let move = Change.Move(element: 1, origin: 3, destination: 5)
        
        XCTAssertEqual(insertion, Change.Insertion(element: 1, destination: 5))
        XCTAssertEqual(deletion, Change.Deletion(element: 1, destination: 5))
        XCTAssertEqual(substitution, Change.Substitution(element: 1, destination: 5))
        XCTAssertEqual(move, Change.Move(element: 1, origin: 3, destination: 5))
        
        XCTAssertNotEqual(insertion, Change.Insertion(element: 1, destination: 7))
        XCTAssertNotEqual(deletion, Change.Deletion(element: 1, destination: 7))
        XCTAssertNotEqual(substitution, Change.Substitution(element: 1, destination: 7))
        XCTAssertNotEqual(move, Change.Move(element: 1, origin: 11, destination: 13))
    }
    
    func testChanges() {
        let string = "abcd"
        
        XCTAssertEqual(string.changes(since: ""), [
            Change.Insertion(element: "a", destination: 0),
            Change.Insertion(element: "b", destination: 1),
            Change.Insertion(element: "c", destination: 2),
            Change.Insertion(element: "d", destination: 3)
            ]
        )
        
        XCTAssertEqual("".changes(since: string), [
            Change.Deletion(element: "a", destination: 0),
            Change.Deletion(element: "b", destination: 1),
            Change.Deletion(element: "c", destination: 2),
            Change.Deletion(element: "d", destination: 3)
            ]
        )
        
        XCTAssertEqual("".changes(since: ""), [])
    }


    static var allTests : [(String, (ChangesTests) -> () throws -> Void)] {
        return [
            ("testChangeEquality", testChangeEquality),
            ("testChanges", testChanges)
        ]
    }
}
