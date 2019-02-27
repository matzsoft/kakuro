//
//  PuzzleSolver.swift
//  kakuro
//
//  Created by Mark Johnson on 2/25/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

class PuzzleSolver: Puzzle {
    var srow = 0        // Start row
    var scol = 0        // Start column
    var crow = 0        // Current row
    var ccol = 0        // Current column
    var nrow = 0        // Next row
    var ncol = 0        // Next column

    convenience init(with puzzle: Puzzle) {
        self.init()
        cells = puzzle.cells
        prepareHeaders()
    }
    
    func next() -> Cell? {
        let cell = cells[nrow][ncol]
        
        ( crow, ccol ) = ( nrow, ncol )
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
    
    private func prepareHeaders() -> Void {
        ( nrow, ncol ) = ( srow, scol )
        while let cell = next() {
            if let header = cell as? HeaderCell {
                prepareVertical( header )
                prepareHorizontal( header )
            }
        }
    }
    
    
    private func prepareHorizontal( _ header: HeaderCell ) {
        guard let sum = header.horizontal else { return }
        var cells: [EmptyCell] = []
        
        for newCol in ccol + 1 ..< self.cells[crow].count {
            guard let cell = self.cells[crow][newCol] as? EmptyCell else { break }
            
            cell.horizontal = header
            cells.append(cell)
        }
        
        sum.setCells( cells: cells )
    }
    
    private func prepareVertical( _ header: HeaderCell ) {
        guard let sum = header.vertical else { return }
        var cells: [EmptyCell] = []
        
        for newRow in crow + 1 ..< nrows {
            guard let cell = self.cells[newRow][ccol] as? EmptyCell else { break }
            
            cell.vertical = header
            cells.append(cell)
        }
        
        sum.setCells( cells: cells )
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
                if let horzSum = empty.horizontal?.horizontal {
                    if let vertSum = empty.vertical?.vertical {
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
                        
                        horzSum.requireSome( of: empty.eligible )
                        vertSum.requireSome( of: empty.eligible )
                    }
                }
            }
        }
        
        return status
    }
}
