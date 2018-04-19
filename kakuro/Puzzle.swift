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
        let header  = cells[lastRow][lastCol] as! HeaderCell
        
        header.setHorizontal( horizontal )
    }
    
    
    func moveTo(row: Int, col: Int) -> Bool {
        if row < 0 || row >= nrows {
            return false
        }
        
        if col < 0 || col >= cells[row].count {
            return false
        }
        
        self.row = row
        self.col = col
        return true
    }
    
    
    func newCells(_ count: Int) -> Bool {
        var modified = false
        
        for _ in 1...count {
            if col == ncols - 1 && row > 0 {
                break
            }
            
            if col < cells[row].count - 1 {
                modified = moveTo(row: row, col: col + 1) || modified
            } else {
                let cell = selectedCell
                
                switch cell {
                case is UnusedCell:
                    append( UnusedCell() )
                    
                case is EmptyCell:
                    append( EmptyCell() )
                    
                case is HeaderCell:
                    let header = cell as! HeaderCell
                    
                    if header.horizontal != nil {
                        append( EmptyCell() )
                    } else {
                        append( HeaderCell(vertical: nil, horizontal: nil) )
                    }
                    
                default:
                    fatalError("Unknown Cell Type")
                }
                modified = true
            }
        }
        
        return modified
    }
    
    
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
    
    
    func newLine() -> Bool {
        if row < nrows - 1 {
            return moveTo(row: row + 1, col: 0)
        }
        
        if cells[row].count < ncols {
            let _ = newCells(ncols - cells[row].count)
        }
        
        endRow()
        append( HeaderCell(vertical: nil, horizontal: nil) )
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
        let lastRow = nrows - 1
        
        guard lastRow >= 0 else { return false }

        return moveTo(row: lastRow, col: cells[lastRow].count - 1)
    }
    
    
    func deleteBackward() -> Bool {
        return false
    }
    
    
    func deleteForward() -> Bool {
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
            for col in 0 ..< cells[row].count {
                let cell     = cells[row][col]
                let cellRect = rectFromRow( row + 1, andCol: col + 1 )
                let selected = row == self.row && col == self.col
                let image = cell.draw(generator: generator, selected: selected)
                
                context?.draw(image!, in: cellRect)
            }
            drawBorderCol( ncols + 1, andRow: row + 1 )
        }
        drawBorderRow( nrows + 1 )
        
        return context?.makeImage()
    }
}
