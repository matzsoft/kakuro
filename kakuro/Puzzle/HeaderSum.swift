//
//  HeaderSum.swift
//  kakuro
//
//  Created by Mark Johnson on 5/9/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation


class HeaderSum {
    var total: Int
    var cells: [ EmptyCell ]
    var eligible: Set<Int>
    var possibles: [ Set<Int> ]
    
    var unsolvedCells: [ EmptyCell ] {
        return cells.filter { $0.solution == nil }
    }
    
    init(total: Int) {
        self.total = total
        cells = []
        eligible = Set<Int>( 1 ... 9 )
        possibles = []
    }
    
    init( from other: HeaderSum ) {
        total = other.total
        eligible = other.eligible
        possibles = other.possibles
        cells = other.cells
    }
    
    func workingCopy() -> HeaderSum {
        let copy = HeaderSum( total: total )
        
        copy.eligible = eligible
        copy.possibles = possibles
        copy.cells = cells.map {
            let new = EmptyCell()
            
            new.eligible = $0.eligible
            new.horizontal = copy
            return new
        }
        
        return copy
    }
    
    func workingCopy( possible: Set<Int> ) -> HeaderSum {
        let copy = HeaderSum( total: total )
        
        copy.eligible = possible
        copy.possibles = [ possible ]
        copy.cells = unsolvedCells.map {
            let new = EmptyCell()
            
            new.eligible = $0.eligible.intersection( possible )
            new.horizontal = copy
            return new
        }
        
        return copy
    }
    
    func emptyCopy() -> HeaderSum {
        let copy = HeaderSum( total: total )
        
        copy.eligible = Set<Int>()
        copy.possibles = []
        copy.cells = cells.map {
            let new = EmptyCell()
            
            if $0.solution == nil {
                new.eligible = Set<Int>()
            } else {
                new.eligible = $0.eligible
                new.solution = $0.solution
            }
            
            new.horizontal = copy
            return new
        }
        
        return copy
    }
    
    func setCells(cells: [EmptyCell]) {
        self.cells = cells
        possibles = possibilities( total: total, number: cells.count, available: Set<Int>( 1 ... 9 ) )
        eligible = possibles.reduce( Set<Int>(), { $0.union( $1 ) } )
    }
    
    func remove( cell: EmptyCell ) -> Void {
        guard let value = cell.solution else { return }
        
        total -= value
        possibles = possibles.filter { $0.contains( value ) }.map { $0.filter { $0 != value } }
        eligible = possibles.reduce( Set<Int>(), { $0.union( $1 ) } )
        unsolvedCells.forEach { $0.eligible.formIntersection( eligible ) }
    }
    
    func requireSome( of set: Set<Int> ) -> Bool {
        let count = possibles.count
        
        possibles = possibles.filter { !$0.isDisjoint( with: set ) }
        eligible = possibles.reduce( Set<Int>(), { $0.union( $1 ) } )
        
        return possibles.count < count
    }
    
    func copy( from other: HeaderSum ) -> Void {
        total = other.total
        eligible = other.eligible
        possibles = other.possibles
        cells.enumerated().forEach { $0.element.copy( from: other.cells[$0.offset] ) }
    }
    
    static func ==( lhs: HeaderSum, rhs: HeaderSum ) -> Bool {
        guard lhs.total == rhs.total else { return false }
        guard lhs.eligible == rhs.eligible else { return false }
        guard lhs.possibles == rhs.possibles else { return false }
        guard lhs.cells.count == rhs.cells.count else { return false }
        
        return ( 0 ..< lhs.cells.count ).allSatisfy { lhs.cells[$0] == rhs.cells[$0] }
    }
    
    static func !=( lhs: HeaderSum, rhs: HeaderSum ) -> Bool {
        return !( lhs == rhs )
    }
}
