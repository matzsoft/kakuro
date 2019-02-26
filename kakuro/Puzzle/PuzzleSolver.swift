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
        case found, stuck, finished, bogus
    }
    
    func step() -> Status {
        var status = Status.finished
        
        ( nrow, ncol ) = ( srow, scol )
        while let cell = next() {
            if let empty = cell as? EmptyCell, empty.solution == nil {
                status = .stuck
                if var horzSum = empty.horizontal?.horizontal {
                    if var vertSum = empty.vertical?.vertical {
                        empty.eligible = horzSum.eligible.intersection( vertSum.eligible )
                        
                        if empty.eligible.isEmpty {
                            return .bogus
                        }
                        if empty.eligible.count == 1 {
                            if let value = empty.eligible.first {
                                empty.solution = value
                                horzSum.remove( value: value )
                                vertSum.remove( value: value )
                            }
                            
                            ( srow, scol ) = ( nrow, ncol )
                            return .found
                        }
                    }
                }
            }
        }
        
        return status
    }
}
