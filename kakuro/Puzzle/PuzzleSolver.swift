//
//  PuzzleSolver.swift
//  kakuro
//
//  Created by Mark Johnson on 2/25/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

class PuzzleSolver: Puzzle {
    var headerSums: [HeaderSum] = []
    var srow = 0        // Start row
    var scol = 0        // Start column
    var crow = 0        // Current row
    var ccol = 0        // Current column
    var nrow = 0        // Next row
    var ncol = 0        // Next column

    convenience init(with puzzle: Puzzle) {
        self.init()
        cells = puzzle.cells
        setupPuzzle()
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
    
    private func setupPuzzle() -> Void {
        ( nrow, ncol ) = ( srow, scol )
        while let cell = next() {
            switch cell {
            case is UnusedCell:
                break
            case let empty as EmptyCell:
                empty.solution = nil
            case let header as HeaderCell:
                setupVertical( header )
                setupHorizontal( header )
            default:
                break
            }
        }
    }
    
    
    private func setupHorizontal( _ header: HeaderCell ) {
        guard let sum = header.horizontal else { return }
        var cells: [EmptyCell] = []
        
        for newCol in ccol + 1 ..< self.cells[crow].count {
            guard let cell = self.cells[crow][newCol] as? EmptyCell else { break }
            
            cell.horizontal = header
            cells.append(cell)
        }
        
        sum.setCells( cells: cells )
        headerSums.append( sum )
    }
    
    private func setupVertical( _ header: HeaderCell ) {
        guard let sum = header.vertical else { return }
        var cells: [EmptyCell] = []
        
        for newRow in crow + 1 ..< nrows {
            guard let cell = self.cells[newRow][ccol] as? EmptyCell else { break }
            
            cell.vertical = header
            cells.append(cell)
        }
        
        sum.setCells( cells: cells )
        headerSums.append( sum )
    }


    enum Status {
        case informative, found, finished, stuck, bogus
    }

    
    // This function is responsible for finding the solution for one cell of the puzzle.
    // Its return values are:
    //      .found       - a single cell of the puzzle was solved
    //      .informative - no solution, but information was obtained that makes it worth proceeding
    //      .finished    - all cells have already been solved
    //      .stuck       - the solver is unable to advance
    //      .bogus       - the puzzle was found to be unsolvable, i.e inconsistent in some way
    func step() -> Status {
        var status = basic()
        
        if status != .stuck {
            return status
        }
        
        status = reduceRequired()
        if status != .stuck {
            return status
        }
        
        status = elimination()
        return status
    }
    
    
    // This function implements the most simple strategy for puzzle solving.
    // Its return values have the same meaning as the step function.  It has a
    // very important side effect.  All empty cells will have their eligible
    // member set to represent the current knowledge of the puzzle solution.
    // This side effect is used by all subsequent solution strategies.
    //
    // The strategy involves looping through all empty cells that have not yet
    // been solved.  When one is found then its eligible property is set to the
    // intersection of the eligible properties of its vertical and horizontal
    // header cells.
    //
    // If that intersection is emtpy then the puzzle is unsolvable and .bogus
    // is returned.
    //
    // If that intersection has only a single element then that becomes the
    // solution for that cell.  The horizontal and vertical headers are updated
    // appropriately and .found is returned.  Note that in subsequent calls to
    // this function the loop resumes where it left off rather than at the
    // beginning of the puzzle.
    //
    // If the intersection has multiple elements, then the vertical and
    // horizontal headers are updated with that information.  In this case the
    // function does not return but continues to look for a solution.
    //
    // The loop may return to its starting position without finding
    // the solution for any cell.  In this case the function will return 1 of 3
    // values:
    //      1. .finished if no unsolved empty cells were found
    //      2. .informative if some information was gleaned for any cell
    //      3. .stuck otherwise
    //
    func basic() -> Status {
        var status = Status.finished

        ( nrow, ncol ) = ( srow, scol )
        while let cell = next() {
            if let empty = cell as? EmptyCell, empty.solution == nil {
                if status == .finished { status = .stuck }
                if let horzSum = empty.horizontal?.horizontal, let vertSum = empty.vertical?.vertical {
                    let eligible = horzSum.eligible.intersection( vertSum.eligible )
                    let newStatus = empty.restrict( to: eligible )
                    
                    switch newStatus {
                    case .found:
                        ( srow, scol ) = ( nrow, ncol )
                        return newStatus
                    case .finished, .bogus:
                        return newStatus
                    case .informative, .stuck:
                        break
                    }
                }
            }
        }

        return status
    }
    
    func reduceRequired() -> Status {
        var status = Status.stuck
        
        for sum in headerSums {
            let required = sum.possibles.reduce( Set<Int>( 1...9 ), { $0.intersection( $1 ) } )
            
            if required.count > 0 {
                let cells = sum.cells.filter { !$0.eligible.isDisjoint( with: required ) }
                
                if required.count == cells.count {
                    for empty in cells {
                        let newStatus = empty.restrict( to: required )
                        
                        switch newStatus {
                        case .found, .finished, .bogus:
                            return newStatus
                        case .informative:
                            status = newStatus
                        case .stuck:
                            break
                        }
                    }
                }
            }
        }
        
        return status
    }
    
    func elimination() -> Status {
        var status = Status.stuck
        
        for sum in headerSums {
            let cells = sum.cells.filter { $0.solution == nil }
            
            if cells.count == 1 {
                if cells[0].eligible.count != 1 {
                    return .bogus
                }
                
                cells[0].found( solution: cells[0].eligible.first! )
                return .found
            }
            
            if cells.count > 1 {
                let base = cells.min { $0.eligible.count < $1.eligible.count }!
                var eligible = Set<Int>()
                var possibles = Set<Set<Int>>()
                
                for value in base.eligible {
                    let valid = sum.possibles.filter { $0.contains( value ) }.map { $0.subtracting( [value] ) }
                    
                    for possible in valid {
                        for empty in cells where empty !== base {
                            if !possible.isDisjoint( with: empty.eligible ) {
                                eligible.insert( value )
                                possibles.insert( possible.union( [value] ) )
                            }
                        }
                    }
                }
                
                if eligible.count == 1 {
                    base.found( solution: eligible.first! )
                    return .found
                }
                
                if possibles.count < sum.possibles.count {
                    sum.possibles = Array( possibles )
                    sum.eligible = sum.possibles.reduce( Set<Int>(), { $0.union( $1 ) } )
                    status = .informative
                }
                
                for empty in cells where empty !== base {
                    var eligible = Set<Int>()

                    for value in base.eligible {
                        let valid = sum.possibles.filter { $0.contains( value ) }.map { $0.subtracting( [value] ) }
                        
                        for possible in valid {
                            eligible.formUnion( possible )
                        }
                    }
                    
                    let newStatus = empty.restrict( to: eligible )
                    
                    switch newStatus {
                    case .found, .finished, .bogus:
                        return newStatus
                    case .informative:
                        status = .informative
                    case .stuck:
                        break
                    }
                }
            }
        }
        
        return status
    }
}
