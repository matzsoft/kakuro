//
//  Puzzle.swift
//  puzzle
//
//  Created by Mark Johnson on 3/10/16.
//  Copyright © 2016 Mark Johnson. All rights reserved.
//

import Foundation

class Puzzle {
    var cells: [ [ Cell ] ] = []
    var row = 0             // row and col must ALWAYS point to a valid cell,
    var col = 0             // except when the puzzle is empty.
    var nrows: Int { return cells.count }
    var ncols: Int { return nrows == 0 ? 0 : cells.map({ $0.count}).max()! }
    
    // Constants for puzzle drawing
    let borderWidth = CGFloat(6)
    let cellWidth   = CGFloat(82)
    let colorSpace  = CGColorSpace( name: CGColorSpace.sRGB )

    // Computed variables for puzzle drawing
    var lineGap:        CGFloat { return cellWidth + 3 }
    var interiorWidth:  CGFloat { return CGFloat( ncols + 2 - 1 ) * lineGap + cellWidth }
    var interiorHeight: CGFloat { return CGFloat( nrows + 2 - 1 ) * lineGap + cellWidth }
    var exteriorWidth:  CGFloat { return interiorWidth + 2 * borderWidth }
    var exteriorHeight: CGFloat { return interiorHeight + 2 * borderWidth }
    
    lazy var generator: cellImageGenerator = {
        return cellImageGenerator(imageWidth: Int( cellWidth ), colorSpace: colorSpace!)
    }()

    var selectedCell: Cell? {
        get {
            guard nrows > 0 else { return nil }
            return cells[row][col]
        }
        set {
            if nrows > 0 {
                cells[row][col] = newValue!
            }
        }
    }
    

    // MARK: - Initializers
    
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
    
    
    // MARK: - Convenience methods for PuzzleParser
    
    func setHorizontal( _ horizontal: Int ) {
        let lastRow = cells.count - 1
        let lastCol = cells[lastRow].count - 1
        let header  = cells[lastRow][lastCol] as! HeaderCell
        
        header.horizontal = horizontal
    }
    
    
    // MARK: - Movement methods (i.e. change which cell is selected)
    
    func moveTo(row: Int, col: Int) -> Bool {
        guard row >= 0 && row < nrows            else { return false }
        guard col >= 0 && col < cells[row].count else { return false }
        guard row != self.row || col != self.col else { return false }
        
        self.row = row
        self.col = col
        return true
    }
    
    
    func moveLeft() -> Bool {
        return moveTo(row: row, col: col - 1)
    }
    
    
    func moveRight() -> Bool {
        return moveTo(row: row, col: col + 1)
    }
    
    
    func moveUp() -> Bool {
        return moveTo(row: row - 1, col: col)
    }
    
    
    func moveDown() -> Bool {
        return moveTo(row: row + 1, col: col)
    }
    
    
    func moveToBeginningOfLine() -> Bool {
        return moveTo(row: row, col: 0)
    }
    
    
    func moveToEndOfLine() -> Bool {
        guard nrows > 0 else { return false }
        
        return moveTo(row: row, col: cells[row].count - 1)
    }
    
    
    func moveToBeginningOfDocument() -> Bool {
        return moveTo(row: 0, col: 0)
    }
    
    
    func moveToEndOfDocument() -> Bool {
        guard nrows > 0 else { return false }
        
        let lastRow = nrows - 1
        
        return moveTo(row: lastRow, col: cells[lastRow].count - 1)
    }
    
    // MARK: - Change the type of the selected cell
    
    func changeToUnused() -> Bool {
        guard nrows > 0 else { return false }
        if selectedCell is UnusedCell { return false }
        
        selectedCell = UnusedCell()
        return true
    }
    
    
    func changeToEmpty() -> Bool {
        guard nrows > 0 else { return false }
        if selectedCell is EmptyCell { return false }
        
        selectedCell = EmptyCell()
        return true
    }
    
    
    func changeToHeader() -> Bool {
        guard nrows > 0 else { return false }
        
        if !( selectedCell is HeaderCell ) {
            selectedCell = HeaderCell(vertical: nil, horizontal: nil)
        }
        
        return true
    }
    
    // MARK: - Add a cell (or cells) to the puzzle
    
    func append( _ cell: Cell ) {
        if ( nrows == 0 ) {
            cells.append( [] )
        }
        
        row = cells.count - 1
        cells[row].append(cell)
        col = cells[row].count - 1
    }
    
    
    func appendCell() -> Bool {
        if nrows == 0 {
            append(UnusedCell())
            return true
        }
        
        switch selectedCell {
        case is UnusedCell:
            cells[row].insert( UnusedCell(), at: col + 1 )
            
        case is EmptyCell:
            cells[row].insert( EmptyCell(), at: col + 1 )
            
        case let header as HeaderCell:
            if header.horizontal != nil {
                cells[row].insert( EmptyCell(), at: col + 1 )
            } else {
                cells[row].insert( HeaderCell(vertical: nil, horizontal: nil), at: col + 1 )
            }
            
        default:
            fatalError("Unknown Cell Type")
        }

        col += 1
        return true
    }
    
    
    func insertBefore() -> Bool {
        if nrows == 0 {
            append(UnusedCell())
            return true
        }
        
        if col == 0 {
            cells[row].insert( UnusedCell(), at: col )
            return true
        }
        
        col -= 1
        return appendCell()
    }
    
    
    func appendCount(_ count: Int) -> Bool {
        if nrows == 0 {
            for _ in 1 ... count { append( UnusedCell() ) }
            append( HeaderCell(vertical: nil, horizontal: nil) )
            return  true
        }
        
        if count < 2 || col < cells[row].count - 1 {
            return false
        }
        
        for _ in 2 ... count {
            if !appendCell() {
                return false
            }
        }
        
        return true
    }
    
    
    func appendNewRow( cell: Cell ) {
        if nrows == 0 {
            append( UnusedCell() )
            return
        }
        
        cells.insert( [ cell ], at: row + 1 )
        row += 1
        col = 0
    }
    
    
    func lineBreak() -> Bool {
        if nrows == 0 {
            append( UnusedCell() )
            return true
        }
        
        if !moveToEndOfLine() {
            return false
        }
        
        while cells[row].count < ncols {
            if !appendCell() {
                return false
            }
        }
        
        appendNewRow(cell: HeaderCell(vertical: nil, horizontal: nil))
        return true
    }
    

