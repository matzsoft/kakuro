//
//  Cell.swift
//  kakuro
//
//  Created by Mark Johnson on 4/15/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

enum Cell {
    case unused
    case header( vertical: Int?, horizontal: Int? )
    case empty( eligible: Set<Int> )
    
    mutating func setHorizontal( _ horizontal: Int ) {
        if case let .header(vertical,_) = self {
            self = .header( vertical: vertical, horizontal: horizontal )
        }
    }
    
    
    func draw( _ context: CGContext, cellRect: CGRect, generator: cellImageGenerator, selected: Bool ) {
        switch self {
        case .unused:
            let image = selected ? generator.getSelectUnused() : generator.getNormalUnused()
            
            context.draw(image!, in: cellRect)
            
        case .empty:
            let image = selected ? generator.getSelectEmpty() : generator.getNormalEmpty()
            
            context.draw(image!, in: cellRect)
            
        case .header( let vertical, let horizontal ):
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
}
