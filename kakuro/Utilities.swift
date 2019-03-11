//
//  Utilities.swift
//  kakuro
//
//  Created by Mark Johnson on 3/11/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

extension Set {
    func subsets() -> [Set<Element>] {
        var result = [ Set<Element>() ]
        var remaining = self
        
        for element in self {
            remaining = remaining.subtracting( [ element ] )
            
            let subsubsets = remaining.subsets()
            
            result.append( contentsOf: subsubsets.map { $0.union( [ element ] ) } )
        }
        
        return result
    }
}
