//
//  Cell.swift
//  kakuro
//
//  Created by Mark Johnson on 4/15/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

protocol Cell {
    func draw( _ context: CGContext, cellRect: CGRect, generator: cellImageGenerator, selected: Bool )
}


class UnusedCell: Cell {
    func draw( _ context: CGContext, cellRect: CGRect, generator: cellImageGenerator, selected: Bool ) {
        let image = selected ? generator.getSelectUnused() : generator.getNormalUnused()
        
        context.draw(image!, in: cellRect)
    }
}


class EmptyCell: Cell {
    var eligible = Set<Int>( 1 ... 9 )
    
    func draw( _ context: CGContext, cellRect: CGRect, generator: cellImageGenerator, selected: Bool ) {
        let image = selected ? generator.getSelectEmpty() : generator.getNormalEmpty()
        
        context.draw(image!, in: cellRect)
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
    
    func draw( _ context: CGContext, cellRect: CGRect, generator: cellImageGenerator, selected: Bool ) {
        let image = selected ? generator.getSelectVertical() : generator.getNormalHeader()
        
        context.draw(image!, in: cellRect)
        
        if let vert = vertical {
            generator.labelVertical(context, text: String(vert), cellRect: cellRect)
        }
        
        if let horz = horizontal {
            generator.labelHorizontal(context, text: String(horz), cellRect: cellRect)
        }
    }
}
