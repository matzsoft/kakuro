//
//  Puzzle.swift
//  puzzle
//
//  Created by Mark Johnson on 3/10/16.
//  Copyright © 2016 Mark Johnson. All rights reserved.
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



class Puzzle {
    var cells: [ [ Cell ] ] = []
    var nrows: Int { get { return cells.count } }
    var ncols: Int { get { return nrows > 0 ? cells[0].count : 0 } }
    var rowComplete = true
    var row = 0             // row and col must ALWAYS point to a valid cell,
    var col = 0             // except when the puzzle is empty.
    
    // Constants for puzzle drawing
    let borderWidth = CGFloat(6)
    let cellWidth   = CGFloat(82)
    let colorSpace  = CGColorSpace( name: CGColorSpace.sRGB )

    // Computed variables for puzzle drawing
    var lineGap:        CGFloat { return cellWidth + 3 }
    var interiorWidth:  CGFloat { return CGFloat( ncols + 2 ) * lineGap - 1 }
    var interiorHeight: CGFloat { return CGFloat( nrows + 2 ) * lineGap - 1 }
    var exteriorWidth:  CGFloat { return interiorWidth + 2 * borderWidth }
    var exteriorHeight: CGFloat { return interiorHeight + 2 * borderWidth }
    
    lazy var generator: cellImageGenerator = {
        return cellImageGenerator(imageWidth: Int( cellWidth ), colorSpace: colorSpace!)
    }()

    convenience init?( text: String ) {
        self.init()
        
        let parser = PuzzleParser( text: text )
        if !parser.parse( self ) {
            return nil
        }
        row = 0
        col = 0
    }
    
    
    convenience init? ( file: String ) {
        do {
            let text = try String(contentsOfFile: file, encoding: String.Encoding.utf8)
            
            self.init( text: text )
            
        } catch {
            return nil
        }
    }
    
    
    func append( _ cell: Cell ) {
        if ( rowComplete ) {
            rowComplete = false
            cells.append( [] )
        }
        
        row = cells.count - 1
        cells[row].append(cell)
        col = cells[row].count - 1
    }
    
    
    func endRow() {
        rowComplete = true
    }
    
    
    func setHorizontal( _ horizontal: Int ) {
        let lastRow = cells.count - 1
        let lastCol = cells[lastRow].count - 1
        
        cells[lastRow][lastCol].setHorizontal( horizontal )
    }
    
    
    func moveLeft() -> Bool {
        if col > 0 {
            col -= 1
            return true
        }
        
        return false
    }
    
    
    func moveRight() -> Bool {
        if col < ncols - 1 {
            col += 1
            return true
        }
        
        return false
    }
    
    
    func moveUp() -> Bool {
        if row > 0 {
            row -= 1
            return true
        }
        
        return false
    }
    
    
    func moveDown() -> Bool {
        if row < nrows - 1 {
            row += 1
            return true
        }
        
        return false
    }
    
    
    func makeImage() -> CGImage? {
        let interiorRect = CGRect( x: borderWidth, y: borderWidth, width: interiorWidth, height: interiorHeight )
        let exteriorRect = CGRect( x: 0, y: 0, width: exteriorWidth, height: exteriorHeight )
        
        let context   = CGContext( data: nil, width: Int(exteriorWidth), height: Int(exteriorHeight), bitsPerComponent: 8, bytesPerRow: Int(exteriorWidth*4), space: colorSpace!, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue )
        
        func rectFromRow( _ row: Int, andCol col: Int ) -> CGRect {
            let x = interiorRect.minX + 1 + CGFloat( col ) * lineGap
            let y = interiorRect.maxY - cellWidth - CGFloat( row ) * lineGap - 1
            
            return CGRect( x: x, y: y, width: cellWidth, height: cellWidth )
        }
        
        func drawBorderRow( _ row: Int ) {
            for col in 0 ..< ncols + 2 {
                context?.draw(generator.getBorderCell()!, in: rectFromRow( row, andCol: col ))
            }
        }
        
        func drawBorderCol( _ col: Int, andRow row: Int ) {
            context?.draw(generator.getBorderCell()!, in: rectFromRow( row, andCol: col ))
        }
        
        context?.setFillColor(generator.borderSolid )
        context?.fill(exteriorRect )
        
        drawBorderRow( 0 )
        for row in 0 ..< nrows {
            drawBorderCol( 0, andRow: row + 1 )
            for col in 0 ..< ncols {
                let cell     = cells[row][col]
                let cellRect = rectFromRow( row + 1, andCol: col + 1 )
                let selected = row == self.row && col == self.col
                
                cell.draw(context!, cellRect: cellRect, generator: generator, selected: selected)
            }
            drawBorderCol( ncols + 1, andRow: row + 1 )
        }
        drawBorderRow( nrows + 1 )
        
        return context?.makeImage()
    }
}
