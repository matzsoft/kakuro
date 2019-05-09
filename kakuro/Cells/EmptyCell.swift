//
//  EmptyCell.swift
//  kakuro
//
//  Created by Mark Johnson on 5/9/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation


class EmptyCell: Cell {
    var eligible = Set<Int>( 1 ... 9 )
    var solution: Int? = nil
    weak var vertical: HeaderSum? = nil
    weak var horizontal: HeaderSum? = nil
    
    func found( solution: Int ) -> Void {
        self.solution = solution
        eligible = Set<Int>( [ solution ] )
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
