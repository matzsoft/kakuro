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
    
    func setHorizontal( _ horizontal: Int ) {
        self.horizontal = horizontal
    }
    
    func draw( generator: cellImageGenerator, selected: Bool ) -> CGImage? {
        return selected ? draw( generator: generator, selectType: .both ) : draw( generator: generator, selectType: .none )
    }
    
    func draw( generator: cellImageGenerator, selectType type: SelectType ) -> CGImage? {
        var image: CGImage?
        
        switch type {
        case .none:
            image = generator.getNormalHeader()
        case .vertical:
            image = generator.getSelectVertical()
        case .horizontal:
            image = generator.getSelectHorizontal()
        case .both:
            image = generator.getSelectBoth()
        }
        
        if let vert = vertical {
            image = generator.labelVertical(text: String(vert))
        }
        
        if let horz = horizontal {
            image = generator.labelHorizontal(text: String(horz))
        }
        
        return image
    }
}
