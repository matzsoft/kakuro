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