    // MARK: - Hybred methods, either change the selection or add a cell depending
    
    func newLine() -> Bool {
        if nrows == 0 {
            append( UnusedCell() )
            return true
        }
        
        _ = moveToEndOfLine()
        while cells[row].count < ncols {
            if !appendCell() {
                return false
            }
        }
        
        if row < nrows - 1 {
            return moveTo(row: row + 1, col: 0)
        }
        
        appendNewRow(cell: HeaderCell(vertical: nil, horizontal: nil))
        return true
    }
    
    
    func advanceOrAppend() -> Bool {
        if nrows > 0 && col < cells[row].count - 1 {
            return moveTo(row: row, col: col + 1)
        }
        
        return appendCell()
    }
    
    
    // MARK: - Delete a cell (and the row if it's the last cell in the row)
    
    func deleteBackward() -> Bool {
        guard col > 0 else { return false }
        
        col -= 1
        return deleteForward()
    }
    
    
    func deleteForward() -> Bool {
        cells[row].remove(at: col)
        if cells[row].count == 0 {
            cells.remove(at: row)
            if row > 0 && row == nrows {
                row -= 1
            }
            return true
        }
        
        if col == cells[row].count {
            col -= 1
        }
        return true
    }
    
    
    // MARK: - Puzzle drawing methods and utilities
    
    func selectFrom(point: NSPoint) -> Bool {
        let min = borderWidth + lineGap
        let width = interiorWidth - lineGap - cellWidth
        let height = interiorHeight - lineGap - cellWidth
        let puzzleRect = CGRect( x: min, y: min, width: width, height: height )
        
        guard puzzleRect.contains(point) else { return false }
        
        let row = Int( ( puzzleRect.maxY - point.y /*- cellWidth*/ ) / lineGap )
        let col = Int( ( point.x - puzzleRect.minX ) / lineGap )
        let cellRect = rectFrom(row: row + 1, col: col + 1)
        
        guard cellRect.contains(point) else { return false }

        return moveTo(row: row, col: col)
    }

    
    // NOTE: row and col here include the border cells around the puzzle
    func rectFrom( row: Int, col: Int ) -> CGRect {
        let interiorRect = CGRect( x: borderWidth, y: borderWidth, width: interiorWidth, height: interiorHeight )
        let x = interiorRect.minX + CGFloat( col ) * lineGap
        let y = interiorRect.maxY - CGFloat( row ) * lineGap - cellWidth
        
        return CGRect( x: x, y: y, width: cellWidth, height: cellWidth )
    }
    
    
    func selectedRect() -> CGRect {
        return rectFrom(row: row + 1, col: col + 1)
    }
    

    func makeImage( editSelected: Bool, editHorizontal: Bool ) -> CGImage? {
        let exteriorRect = CGRect( x: 0, y: 0, width: exteriorWidth, height: exteriorHeight )
        
        let context   = CGContext( data: nil, width: Int(exteriorWidth), height: Int(exteriorHeight), bitsPerComponent: 8, bytesPerRow: Int(exteriorWidth*4), space: colorSpace!, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue )
        
        func drawBorderRow( _ row: Int ) {
            let cell = generator.BorderCell
            
            for col in 0 ..< ncols + 2 {
                context?.draw(cell, in: rectFrom( row: row, col: col ))
            }
        }
        
        func drawBorderCol( _ col: Int, andRow row: Int ) {
            context?.draw(generator.BorderCell, in: rectFrom( row: row, col: col ))
        }
        
        context?.setFillColor(generator.borderSolid )
        context?.fill(exteriorRect )
        
        drawBorderRow( 0 )
        for row in 0 ..< nrows {
            drawBorderCol( 0, andRow: row + 1 )
            for col in 0 ..< cells[row].count {
                let cell     = cells[row][col]
                let cellRect = rectFrom( row: row + 1, col: col + 1 )
                let selected = row == self.row && col == self.col
                var image: CGImage?
                
                if !selected || !editSelected {
                    image = cell.draw(generator: generator, selected: selected)
                } else {
                    let header = cell as! HeaderCell
                    
                    if editHorizontal {
                        image = header.draw(generator: generator, selectType: .horizontal)
                    } else {
                        image = header.draw(generator: generator, selectType: .vertical)
                    }
                }
                
                context?.draw(image!, in: cellRect)
            }
            drawBorderCol( ncols + 1, andRow: row + 1 )
        }
        drawBorderRow( nrows + 1 )
        
        return context?.makeImage()
    }
    
    // MARK: - Methods for converting a puzzle to a string
    
    var string: String {
        guard nrows > 0 else { return "" }
        var result = ""
        
        for row in 0 ..< nrows {
            for col in 0 ..< cells[row].count {
                result.append(cells[row][col].string)
            }
            result.append("\n")
        }
        
        return result
    }
}
