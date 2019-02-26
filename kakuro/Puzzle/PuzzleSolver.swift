//
//  PuzzleSolver.swift
//  kakuro
//
//  Created by Mark Johnson on 2/25/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

class PuzzleSolver: Puzzle {
    var srow = 0
    var scol = 0
    var nrow = 0
    var ncol = 0
    
    convenience init(with puzzle: Puzzle) {
        self.init()
        cells = puzzle.cells
    }
    
    func next() -> Cell? {
        let cell = cells[nrow][ncol]
        
        ncol += 1
        if ncol >= cells[nrow].count {
            ncol = 0
            nrow += 1
            if nrow >= nrows {
                nrow = 0
            }
        }
        
        if nrow == srow && ncol == scol {
            return nil
        }
        
        return cell
    }
    
    enum Status {
        case found, stuck, finished
    }
    
    func step() -> Status {
        var status = Status.finished
        
        ( nrow, ncol ) = ( srow, scol )
        while let cell = next() {
            switch cell {
            case let empty as EmptyCell where empty.solution == nil:
                status = .stuck
                if let horzEligible = empty.horizontal?.horizontal?.eligible {
                    if let vertEligible = empty.vertical?.vertical?.eligible {
                        empty.eligible = horzEligible.intersection( vertEligible )
                    }
                }
                if empty.eligible.count == 1 {
                    empty.solution = empty.eligible.first
                    ( srow, scol ) = ( nrow, ncol )
                    return .found
                }
            default:
                break
            }
        }
        
        return status
    }
}
