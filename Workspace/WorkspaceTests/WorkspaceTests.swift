//
//  WorkspaceTests.swift
//  WorkspaceTests
//
//  Created by Bernardo Breder on 14/02/16.
//  Copyright © 2016 breder. All rights reserved.
//

import XCTest
@testable import Workspace

class WorkspaceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testValue() {
        XCTAssertEqual(3, SwiftParser(code: "1+2").parseExpr()?.getValue())
        XCTAssertEqual(3, SwiftParser(code: "(1+2)").parseExpr()?.getValue())
        XCTAssertEqual(6, SwiftParser(code: "1+2+3").parseExpr()?.getValue())
        XCTAssertEqual(7, SwiftParser(code: "1+2*3").parseExpr()?.getValue())
        XCTAssertEqual(4, SwiftParser(code: "2*8/4").parseExpr()?.getValue())
        XCTAssertEqual(9, SwiftParser(code: "(1+2)*3").parseExpr()?.getValue())
        XCTAssertEqual(45, SwiftParser(code: "(2+3)*(4+5)").parseExpr()?.getValue())
        XCTAssertEqual(585, SwiftParser(code: "(2+3)*(4+5)*(6+7)").parseExpr()?.getValue())
        XCTAssertEqual(45, SwiftParser(code: " ( 2 + 3 ) * ( 4 + 5 ) ").parseExpr()?.getValue())
        XCTAssertEqual("abc", SwiftParser(code: "\"abc\"").parseExpr()?.getValue())
        XCTAssertEqual("abccba", SwiftParser(code: "\"abc\"+\"cba\"").parseExpr()?.getValue())
        XCTAssertNil(SwiftParser(code: "abc").parseExpr()?.getValue())
        XCTAssertTrue(SwiftParser(code: "1==1").parseExpr()?.getValue() as! Bool)
        XCTAssertFalse(SwiftParser(code: "1==2").parseExpr()?.getValue() as! Bool)
        XCTAssertTrue(SwiftParser(code: "1!=2").parseExpr()?.getValue() as! Bool)
        XCTAssertFalse(SwiftParser(code: "1!=1").parseExpr()?.getValue() as! Bool)
        XCTAssertTrue(SwiftParser(code: "1>=1").parseExpr()?.getValue() as! Bool)
        XCTAssertFalse(SwiftParser(code: "1>=2").parseExpr()?.getValue() as! Bool)
        XCTAssertTrue(SwiftParser(code: "1<=2").parseExpr()?.getValue() as! Bool)
        XCTAssertFalse(SwiftParser(code: "2<=1").parseExpr()?.getValue() as! Bool)
        XCTAssertTrue(SwiftParser(code: "2>1").parseExpr()?.getValue() as! Bool)
        XCTAssertFalse(SwiftParser(code: "1>2").parseExpr()?.getValue() as! Bool)
        XCTAssertTrue(SwiftParser(code: "1<2").parseExpr()?.getValue() as! Bool)
        XCTAssertFalse(SwiftParser(code: "1<1").parseExpr()?.getValue() as! Bool)
    }
    
    func testCommand() {
        SwiftParser(code: "1+2").parseCommand()?.execute()
        SwiftParser(code: "let a").parseCommand()?.execute()
        SwiftParser(code: "let a = 1+2").parseCommand()?.execute()
        SwiftParser(code: "let a: Int = 1+2").parseCommand()?.execute()
        SwiftParser(code: "let a: Int? = nil").parseCommand()?.execute()
    }
    
    func testPerformanceParse() {
        var str: String = ""
        str += "0"
        for _ in 1 ... 1024 {
            str += "+1"
        }
        self.measure {
            SwiftParser(code: str).parse()
        }
    }
    
    func testPerformanceValue() {
        var str: String = "0"
        for _ in 1 ... 1024 {
            str += "+1"
        }
        let node: SwiftValueNode = SwiftParser(code: str).parseExpr()!
        node.cleanDebug()
        self.measure {
            node.getValue()
        }
    }
    
}
