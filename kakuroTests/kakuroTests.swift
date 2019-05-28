//
//  kakuroTests.swift
//  kakuroTests
//
//  Created by Mark Johnson on 5/27/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import XCTest
@testable import kakuro

class kakuroTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    func testSolver() -> Void {
        let fileManager = FileManager.default
        let path = "/Users/markj/Development/kakuro/testdata"
        let dirEnum = fileManager.enumerator( atPath: path )
        var failedCount = 0
        
        while let file = dirEnum?.nextObject() {
            let filename = file as! NSString
            
            if filename.pathExtension == "kkr" {
                print( "Solving \(file)" )
                guard let puzzle = Puzzle( file: "\(path)/\(filename)" ) else {
                    failedCount += 1
                    print( "\(file) failed to create puzzle" )
                    continue
                }
                let solver = PuzzleSolver( with: puzzle )
                
                solveLoop: while true {
                    let status = solver.step()
                    
                    switch status {
                    case .bogus, .stuck:
                        failedCount += 1
                        print( "\(file) failed as \(status)" )
                    case .finished:
                        break solveLoop
                    case .informative, .found:
                        break
                    }
                }
            }
        }
        
        XCTAssert( failedCount < 2, "\(failedCount) files failed to solve" )
    }
    
    
//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
