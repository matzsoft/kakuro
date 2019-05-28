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
    let cellIterator: CircularIterator2D<Cell>

    init( with puzzle: Puzzle ) {
        cellIterator = CircularIterator2D( array: puzzle.cells )
        super.init()
        cells = puzzle.cells
        setupPuzzle()
    }
    
    private func setupPuzzle() -> Void {
        cellIterator.reset()
        while let cell = cellIterator.next() {
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
        guard let total = header.horizontal else { return }
        let sum = HeaderSum( total: total )
        var cells: [EmptyCell] = []
        
        for newCol in cellIterator.ccol + 1 ..< self.cells[cellIterator.crow].count {
            guard let cell = self.cells[cellIterator.crow][newCol] as? EmptyCell else { break }
            
            cell.horizontal = sum
            cells.append(cell)
        }
        
        sum.setCells( cells: cells )
        headerSums.append( sum )
    }
    
    private func setupVertical( _ header: HeaderCell ) {
        guard let total = header.vertical else { return }
        let sum = HeaderSum( total: total )
        var cells: [EmptyCell] = []
        
        for newRow in cellIterator.crow + 1 ..< nrows {
            guard let cell = self.cells[newRow][cellIterator.ccol] as? EmptyCell else { break }
            
            cell.vertical = sum
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
        
        if status == .stuck {
            headerSums.removeAll( where: { $0.total == 0 } )
            status = enumeration()
        }
        
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

        cellIterator.markStart()
        while let cell = cellIterator.next() {
            if let empty = cell as? EmptyCell, empty.solution == nil {
                if status == .finished { status = .stuck }
                if let horzSum = empty.horizontal, let vertSum = empty.vertical {
                    let eligible = horzSum.eligible.intersection( vertSum.eligible )
                    let newStatus = empty.restrict( to: eligible )
                    
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

        return status
    }
    
    func reduceRequired( sum: HeaderSum ) -> Status {
        var status = Status.stuck
        
        let required = sum.possibles.reduce( Set<Int>( 1...9 ), { $0.intersection( $1 ) } )
        let subsets = required.subsets().sorted { $0.count < $1.count }
        
        for subset in subsets where subset.count > 0 {
            let cells = sum.unsolvedCells.filter { !$0.eligible.isDisjoint( with: subset ) }
            
            if cells.isEmpty {
                return .bogus
            }
            if subset.count == cells.count {
                for empty in cells {
                    let newStatus = empty.restrict( to: subset )
                    
                    switch newStatus {
                    case .found, .finished, .bogus:
                        return newStatus
                    case .informative:
                        status = newStatus
                    case .stuck:
                        break
                    }
                }
            } else {
                let cells = cells.filter { $0.eligible.subtracting( subset ).isEmpty }
                
                if subset.count == cells.count {
                    for empty in cells {
                        let newStatus = empty.restrict( to: subset )
                        
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
    
    func enumeration() -> Status {
        var status = Status.stuck
        
        for sum in headerSums {
            let accumulator = sum.emptyCopy()
            
            for possible in sum.possibles {
                let trial = sum.workingCopy( possible: possible )
                
                if enumeration( trial: trial ) {
                    accumulator.eligible.formUnion( possible )
                    accumulator.possibles.append( possible )
                    accumulator.unsolvedCells.enumerated().forEach {
                        $0.element.eligible.formUnion( trial.cells[$0.offset].eligible )
                    }
                }
            }
            
            if accumulator != sum {
                sum.copy( from: accumulator )
                status = .informative
            }
        }
        
        return status
    }
    
    func enumeration( trial: HeaderSum ) -> Bool {
        while true {
            let newStatus = reduceRequired( sum: trial )
            
            switch newStatus {
            case .finished, .bogus:
                return false
            case .informative, .found:
                let available = trial.unsolvedCells.reduce( Set<Int>(), { $0.union( $1.eligible ) } )
                
                if trial.eligible.subtracting( available ).count > 0 {
                    return false
                }
            case .stuck:
                return trial.cells.allSatisfy { $0.eligible.count > 0 }
            }
        }
    }
}
