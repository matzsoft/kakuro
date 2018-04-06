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
    
    
    fileprivate static func drawLabel( _ context: CGContext, text: String, rect: CGRect, textRange: CGRect, attributes: [String:AnyObject] ) {
        let attrString = CFAttributedStringCreate( kCFAllocatorDefault, text as CFString, attributes as CFDictionary )
        let line       = CTLineCreateWithAttributedString( attrString! )
        let textSize   = CTLineGetImageBounds( line, context )
        let x          = rect.minX - textRange.minX + ( rect.width - textSize.width ) / 2
        let y          = rect.minY - textRange.minY + ( rect.height - textSize.height ) / 2
        
        context.textPosition = CGPoint( x: x, y: y)
        context.saveGState()
        CTLineDraw( line, context )
        context.restoreGState()
    }
    
    
    func draw( _ context: CGContext, cellRect: CGRect, generator: cellImageGenerator, textRange: CGRect, attributes: [String:AnyObject] ) {
        switch self {
        case .unused:
            context.draw(generator.getNormalUnused()!, in: cellRect)
            
        case .empty:
            context.draw(generator.getNormalEmpty()!, in: cellRect)
            
        case .header( let vertical, let horizontal ):
            context.draw(generator.getNormalHeader()!, in: cellRect)
            
            if let vert = vertical {
                let rect = generator.getVerticalRect( textRange ).offsetBy(dx: cellRect.minX, dy: cellRect.minY )
                
                Cell.drawLabel( context, text: String( vert ), rect: rect, textRange: textRange, attributes: attributes )
            }
            
            if let horz = horizontal {
                let rect = generator.getHorizontalRect( textRange ).offsetBy(dx: cellRect.minX, dy: cellRect.minY )
                
                Cell.drawLabel( context, text: String( horz ), rect: rect, textRange: textRange, attributes: attributes )
            }
        }
    }
}



class Puzzle {
    var cells: [ [ Cell ] ] = []
    var rowComplete = true
    
    convenience init?( text: String ) {
        self.init()
        
        let parser = PuzzleParser( text: text )
        if !parser.parse( self ) {
            return nil
        }
    }
    
    
    convenience init?( fromFile: String ) {
        self.init()
        
        if let parser = PuzzleParser(file: fromFile) {
            if !parser.parse( self ) {
                return nil
            }
        }
    }
    
    
    func append( _ cell: Cell ) {
        if ( rowComplete ) {
            cells.append( [] )
            rowComplete = false
        }
        
        let lastRow = cells.count - 1
        
        cells[lastRow].append(cell)
    }
    
    
    func endRow() {
        rowComplete = true
    }
    
    
    func setHorizontal( _ horizontal: Int ) {
        let lastRow = cells.count - 1
        let lastCol = cells[lastRow].count - 1
        
        cells[lastRow][lastCol].setHorizontal( horizontal )
    }
    
    
    fileprivate func trialFont( _ context: CGContext, generator: cellImageGenerator, scaleFactor: CGFloat ) -> ( [ String: AnyObject ], CGRect ) {
        let fontAttributes = [
            String( kCTFontFamilyNameAttribute ): "Arial",
            String( kCTFontStyleNameAttribute ):  "Regular",
            String( kCTFontSizeAttribute ):       20.0 * scaleFactor
        ] as [String : Any]
        let fontDescriptor = CTFontDescriptorCreateWithAttributes( fontAttributes as CFDictionary )
        let font           = CTFontCreateWithFontDescriptor( fontDescriptor, 0.0, nil )
        
        let attributes: [ String: AnyObject ] = [
            String( kCTFontAttributeName ):            font,
            String( kCTForegroundColorAttributeName ): generator.borderSolid
        ]
        var textRange = CGRect( x: 0, y: 0, width: 0, height: 0 )
        
        context.textPosition = CGPoint( x: 0, y: 0)
        for label in 3 ... 45 {
            let text     = CFAttributedStringCreate( kCFAllocatorDefault, String( label ) as CFString, attributes as CFDictionary )
            let line     = CTLineCreateWithAttributedString( text! )
            let textRect = CTLineGetImageBounds( line, context )
            
            textRange = textRange.union(textRect )
        }
        
        return ( attributes, textRange )
    }
    
    
    fileprivate func setupFont( _ context: CGContext, generator: cellImageGenerator ) -> ( [ String: AnyObject ], CGRect ) {
        var ( attributes, textRange ) = trialFont( context, generator: generator, scaleFactor: 1 )
        let vertRect = generator.getVerticalRect( textRange )
        let scaleFactor = vertRect.height / textRange.height
        
        ( attributes, textRange ) = trialFont( context, generator: generator, scaleFactor: scaleFactor )
        
        return ( attributes, textRange )
    }
    
    
    func makeImage() -> CGImage? {
        let borderWidth = CGFloat(6)
        let cellWidth   = CGFloat(82)
        let nrows       = cells.count
        let ncols       = nrows > 0 ? cells[0].count : 0
        
        let lineGap        = cellWidth + 3
        let interiorWidth  = CGFloat( ncols + 2 ) * lineGap - 1
        let interiorHeight = CGFloat( nrows + 2 ) * lineGap - 1
        let interiorRect   = CGRect( x: borderWidth, y: borderWidth, width: interiorWidth, height: interiorHeight )
        let exteriorRect   = CGRect( x: 0, y: 0, width: interiorRect.width + 2 * borderWidth, height: interiorRect.height + 2 * borderWidth )
        
        let colorSpace = CGColorSpace( name: CGColorSpace.sRGB )
        let context    = CGContext( data: nil, width: Int(exteriorRect.width), height: Int(exteriorRect.height), bitsPerComponent: 8, bytesPerRow: Int(exteriorRect.width*4), space: colorSpace!, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue )
        
        let generator  = cellImageGenerator( imageWidth: Int( cellWidth ), colorSpace: colorSpace! )
        
        let ( attributes, textRange ) = setupFont( context!, generator: generator )
        
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
                
                cell.draw( context!, cellRect: cellRect, generator: generator, textRange: textRange, attributes: attributes )
            }
            drawBorderCol( ncols + 1, andRow: row + 1 )
        }
        drawBorderRow( nrows + 1 )
        
        return context?.makeImage()
    }
}
