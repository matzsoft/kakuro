//
//  CircularIterator2D.swift
//  kakuro
//
//  Created by Mark Johnson on 3/14/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

class CircularIterator2D<Element> {
    var array: [[Element]]
    var started = false
    var srow = 0        // Start row
    var scol = 0        // Start column
    var crow = 0        // Current row
    var ccol = 0        // Current column
    var nrow = 0        // Next row
    var ncol = 0        // Next column
    
    init( array: inout [[Element]] ) {
        self.array = array
    }
    
    func next() -> Element? {
        if started && nrow == srow && ncol == scol {
            return nil
        }
        
        ( crow, ccol ) = ( nrow, ncol )
        started = true
        ncol += 1
        if ncol >= array[nrow].count {
            ncol = 0
            nrow += 1
            if nrow >= array.count {
                nrow = 0
            }
        }
        
        return array[crow][ccol]
    }
    
    func reset() -> Void {
        started = false
        ( srow, scol, crow, ccol, nrow, ncol ) = ( 0, 0, 0, 0, 0, 0 )
    }
    
    func markStart() -> Void {
        started = false
        ( srow, scol ) = ( nrow, ncol )
    }
}
