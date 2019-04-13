//
//  Cell.swift
//  kakuro
//
//  Created by Mark Johnson on 4/15/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

protocol Cell {
    func draw( generator: cellImageGenerator, selected: Bool ) -> CGImage
    var string: String { get }
    var speechString: String { get }
}


class UnusedCell: Cell {
    func draw( generator: cellImageGenerator, selected: Bool ) -> CGImage {
        return selected ? generator.SelectUnused : generator.NormalUnused
    }
    
    var string: String {
        return "  -  "
    }
    
    var speechString: String {
        return "Unused"
    }
}


class EmptyCell: Cell {
    var eligible = Set<Int>( 1 ... 9 )
    var solution: Int? = nil
    weak var vertical: HeaderSum? = nil
    weak var horizontal: HeaderSum? = nil
    
    func found( solution: Int ) -> Void {
        self.solution = solution
        horizontal?.remove( cell: self )
        vertical?.remove( cell: self )
    }
    
    func restrict( to only: Set<Int> ) -> PuzzleSolver.Status {
        let new = eligible.intersection( only )
        
        if new.count == 0 {
            return .bogus
        }
        
        if new.count == 1 {
            found( solution: new.first! )
            return .found
        }
        
        if new != eligible {
            eligible = new
            _ = horizontal?.requireSome( of: eligible )
            _ = vertical?.requireSome( of: eligible )
            return .informative
        }
        
        return .stuck
    }
    
    func draw( generator: cellImageGenerator, selected: Bool ) -> CGImage {
        var image = selected ? generator.SelectEmpty : generator.NormalEmpty
        
        if let solved = solution {
            image = generator.labelSolved( image: image, text: String(solved) )
        } else if eligible.count < 9 {
            image = generator.labelEligible( image: image, eligible: eligible )
        }
        
        return image
    }
    
    var string: String {
        return "  .  "
    }
    
    var speechString: String {
        return "Empty"
    }
    
    func copy( from other: EmptyCell ) -> Void {
        eligible = other.eligible
        solution = other.solution
    }
    
    static func ==( lhs: EmptyCell, rhs: EmptyCell ) -> Bool {
        guard lhs.eligible == rhs.eligible else { return false }
        guard lhs.solution == rhs.solution else { return false }
        
        return true
    }
}


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


class HeaderCell: Cell {
    enum SelectType {
        case none
        case vertical
        case horizontal
        case both
    }
    
    var vertical: Int?
    var horizontal: Int?
    
    init( vertical: Int?, horizontal: Int? ) {
        self.vertical = vertical
        self.horizontal = horizontal
    }
    
    func hasNoTotal() -> Bool {
        return vertical == nil && horizontal == nil
    }
    
    func draw( generator: cellImageGenerator, selected: Bool ) -> CGImage {
        if selected {
            return draw( generator: generator, selectType: .both )
        } else {
            return draw( generator: generator, selectType: .none )
        }
    }
    
    func draw( generator: cellImageGenerator, selectType type: SelectType ) -> CGImage {
        var image: CGImage
        
        switch type {
        case .none:
            image = generator.NormalHeader
        case .vertical:
            image = generator.SelectVertical
        case .horizontal:
            image = generator.SelectHorizontal
        case .both:
            image = generator.SelectBoth
        }
        
        if let vert = vertical {
            image = generator.labelVertical( image: image, text: String( vert ) )
        }
        
        if let horz = horizontal {
            image = generator.labelHorizontal( image: image, text: String( horz ) )
        }
        
        return image
    }
    
    var string: String {
        var front = "  "
        var back  = "  "
        
        if let vert = vertical {
            front = String( format: "%2d", arguments: [vert] )
        }
        
        if let horz = horizontal {
            back = String( format: "%-2d", arguments: [horz] )
        }

        return "\(front)\\\(back)"
    }
    
    var speechString: String {
        var front = ""
        var back  = ""
        
        if let horz = horizontal {
            back = ", right \(horz)"
        }
        
        if let vert = vertical {
            front = ", down \(vert)"
        }
        
        return "Header\(front)\(back)"
    }
}


func possibilities(total: Int, number: Int, available: Set<Int>) -> Array<Set<Int>> {
    var results = Array<Set<Int>>()
    
    if number == 1 {
        if available.contains(total) {
            results.append([total])
        }
        
    } else {
        let limit = total / ( number - 1 )
        var eligible = available
        
        while !eligible.isEmpty {
            let trial = eligible.min()!
            
            if trial >= limit { break }
            
            eligible.remove(trial)
            
            let possibles = possibilities(total: total - trial, number: number - 1, available: eligible)
            
            results.append( contentsOf: possibles.map { $0.union( [trial] ) } )
        }
    }
    
    return results
}
