//
//  UnusedCell.swift
//  kakuro
//
//  Created by Mark Johnson on 5/9/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation


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
