//
//  PuzzleValidator.swift
//  kakuro
//
//  Created by Mark Johnson on 4/27/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

fileprivate let totalRanges: [ ( min: Int, max: Int ) ] = [
    ( min: 0, max: 0 ), ( min: 0, max: 0 ), ( min: 0, max: 0 ),     // 0, 1, 2 - not used
    ( min: 2, max: 2 ), ( min: 2, max: 2 ), ( min: 2, max: 2 ),     // 3, 4, 5
    ( min: 2, max: 3 ), ( min: 2, max: 3 ), ( min: 2, max: 3 ),     // 6, 7, 8
    ( min: 2, max: 3 ), ( min: 2, max: 4 ), ( min: 2, max: 4 ),     // 9, 10, 11
    ( min: 2, max: 4 ), ( min: 2, max: 4 ), ( min: 2, max: 4 ),     // 12, 13, 14
    ( min: 2, max: 5 ), ( min: 2, max: 5 ), ( min: 2, max: 5 ),     // 15, 16, 17
    ( min: 3, max: 5 ), ( min: 3, max: 5 ), ( min: 3, max: 5 ),     // 18, 19, 20
    ( min: 3, max: 6 ), ( min: 3, max: 6 ), ( min: 3, max: 6 ),     // 21, 22, 23
    ( min: 3, max: 6 ), ( min: 4, max: 6 ), ( min: 4, max: 6 ),     // 24, 25, 26
    ( min: 4, max: 6 ), ( min: 4, max: 7 ), ( min: 4, max: 7 ),     // 27, 28, 29
    ( min: 4, max: 7 ), ( min: 5, max: 7 ), ( min: 5, max: 7 ),     // 30, 31, 32
    ( min: 5, max: 7 ), ( min: 5, max: 7 ), ( min: 5, max: 7 ),     // 33, 34, 35
    ( min: 6, max: 8 ), ( min: 6, max: 8 ), ( min: 6, max: 8 ),     // 36, 37, 38
    ( min: 6, max: 8 ), ( min: 7, max: 8 ), ( min: 7, max: 8 ),     // 39, 40, 41
    ( min: 7, max: 8 ), ( min: 8, max: 8 ), ( min: 8, max: 8 ),     // 42, 43, 44
    ( min: 9, max: 9 ),                                             // 45
]

class PuzzleValidator: Puzzle {
    var errors: [ String ] = []
    
    convenience init(with puzzle: Puzzle) {
        self.init()
        cells = puzzle.cells
    }
    
    var isValid: Bool {
        errors = []
        
        guard nrows > 0 else {
            errors.append("puzzle is empty")
            return false
        }
        
        for row in 0 ..< nrows {
            if cells[row].count != ncols {
                errors.append("Row \(row + 1) has incorrect length")
            }
        }
        
        guard errors.count == 0 else { return false }
        
        for row in 0 ..< nrows {
            for col in 0 ..< ncols {
                switch cells[row][col] {
                case is UnusedCell:
                    break
                case is EmptyCell:
                    validateEmptyCell(row: row, col: col)
                case let header as HeaderCell:
                    validateHeaderCell(header: header, row: row, col: col)
                default:
                    cellError(row: row, col: col, error: "has unknown cell type")
                }
            }
        }
        
        return errors.count == 0
    }
    
    private func cellError( row: Int, col: Int, error: String) {
        errors.append("Cell at \(row+1),\(col+1) \(error)")
    }
    
    private func validateEmptyCell(row: Int, col: Int) {
        if row == 0 || col == 0 {
            cellError(row: row, col: col, error: "is orphaned")
        } else {
            let leftCell = cells[row][col-1]
            let upCell = cells[row-1][col]
            
            if leftCell is UnusedCell || upCell is UnusedCell {
                cellError(row: row, col: col, error: "is orphaned")
            } else {
                if leftCell is HeaderCell {
                    let header = leftCell as! HeaderCell
                    
                    if header.horizontal == nil {
                        cellError(row: row, col: col, error: "is orphaned")
                    }
                }
                if upCell is HeaderCell {
                    let header = upCell as! HeaderCell
                    
                    if header.vertical == nil {
                        cellError(row: row, col: col, error: "is orphaned")
                    }
                }
            }
        }
    }
    
    private func validateHeaderCell(header: HeaderCell, row: Int, col: Int) {
        if header.hasNoTotal() {
            cellError(row: row, col: col, error: "has no total")
        } else {
            switch row {
            case 0:
                if let _ = header.horizontal {
                    cellError(row: row, col: col, error: "should not have horizontal total")
                }
            case nrows - 1:
                if let _ = header.vertical {
                    cellError(row: row, col: col, error: "should not have vertical total")
                }
            default:
                if let horz = header.vertical {
                    validateVerticalTotal(horz, row: row, col: col)
                }
            }
            switch col {
            case 0:
                if let _ = header.vertical {
                    cellError(row: row, col: col, error: "should not have vertical total")
                }
            case ncols - 1:
                if let _ = header.horizontal {
                    cellError(row: row, col: col, error: "should not have horizontal total")
                }
            default:
                if let horz = header.horizontal {
                    validateHorizontalTotal(horz, row: row, col: col)
                }
            }
        }
    }
    
    private func validateHorizontalTotal(_ total: Int, row: Int, col: Int) {
        var count = 0
        
        for newCol in col + 1 ..< ncols {
            if !( cells[row][newCol] is EmptyCell ) {
                break
            }
            count += 1
        }
        
        if count < totalRanges[total].min {
            cellError(row: row, col: col, error: "doesn't have enough empty cells on the right")
        } else if count > totalRanges[total].max {
            cellError(row: row, col: col, error: "has too many empty cells on the right")
        }
    }
    
    private func validateVerticalTotal(_ total: Int, row: Int, col: Int) {
        var count = 0
        
        for newRow in row + 1 ..< nrows {
            if !( cells[newRow][col] is EmptyCell ) {
                break
            }
            count += 1
        }
        
        if count < totalRanges[total].min {
            cellError(row: row, col: col, error: "doesn't have enough empty below")
        } else if count > totalRanges[total].max {
            cellError(row: row, col: col, error: "has too many empty cells below")
        }
    }
}