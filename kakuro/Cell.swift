//
//  Cell.swift
//  kakuro
//
//  Created by Mark Johnson on 4/15/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

protocol Cell {
    func draw( generator: cellImageGenerator, selected: Bool ) -> CGImage?
}


class UnusedCell: Cell {
    func draw( generator: cellImageGenerator, selected: Bool ) -> CGImage? {
        return selected ? generator.getSelectUnused() : generator.getNormalUnused()
    }
}


class EmptyCell: Cell {
    var eligible = Set<Int>( 1 ... 9 )
    
    func draw( generator: cellImageGenerator, selected: Bool ) -> CGImage? {
        return selected ? generator.getSelectEmpty() : generator.getNormalEmpty()
    }
}


class HeaderCell: Cell {
    var vertical: Int?
    var horizontal: Int?
    
    init( vertical: Int?, horizontal: Int? ) {
        self.vertical = vertical
        self.horizontal = horizontal
    }
    
    func setHorizontal( _ horizontal: Int ) {
        self.horizontal = horizontal
    }
    
    func draw( generator: cellImageGenerator, selected: Bool ) -> CGImage? {
        var image = selected ? generator.getSelectVertical() : generator.getNormalHeader()
        
        if let vert = vertical {
            image = generator.labelVertical(text: String(vert))
        }
        
        if let horz = horizontal {
            image = generator.labelHorizontal(text: String(horz))
        }
        
        return image
    }
}
