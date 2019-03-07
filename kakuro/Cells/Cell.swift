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
    weak var vertical: HeaderCell? = nil
    weak var horizontal: HeaderCell? = nil
    
    func found( solution: Int ) -> Void {
        self.solution = solution
        horizontal?.horizontal!.remove( value: solution )
        vertical?.vertical!.remove( value: solution )
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
            _ = horizontal?.horizontal?.requireSome( of: eligible )
            _ = vertical?.vertical?.requireSome( of: eligible )
            return .informative
        }
        
        return .stuck
    }
    
    func draw( generator: cellImageGenerator, selected: Bool ) -> CGImage {
        var image = selected ? generator.SelectEmpty : generator.NormalEmpty
        
        if let solved = solution {
            image = generator.labelSolved( image: image, text: String(solved) )
        }
        
        return image
    }
    
    var string: String {
        return "  .  "
    }
    
    var speechString: String {
        return "Empty"
    }
}


class HeaderSum {
    var total: Int
    var cells: [ EmptyCell ]
    var eligible: Set<Int>
    var possibles: [ Set<Int> ]
    
    init(total: Int) {
        self.total = total
        cells = []
        eligible = Set<Int>( 1 ... 9 )
        possibles = []
    }
    
    func setCells(cells: [EmptyCell]) {
        self.cells = cells
        possibles = possibilities( total: total, number: cells.count, available: Set<Int>( 1 ... 9 ) )
        eligible = possibles.reduce( Set<Int>(), { $0.union( $1 ) } )
    }
    
    func remove( value: Int ) -> Void {
        possibles = possibles.filter { $0.contains( value ) }.map { $0.filter { $0 != value } }
        eligible = possibles.reduce( Set<Int>(), { $0.union( $1 ) } )
    }
    
    func requireSome( of set: Set<Int> ) -> Bool {
        let count = possibles.count
        
        possibles = possibles.filter { !$0.isDisjoint( with: set ) }
        eligible = possibles.reduce( Set<Int>(), { $0.union( $1 ) } )
        
        return possibles.count < count
    }
}


class HeaderCell: Cell {
    enum SelectType {
        case none
        case vertical
        case horizontal
        case both
    }
    
    var vertical: HeaderSum?
    var horizontal: HeaderSum?
    
    init( vertical: Int?, horizontal: Int? ) {
        if let total = vertical {
            self.vertical = HeaderSum(total: total)
        } else {
            self.vertical = nil
        }
        
        if let total = horizontal {
            self.horizontal = HeaderSum(total: total)
        } else {
            self.horizontal = nil
        }
    }
    
    func setVertical( _ vertical: Int? ) {
        if let total = vertical {
            self.vertical = HeaderSum(total: total)
        } else {
            self.vertical = nil
        }
    }
    
    func setHorizontal( _ horizontal: Int? ) {
        if let total = horizontal {
            self.horizontal = HeaderSum(total: total)
        } else {
            self.horizontal = nil
        }
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
            image = generator.labelVertical(image: image, text: String(vert.total))
        }
        
        if let horz = horizontal {
            image = generator.labelHorizontal(image: image, text: String(horz.total))
        }
        
        return image
    }
    
    var string: String {
        var front = "  "
        var back  = "  "
        
        if let vert = vertical {
            front = String(format: "%2d", arguments: [vert.total])
        }
        
        if let horz = horizontal {
            back = String(format: "%-2d", arguments: [horz.total])
        }

        return "\(front)\\\(back)"
    }
    
    var speechString: String {
        var front = ""
        var back  = ""
        
        if let vert = vertical {
            front = ", down \(vert.total)"
        }
        
        if let horz = horizontal {
            back = ", right \(horz.total)"
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
